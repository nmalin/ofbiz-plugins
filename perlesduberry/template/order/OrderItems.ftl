<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<#-- NOTE: this template is used for the orderstatus screen in ecommerce AND for order notification emails through the OrderNoticeEmail.ftl file -->
<#-- the "urlPrefix" value will be prepended to URLs by the ofbizUrl transform if/when there is no "request" object in the context -->
<#if baseEcommerceSecureUrl??><#assign urlPrefix = baseEcommerceSecureUrl/></#if>
<div class="card">
  <div class="card-header">
    <strong>
    <#assign numColumns = 7>
    ${uiLabelMap.OrderOrderItems}
    </strong>
  </div>
  <div class="card-body">
  <table class="table table-responsive-sm">
    <thead class="thead-light">
      <tr>
        <th>${uiLabelMap.OrderProduct}</th>
        <th>${uiLabelMap.OrderQtyOrdered}</th>
        <th class="amount">${uiLabelMap.EcommerceUnitPrice}</th>
        <th class="amount">${uiLabelMap.OrderSalesTax}</th>
        <th class="amount">${uiLabelMap.CommonSubtotal}</th>
      </tr>
    </thead>
    <tfoot>
      <tr>
        <#assign orderTaxTotal = localOrderReadHelper.getTaxTotal()>
        <th colspan="3">${uiLabelMap.CommonSubtotal}</th>
        <td class="amount"><@ofbizCurrency amount=orderTaxTotal isoCode=currencyUomId/></td>
        <#assign orderSubTotalWithTax = orderSubTotal + orderTaxTotal>
        <td class="amount"><@ofbizCurrency amount=orderSubTotalWithTax isoCode=currencyUomId/></td>
      </tr>
      <tr>
        <th colspan="4">${uiLabelMap.OrderShippingAndHandling}</th>
        <td class="amount"><@ofbizCurrency amount=orderShippingTotal isoCode=currencyUomId/></td>
      </tr>
      <tr>
      <tr>
        <th colspan="4">${uiLabelMap.OrderGrandTotal}</th>
        <td class="amount">
          <@ofbizCurrency amount=orderGrandTotal isoCode=currencyUomId/>
        </td>
      </tr>
    </tfoot>
    <tbody>
      <#list orderItems as orderItem>
        <tr>
            <#assign product = orderItem.getRelatedOne("Product", true)!/> <#-- should always exist because of FK constraint, but just in case -->
            <td>
              ${orderItem.productId}
            </td>
            <td>
              ${orderItem.quantity?string.number}
            </td>
            <td class="amount">
              <@ofbizCurrency amount=orderItem.unitPrice isoCode=currencyUomId/>
            </td>
            <td class="amount">
              <@ofbizCurrency amount=localOrderReadHelper.getOrderItemTax(orderItem) isoCode=currencyUomId/>
            </td>
            <td class="amount">
                <@ofbizCurrency amount=localOrderReadHelper.getOrderItemTotal(orderItem) isoCode=currencyUomId/>
            </td>
        </tr>
        <#-- show the order item ship group info
        <#assign orderItemShipGroupAssocs = orderItem.getRelated("OrderItemShipGroupAssoc", null, null, false)!>
        <#if orderItemShipGroupAssocs?has_content>
          <#list orderItemShipGroupAssocs as shipGroupAssoc>
            <#assign shipGroup = shipGroupAssoc.getRelatedOne("OrderItemShipGroup", false)!>
            <#assign shipGroupAddress = (shipGroup.getRelatedOne("PostalAddress", false))!>
            <tr>
              <td>
              ${uiLabelMap.OrderShipGroup}: [${shipGroup.shipGroupSeqId}] ${shipGroupAddress.address1?default("N/A")}
              </td>
              <td>
              ${shipGroupAssoc.quantity?string.number}
              </td>
              <td colspan="${numColumns - 2}"></td>
            </tr>
          </#list>
        </#if>-->
      </#list>
    </tbody>
  </table>
     </div>
</div>