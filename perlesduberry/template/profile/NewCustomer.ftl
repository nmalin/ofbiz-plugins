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

<#if getUsername>
  <script type="application/javascript">
    //<![CDATA[
    lastFocusedName = null;
    function setLastFocused(formElement) {
      lastFocusedName = formElement.name;
    }
    function clickUsername() {
      if (document.getElementById('UNUSEEMAIL').checked) {
        if ("UNUSEEMAIL" == lastFocusedName) {
          jQuery('#PASSWORD').focus();
        } else if ("PASSWORD" == lastFocusedName) {
          jQuery('#UNUSEEMAIL').focus();
        } else {
          jQuery('#PASSWORD').focus();
        }
      }
    }
    function changeEmail() {
      if (document.getElementById('UNUSEEMAIL').checked) {
        document.getElementById('USERNAME').value = jQuery('#CUSTOMER_EMAIL').val();
      }
    }
    function setEmailUsername() {
      if (document.getElementById('UNUSEEMAIL').checked) {
        document.getElementById('USERNAME').value = jQuery('#CUSTOMER_EMAIL').val();
        // don't disable, make the browser not submit the field: document.getElementById('USERNAME').disabled=true;
      } else {
        document.getElementById('USERNAME').value = '';
        // document.getElementById('USERNAME').disabled=false;
      }
    }
    function hideShowUsaStates() {
      var customerStateElement = document.getElementById('newuserform_stateProvinceGeoId');
      var customerCountryElement = document.getElementById('newuserform_countryGeoId');
      if ("USA" == customerCountryElement.value || "UMI" == customerCountryElement.value) {
        customerStateElement.style.display = "block";
      } else {
        customerStateElement.style.display = "none";
      }
    }
    //]]>
  </script>
</#if>

<#------------------------------------------------------------------------------
NOTE: all page headings should start with an h2 tag, not an H1 tag, as
there should generally always only be one h1 tag on the page and that
will generally always be reserved for the logo at the top of the page.
------------------------------------------------------------------------------->
<div class="d-flex justify-content-center">
  <h2>${uiLabelMap.PartyRequestNewAccount}</h2>
</div>
<div class="d-flex justify-content-center">
  <h3>
    ${uiLabelMap.PartyAlreadyHaveAccount},
    <a href='<@ofbizUrl>checkLogin/main</@ofbizUrl>'>${uiLabelMap.CommonLoginHere}</a>
  </h3>
</div>

<#macro fieldErrors fieldName>
  <#if errorMessageList?has_content>
    <#assign fieldMessages =
    Static["org.apache.ofbiz.base.util.MessageString"].getMessagesForField(fieldName, true, errorMessageList)>
    <ul>
      <#list fieldMessages as errorMsg>
        <li class="errorMessage">${errorMsg}</li>
      </#list>
    </ul>
  </#if>
</#macro>
<#macro fieldErrorsMulti fieldName1 fieldName2 fieldName3 fieldName4>
  <#if errorMessageList?has_content>
    <#assign fieldMessages =
    Static["org.apache.ofbiz.base.util.MessageString"].getMessagesForField(fieldName1, fieldName2,
    fieldName3, fieldName4, true, errorMessageList)>
    <ul>
      <#list fieldMessages as errorMsg>
        <li class="errorMessage">${errorMsg}</li>
      </#list>
    </ul>
  </#if>
</#macro>
<div class="d-flex justify-content-center">
  <a href="<@ofbizUrl>${donePage}</@ofbizUrl>" class="btn btn-outline-secondary btn-sm">${uiLabelMap.CommonCancel}</a>&nbsp;
  <a href="javascript:document.getElementById('newuserform').submit()" class="btn btn-outline-secondary btn-sm">${uiLabelMap.CommonSave}</a>
