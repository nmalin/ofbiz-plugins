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

import org.apache.ofbiz.base.util.UtilHttp
import org.apache.ofbiz.base.util.UtilMisc
import org.apache.ofbiz.service.ServiceUtil


def callPayPlug() {
    String orderId = context.orderId ?: parameters.orderId
    Map createPaymentResult = run service: 'payplugCreatePaymentForOrder', with: [orderId: orderId]
    if (ServiceUtil.isError(createPaymentResult)) {
        return error(ServiceUtil.getErrorMessage(createPaymentResult))
    }

    // payment init created on payPlug server, store the reference and redirect the browser
    response.sendRedirect(createPaymentResult.redirectPaymentUrl)
}

def payPlugNotify() {

    // first verify this is valid from PayPlug
    Map<String, Object> parametersMap = UtilHttp.getParameterMap(request)
    logError(UtilMisc.printMap(parametersMap))

}