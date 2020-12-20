/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.apache.ofbiz.payplugpaymentgateway

import com.fasterxml.jackson.databind.ObjectMapper
import org.apache.http.util.EntityUtils
import org.apache.ofbiz.base.util.StringUtil
import org.apache.ofbiz.base.util.UtilDateTime
import org.apache.ofbiz.base.util.UtilProperties
import org.apache.ofbiz.entity.GenericValue
import org.apache.ofbiz.entity.transaction.TransactionUtil
import org.apache.ofbiz.order.order.OrderChangeHelper
import org.apache.ofbiz.service.ServiceUtil


def callPayPlug() {
    String orderId = context.orderId ?: parameters.orderId
    Map createPaymentResult = run service: 'payplugCreatePaymentForOrder', with: [orderId: orderId]
    if (! ServiceUtil.isSuccess(createPaymentResult)) {
        return error(ServiceUtil.getErrorMessage(createPaymentResult))
    }

    // payment init created on payPlug server, store the reference and redirect the browser
    response.sendRedirect(createPaymentResult.redirectPaymentUrl)
}

def payPlugNotify() {

    // first verify this is valid from PayPlug
    String responseString = EntityUtils.toString(response.getEntity())
    Map convertedMap = new ObjectMapper().readValue(responseString, Map.class)

    if (convertedMap.id && convertedMap.object == 'payment') {
        GenericValue firstGatewayResp = from("PaymentGatewayResponse")
                .where(paymentMethodTypeId: "EXT_PAYPLUG",
                        paymentServiceTypeEnumId: "PRDS_PAY_EXTERNAL",
                        referenceNum: convertedMap.id)
                .queryFirst()

        //of waiting response
        if (firstGatewayResp) {
            GenericValue orderPaymentPref = from("OrderPaymentPreference")
                    .where(orderPaymentPreferenceId: firstGatewayResp.orderPaymentPreferenceId)
                    .queryOne()

            String paymentStatus
            String paymentStatusMessage
            String paymentFlag
            if (firstGatewayResp.referenceNum == convertedMap.id) {
                if (convertedMap.is_paid) {
                    paymentStatus = "Paid"
                    paymentFlag = 'P'
                } else if (convertedMap.failure) {
                    paymentStatus = convertedMap.failure.aborted
                    paymentStatusMessage = convertedMap.failure.message
                    paymentFlag = 'F'
                }
            } else {
                //payment not matching
                paymentStatus = "Not_Match"
                paymentFlag = 'F'
                paymentStatusMessage = "Attendeed ${firstGatewayResp.referenceNum}, received ${convertedMap.id}"
            }
            BigDecimal amount = new BigDecimal(convertedMap.amount)
            amount = amount.movePointLeft(2)
            try {
                TransactionUtil.begin()
                GenericValue paymentGatewayResponse = makeValue("PaymentGatewayResponse", [
                        paymentGatewayResponseId: delegator.getNextSeqId("PaymentGatewayResponse"),
                        orderPaymentPreferenceId: orderPaymentPref.orderPaymentPreferenceId,
                        amount                  : amount,
                        paymentMethodTypeId     : "EXT_PAYPLUG",
                        paymentServiceTypeEnumId: "PRDS_PAY_EXTERNAL",
                        currencyUomId           : convertedMap.currency,
                        referenceNum            : convertedMap.id,
                        subReference            : StringUtil.replaceString(convertedMap.id, 'pay_', ''),
                        gatewayCode             : paymentStatus,
                        gatewayFlag             : paymentFlag,
                        gatewayMessage          : paymentStatusMessage,
                        transactionDate         : UtilDateTime.nowTimestamp()])
                paymentGatewayResponse.create()
                TransactionUtil.commit()

                TransactionUtil.begin()
                GenericValue userLogin = from("UserLogin").where(userLoginId: 'system').cache().queryOne()
                if ('P' == paymentFlag) {
                    OrderChangeHelper.approveOrder(dispatcher, userLogin, orderPaymentPref.orderId)
                    orderPaymentPref.statusId = 'PAYMENT_RECEIVED'
                    orderPaymentPref.store()

                    String comments = UtilProperties.getMessage("PayPlugUiLabels", "PayPlugPaymentReceiveViaPayPlug", locale)
                    if (convertedMap.card) {
                        Map card = convertedMap.cart
                        comments += " xxx ${card.last4} - ${card.exp_month}:${card.exp_year} - ${card.brand}" as String
                    }

                    results = run service: "createPaymentFromPreference", with: [orderPaymentPreferenceId: orderPaymentPref.orderPaymentPreferenceId,
                                                                                 comments                : comments]
                } else {
                    orderPaymentPref.statusId = 'PAYMENT_DECLINED'
                    orderPaymentPref.store()
                }
                TransactionUtil.commit()
            } catch (Exception e) {
                TransactionUtil.rollback()
            }
        }
    }
    return success()
}