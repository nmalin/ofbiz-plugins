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

import org.apache.ofbiz.base.util.StringUtil
import org.apache.ofbiz.base.util.UtilDateTime
import org.apache.ofbiz.base.util.UtilHttp
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
    if (request.getMethod() != 'POST') {
        return error("Receive unlogical request")
    }

    //extract request content
    Map requestAttrs = UtilHttp.getAttributeMap(request)

    //analyse
    if (requestAttrs.id && requestAttrs.object == 'payment') {
        GenericValue firstGatewayResp = from("PaymentGatewayResponse")
                .where(paymentMethodTypeId: "EXT_PAYPLUG",
                        paymentServiceTypeEnumId: "PRDS_PAY_EXTERNAL",
                        referenceNum: requestAttrs.id)
                .queryFirst()

        //of waiting response
        if (firstGatewayResp) {
            GenericValue orderPaymentPref = from("OrderPaymentPreference")
                    .where(orderPaymentPreferenceId: firstGatewayResp.orderPaymentPreferenceId)
                    .queryOne()

            String paymentStatus
            String paymentStatusMessage
            String paymentFlag
            if (firstGatewayResp.referenceNum == requestAttrs.id) {
                if (requestAttrs.is_paid) {
                    paymentStatus = "Paid"
                    paymentFlag = 'P'
                } else if (requestAttrs.failure) {
                    paymentStatus = requestAttrs.failure.aborted
                    paymentStatusMessage = requestAttrs.failure.message
                    paymentFlag = 'F'
                }
            } else {
                //payment not matching
                paymentStatus = "Not_Match"
                paymentFlag = 'F'
                paymentStatusMessage = "Attendeed ${firstGatewayResp.referenceNum}, received ${requestAttrs.id}"
            }
            BigDecimal amount = new BigDecimal(requestAttrs.amount)
            amount = amount.movePointLeft(2)
            try {
                TransactionUtil.begin()
                GenericValue paymentGatewayResponse = makeValue("PaymentGatewayResponse", [
                        paymentGatewayResponseId: delegator.getNextSeqId("PaymentGatewayResponse"),
                        orderPaymentPreferenceId: orderPaymentPref.orderPaymentPreferenceId,
                        amount                  : amount,
                        paymentMethodTypeId     : "EXT_PAYPLUG",
                        paymentServiceTypeEnumId: "PRDS_PAY_EXTERNAL",
                        currencyUomId           : requestAttrs.currency,
                        referenceNum            : requestAttrs.id,
                        subReference            : StringUtil.replaceString(requestAttrs.id, 'pay_', ''),
                        gatewayCode             : paymentStatus,
                        gatewayFlag             : paymentFlag,
                        gatewayMessage          : paymentStatusMessage,
                        transactionDate         : UtilDateTime.nowTimestamp()])
                paymentGatewayResponse.create()
                TransactionUtil.commit()

                TransactionUtil.begin()
                GenericValue userLoginSystem = from("UserLogin").where(userLoginId: 'system').cache().queryOne()
                if ('P' == paymentFlag) {
                    OrderChangeHelper.approveOrder(dispatcher, userLoginSystem, orderPaymentPref.orderId)
                    orderPaymentPref.statusId = 'PAYMENT_RECEIVED'
                    orderPaymentPref.store()

                    String comments = UtilProperties.getMessage("PayPlugUiLabels", "PayPlugPaymentReceivedViaPayPlug", locale)
                    if (requestAttrs.card) {
                        Map card = requestAttrs.card
                        comments += " xxx ${card.last4} - ${card.exp_month}:${card.exp_year} - ${card.brand}" as String
                    }

                    results = run service: "createPaymentFromPreference", with: [userLogin: userLoginSystem,
                                                                                 comments: comments,
                                                                                 paymentRefNum: requestAttrs.id,
                                                                                 orderPaymentPreferenceId: orderPaymentPref.orderPaymentPreferenceId]
                } else {
                    orderPaymentPref.statusId = 'PAYMENT_DECLINED'
                    orderPaymentPref.store()
                }
                TransactionUtil.commit()
            } catch (Exception e) {
                logError("""Failed to load the payment pref : ${firstGatewayResp.orderPaymentPreferenceId}
                         for payplug payment: ${requestAttrs.id},
                         due to ${e.toString()}""")
                TransactionUtil.rollback()
            }
        }
    }
    return success()
}