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
<#assign productUrl><@ofbizCatalogAltUrl productId=product.productId productCategoryId=categoryId/></#assign>
<#assign uuid = Static["java.util.UUID"].randomUUID().toString().replaceAll('-', '_')/>
<div class="product">
    <div class="img">
        <img src="<#if largeImageUrl?string??><@ofbizContentUrl>${largeImageUrl}</@ofbizContentUrl><#else>/daphnis/images/photo-1517135399940-2855f5be7c4b.webp</#if>" alt="${uiLabelMap.CommonImage}" >
        <div class="overlay bg-primary-300">
            <div class="links text-white bg-neutral-900 hover:bg-black">
                <a href="${productUrl}" title="${uiLabelMap.CommonView}" class="hover:bg-primary-400 hover:text-black;"><i data-feather="search" class="h-6 w-6"></i></a>
            </div>
        </div>
    </div>
    <div class="info">
        <a href="${productUrl}"><h4>${productName}</h4></a>
        <p class="text-neutral-600">${productDescription!}</p>
        <span>${currencyPrice!}</span>
    </div>
</div>