</div>
<div class="d-flex justify-content-center">
  <div class="card p-2 m-3">

    <form method="post" action="<@ofbizUrl>createcustomer${previousParams}</@ofbizUrl>" id="newuserform" name="newuserform">

      <div class="card-block">
        ${uiLabelMap.CommonFieldsMarkedAreRequired}
      </div>

      <div class="row">
        <div class="col-6">
          <input type="checkbox" name="UNUSEEMAIL" style="display: none" id="UNUSEEMAIL" value="on" checked="true"/>
          <input type="text" name="USERNAME" style="display: none" id="USERNAME"/>
          <fieldset>
            <legend>${uiLabelMap.CommonUsername}</legend>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_EMAIL">${uiLabelMap.PartyEmailAddress} *</label>
                <@fieldErrors fieldName="CUSTOMER_EMAIL"/>
                <input type="text" name="CUSTOMER_EMAIL" id="CUSTOMER_EMAIL" value="${requestParameters.CUSTOMER_EMAIL!}"
                       class="form-control form-control-sm" onchange="changeEmail()" onkeyup="changeEmail()"/>
              </div>
            </div>
          </fieldset>
        </div>
        <div class="col-6">
          <fieldset>
            <legend>${uiLabelMap.CommonPassword}</legend>
            <div class="row form-group">
              <div class="col-12">
                <label for="PASSWORD">${uiLabelMap.CommonPassword} *</label>
                <@fieldErrors fieldName="PASSWORD"/>
                <input type="password" name="PASSWORD" class="form-control form-control-sm" autocomplete="off" id="PASSWORD" onfocus="setLastFocused(this);"/>
              </div>
            </div>

            <div class="row form-group">
              <div class="col-12">
                <label for="CONFIRM_PASSWORD">${uiLabelMap.PartyRepeatPassword} *</label>
                <@fieldErrors fieldName="CONFIRM_PASSWORD"/>
                <input type="password" class="form-control form-control-sm" name="CONFIRM_PASSWORD" id="CONFIRM_PASSWORD" autocomplete="off" value="" maxlength="50"/>
              </div>
            </div>

            <div class="row form-group">
              <div class="col-12">
                <label for="PASSWORD_HINT">${uiLabelMap.PartyPasswordHint}</label>
                <@fieldErrors fieldName="PASSWORD_HINT"/>
                <input type="text" class="form-control form-control-sm" name="PASSWORD_HINT" id="PASSWORD_HINT"
                       value="${requestParameters.PASSWORD_HINT!}" maxlength="100"/>
              </div>
            </div>
          </fieldset>
        </div>
        <div class="col-6">
          <hr/>
          <fieldset>
            <legend>${uiLabelMap.PartyFullName}</legend>
            <input type="hidden" name="emailProductStoreId" value="${productStoreId}"/>
            <div class="row form-group">
              <div class="col-12">
                <label for="USER_TITLE">${uiLabelMap.CommonTitle}</label>
                <@fieldErrors fieldName="USER_TITLE"/>
                <select name="USER_TITLE" class="form-control form-control-sm">
                  <#if requestParameters.USER_TITLE?has_content >
                    <option>${requestParameters.USER_TITLE}</option>
                    <option value="${requestParameters.USER_TITLE}"> --</option>
                  <#else>
                    <option value="">${uiLabelMap.CommonSelectOne}</option>
                  </#if>
                  <option>${uiLabelMap.CommonTitleMr}</option>
                  <option>${uiLabelMap.CommonTitleMrs}</option>
                  <option>${uiLabelMap.CommonTitleMs}</option>
                  <option>${uiLabelMap.CommonTitleDr}</option>
                </select>
              </div>
            </div>

            <div class="row form-group">
              <div class="col-12">
                <label for="USER_FIRST_NAME">${uiLabelMap.PartyFirstName} *</label>
                <@fieldErrors fieldName="USER_FIRST_NAME"/>
                <input type="text" name="USER_FIRST_NAME" id="USER_FIRST_NAME" value="${requestParameters.USER_FIRST_NAME!}" class="form-control form-control-sm"/>
              </div>
            </div>

            <div class="row form-group">
              <div class="col-12">
                <label for="USER_LAST_NAME">${uiLabelMap.PartyLastName} *</label>
                <@fieldErrors fieldName="USER_LAST_NAME"/>
                <input type="text" name="USER_LAST_NAME" id="USER_LAST_NAME" value="${requestParameters.USER_LAST_NAME!}" class="form-control form-control-sm"/>
              </div>
            </div>
          </fieldset>
        </div>
        <div class="col-6">
          <hr/>

          <fieldset>
            <legend>${uiLabelMap.PartyShippingAddress}</legend>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_ADDRESS1">${uiLabelMap.PartyAddressLine1} *</label>
                <@fieldErrors fieldName="CUSTOMER_ADDRESS1"/>
                <input type="text" name="CUSTOMER_ADDRESS1" id="CUSTOMER_ADDRESS1"
                       value="${requestParameters.CUSTOMER_ADDRESS1!}" class="form-control form-control-sm"/>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_ADDRESS2">${uiLabelMap.PartyAddressLine2}</label>
                <@fieldErrors fieldName="CUSTOMER_ADDRESS2"/>
                <input type="text" name="CUSTOMER_ADDRESS2" id="CUSTOMER_ADDRESS2"
                       value="${requestParameters.CUSTOMER_ADDRESS2!}" class="form-control form-control-sm"/>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_POSTAL_CODE">${uiLabelMap.PartyZipCode} *</label>
                <@fieldErrors fieldName="CUSTOMER_POSTAL_CODE"/>
                <input type="text" pattern="[0-9]{5}" name="CUSTOMER_POSTAL_CODE" id="CUSTOMER_POSTAL_CODE"
                       value="${requestParameters.CUSTOMER_POSTAL_CODE!}" class="form-control form-control-sm"/>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_CITY">${uiLabelMap.PartyCity} *</label>
                <@fieldErrors fieldName="CUSTOMER_CITY"/>
                <input type="text" name="CUSTOMER_CITY" id="CUSTOMER_CITY" value="${requestParameters.CUSTOMER_CITY!}" class="form-control form-control-sm"/>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="customerCountry">${uiLabelMap.CommonCountry}</label>
                <input name="CUSTOMER_COUNTRY" type="hidden" value="FRA"> - France
              </div>
            </div>
          </fieldset>
        </div>
      </div>
      <hr/>
        <div class="col-6">
      <fieldset> <#-- PHONES -->
        <legend>${uiLabelMap.PartyPhoneNumbers}</legend>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_MOBILE_CONTACT">Mobile</label>
                 <input type="tel" pattern="[0-9]{10}" name="CUSTOMER_MOBILE_CONTACT" class="form-control form-control-sm" value="${requestParameters.CUSTOMER_MOBILE_CONTACT!}"/></td>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_HOME_CONTACT">Domicile</label>
                 <input type="tel" pattern="[0-9]{10}" name="CUSTOMER_HOME_CONTACT" class="form-control form-control-sm" value="${requestParameters.CUSTOMER_HOME_CONTACT!}"/></td>
              </div>
            </div>
            <div class="row form-group">
              <div class="col-12">
                <label for="CUSTOMER_WORK_CONTACT">Travail</label>
                 <input type="tel" pattern="[0-9]{10}" name="CUSTOMER_WORK_CONTACT" class="form-control form-control-sm" value="${requestParameters.CUSTOMER_WORK_CONTACT!}"/></td>
              </div>
            </div>
      </fieldset>
        </div>
      <div class="col-6"></div>
  </form>
</div>
</div>

<#------------------------------------------------------------------------------
To create a consistent look and feel for all buttons, input[type=submit],
and a tags acting as submit buttons, all button actions should have a
class name of "button". No other class names should be used to style
button actions.
------------------------------------------------------------------------------->
<div class="d-flex justify-content-center">
  <a href="<@ofbizUrl>${donePage}</@ofbizUrl>" class="btn btn-outline-secondary btn-sm">${uiLabelMap.CommonCancel}</a>&nbsp;
  <a href="javascript:document.getElementById('newuserform').submit()" class="btn btn-outline-secondary btn-sm">${uiLabelMap.CommonSave}</a>
</div>
