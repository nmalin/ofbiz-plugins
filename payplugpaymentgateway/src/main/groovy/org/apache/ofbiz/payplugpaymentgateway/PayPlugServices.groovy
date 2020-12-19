import com.fasterxml.jackson.databind.ObjectMapper
import org.apache.ofbiz.base.lang.JSON
import org.apache.ofbiz.base.util.HttpClient
import org.apache.ofbiz.base.util.SSLUtil
import org.apache.ofbiz.base.util.StringUtil
import org.apache.ofbiz.base.util.UtilDateTime
import org.apache.ofbiz.base.util.UtilIO
import org.apache.ofbiz.base.util.UtilProperties
import org.apache.ofbiz.entity.GenericValue
import org.apache.ofbiz.order.order.OrderReadHelper
import org.apache.ofbiz.product.store.ProductStoreWorker

import java.nio.charset.Charset

def ensureStringSize(String value, int maxSize) {
    if (! value) return null
    return value.length() > maxSize ?
            value.substring(0, maxSize):
            value
}

def createPayPlugPaymentForOrder() {

    Locale locale = context.locale
    OrderReadHelper orh = new OrderReadHelper(delegator, context.orderId)
    String currency = orh.getCurrency()
    BigDecimal processAmount = orh.getOrderGrandTotal()
            .setScale(2, BigDecimal.ROUND_HALF_EVEN)
            .movePointRight(2)

    GenericValue orderPaymentPerference = from("OrderPaymentPreference")
            .where(orderId: orh.getOrderId(),
                    paymentMethodTypeId: "EXT_PAYPLUG",
                    statusId: "PAYMENT_NOT_RECEIVED")
            .queryFirst()
    if (! orderPaymentPerference) {
        return error(UtilProperties.getMessage('PayPlugUiLabels', 'PayPlugOrderNotWaitPayment', locale))
    }

    GenericValue payPlugSetting = ProductStoreWorker.getProductStorePaymentSetting(delegator, orh.getProductStoreId(), "EXT_PAYPLUG", null, true)
    GenericValue payPlugConfig = from("PaymentGatewayPayPlug").where(payPlugSetting).cache().queryOne()

    //from("PaymentGatewayPayPlug").where(context).cache().queryOne()
    GenericValue billToCustomer = orh.getBillToParty()
    String email = orh.getOrderEmailString()
    if (!email) {
        Map emailMap = run service: 'getPartyEmail', with: [partyId: billToCustomer.partyId]
        email = emailMap.emailAddress
    }

    Map postalAddressMap
    List billingLocations = orh.getBillingLocations()
    if (!billingLocations) {
        postalAddressMap = run service: 'getPartyPostalAddress', with: [partyId                 : billToCustomer.partyId,
                                                                        contactMechPurposeTypeId: 'BILLING_LOCATION']
        if (! postalAddressMap.address1) {
            postalAddressMap = run service: 'getPartyPostalAddress', with: [partyId                 : billToCustomer.partyId,
                                                                            contactMechPurposeTypeId: 'SHIPPING_LOCATION']
        }
    } else {
        postalAddressMap = billingLocations[0]
    }

    String telecomNumber
    String informMethod = "EMAIL"
    if (!email) {
        Map telecomMap = run service: 'getPartyTelecomNumber', with: [partyId                 : billToCustomer.partyId,
                                                                      contactMechPurposeTypeId: 'PHONE_MOBILE']
        telecomNumber = telecomMap.telecomNumber
    }
    Map customerMap = [email     : email ?: "",
                       first_name: billToCustomer.getEntityName() == "Person" ? billToCustomer.firstName : billToCustomer.groupName,
                       last_name : billToCustomer.getEntityName() == "Person" ? billToCustomer.lastName : " ",
                       language  : ensureStringSize(locale.toString(), 2)]
    if (telecomNumber) {
        customerMap.phone_number = StringUtil.removeNonNumeric(telecomNumber)
        informMethod = "SMS"
    }
    if (postalAddressMap.address1) {
        customerMap.address1 = ensureStringSize(postalAddressMap.address1, 254)
        customerMap.address2 = ensureStringSize(postalAddressMap.address2, 254)
        customerMap.postcode = ensureStringSize(postalAddressMap.postalCode, 16)
        customerMap.city = ensureStringSize(postalAddressMap.city, 100)
        customerMap.country = from("Geo").where(geoId: postalAddressMap.countryGeoId).cache().queryOne()?.geoCode
    }

    Map<String, Object> ccAuthReqContext = [
            amount          : processAmount,
            currency        : currency,
            customer        : customerMap,
            hosted_payment  : [
                    return_url: payPlugConfig.returnUrl ? "${payPlugConfig.returnUrl}/${orh.getOrderId()}" as String: null,
                    cancel_url: payPlugConfig.cancelUrl ? "${payPlugConfig.cancelUrl}/${orh.getOrderId()}" as String: null,
                    sent_by   : informMethod],
            notification_url: payPlugConfig.notificationUrl ?: null,
            save_card       : payPlugConfig.saveCard == 'Y',
            force_3ds       : payPlugConfig.force3ds == 'Y']

    //prepare request
    String requestBody = JSON.from(ccAuthReqContext)
    HttpClient restClient = new HttpClient(payPlugConfig.transactionUrl + "/v1/payments")
    restClient.setHeaders([Authorization: "Bearer " + payPlugConfig.apiKey])
    restClient.setRawStream(requestBody)
    restClient.setContentType("application/json")
    restClient.setAllowUntrusted(true)
    restClient.setHostVerificationLevel(SSLUtil.getHostCertNoCheck())
    InputStream callResult = restClient.postStream()
    String responseStatus = restClient.getResponseCode()
    String responseString = UtilIO.readString(callResult, Charset.forName("UTF-8"))

    GenericValue paymentGatewayResponse = makeValue("PaymentGatewayResponse", [
            paymentGatewayResponseId: delegator.getNextSeqId("PaymentGatewayResponse"),
            orderPaymentPreferenceId: orderPaymentPerference.orderPaymentPreferenceId,
            amount: orh.getOrderGrandTotal(),
            paymentMethodTypeId: "EXT_PAYPLUG",
            paymentServiceTypeEnumId: "PRDS_PAY_EXTERNAL",
            currencyUomId: orh.getCurrency(),
            gatewayMessage: ensureStringSize(responseString, 255),
            transactionDate: UtilDateTime.nowTimestamp()])
    if (responseStatus == 200
            || responseStatus == 201) {

        Map convertedMap = new ObjectMapper().readValue(responseString, Map.class)

        if (convertedMap.object == "payment") {
            paymentGatewayResponse.referenceNum = convertedMap.id
            paymentGatewayResponse.create()
            return [payPlugPaymentId  : convertedMap.id,
                    redirectPaymentUrl: convertedMap.hosted_payment.payment_url]
        }
        paymentGatewayResponse.referenceNum = "ERROR : Not a Payment"
        paymentGatewayResponse.create()
        return failure(UtilProperties.getMessage('PayPlugUiLabels', 'PayPlugUnparsableResponse', locale))
    }
    paymentGatewayResponse.referenceNum = "ERROR : " + responseStatus
    paymentGatewayResponse.create()
    return failure(UtilProperties.getMessage('PayPlugUiLabels', 'PayPlugCallFailed', locale))
}


