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
<#--
<#macro displayInform message>
    <div class="text-primary-400 flex my-10 font-bold"><i data-feather="message-circle" class="mr-3"></i>${message}</div>
</#macro>
<#macro displayAlert message>
    <div class="text-red-400 flex my-10 font-bold"><i data-feather="alert-circle" class="mr-3"></i>${message}</div>
</#macro>
<#macro displayAvailable message>
    <div class="text-green-400 flex my-10 font-bold"><i data-feather="check-circle" class="mr-3"></i>${message}</div>
</#macro>
-->
<#assign productUrl><@ofbizCatalogAltUrl productId=product.productId productCategoryId=categoryId/></#assign>
    <#if product??>

    <#-- breadcrum-->
        <#if breadcrums??>
            <div class="container px-4">
                <ol class="breadcrumb product-detail">
                    <li><a href="<@ofbizUrl>main</@ofbizUrl>">${uiLabelMap.ContentMain}</a></li>
                    <#list breadcrums as productCategory><li <#if !productCategory_has_next>class="active"</#if>>
                        <a href="<@ofbizCatalogAltUrl productCategoryId=productCategory.productCategoryId/>">${productCategory.categoryName!}</a></li></#list>
                </ol>
            </div>
        </#if>
    <section class="container md:grid grid-cols-2 gap-12 py-5 px-4">
        <div>
            <div>
                <a href="<@ofbizContentUrl>${detailImageUrl!}</@ofbizContentUrl>" data-lightbox="product" class="w-full block">
                    <img src="<@ofbizContentUrl>${largeImageUrl!}</@ofbizContentUrl>" alt="${product.internalName}" class="w-full">
                </a>
            </div>
            <div class="grid grid-cols-3 gap-x-4 gap-y-2 mt-4">
                <#list 1..4 as i>
                    <#assign extraImageDetailUrl = productContentWrapper.get('XTRA_IMG_' + i + '_DETAIL', 'url')!/>
                    <#if extraImageDetailUrl?string?? && extraImageDetailUrl?string != "">
                        <a href="<@ofbizContentUrl>${extraImageDetailUrl}</@ofbizContentUrl>" data-lightbox="product" class="text-center"><img src="<@ofbizContentUrl>${productContentWrapper.get('XTRA_IMG_' + i + '_MEDIUM', 'url')}</@ofbizContentUrl>" alt=""></a>
                    </#if>
                </#list>
            </div>
        </div>
        <div class="product-info">
            <h1 class="mb-2">${productContentWrapper.get("PRODUCT_NAME", "html")!}</h1> 
            <p class='text-lg font-bold text-neutral-700'>${currencyPrice!}</p>

            <#-- example of showing a certain type of feature with the product -->
            <#if sizeProductFeatureAndAppls?has_content>
                <div>
                <#if (sizeProductFeatureAndAppls?size > 1)>
                    ${uiLabelMap.OrderSizeAvailableMultiple}:
                </#if>
                    <div class="border-0 border-t border-b border-neutral-400 py-2 text-primary-400 my-4">
                    <#list sizeProductFeatureAndAppls as sizeProductFeatureAndAppl>
                        ${sizeProductFeatureAndAppl.abbrev?default(sizeProductFeatureAndAppl.description?default(sizeProductFeatureAndAppl.productFeatureId))}<#if sizeProductFeatureAndAppl_has_next>, </#if>
                    </#list>
                    </div>
                </div>
            </#if>

            <p class="mt-6 mb-2 text-neutral-700 mb-8">${productContentWrapper.get("DESCRIPTION", "html")!}</p>

            <div class="productbuy">
            <#-- check to see if introductionDate hasn't passed yet ->
            <#if product.introductionDate?? && nowTimestamp.before(product.introductionDate) && totalAvailableToPromise <= 0>
                <@displayAlert uiLabelMap.ProductNotYetAvailable/>
            <#- check to see if salesDiscontinuationDate has passed ->
            <#elseif product.salesDiscontinuationDate?? && nowTimestamp.after(product.salesDiscontinuationDate)>
                <@displayAlert uiLabelMap.ProductNoLongerAvailable/>
            <#elseif totalAvailableToPromise?? && totalAvailableToPromise <= 0>
                <@displayAlert uiLabelMap.ProductItemOutOfStock/>
            <#else >
                <#if product.releaseDate?? && nowTimestamp.before(product.releaseDate)>
                    <@displayInform uiLabelMap.EcommerceProductionWipStart + product.releaseDate?date + uiLabelMap.EcommerceProductionWipEnd/>
                </#if>
                <form method="post" action="<@ofbizUrl>additem</@ofbizUrl>" name="theform">
                    <@displayAvailable uiLabelMap.EcommerceAvailable + " " + totalAvailableToPromise?number/>
                    <div class="form-group">
                        <input type="hidden" name="add_product_id" value="${product.productId}"/>
                        <input type="hidden" name="clearSearch" value="N"/>
                        <input type="hidden" name="mainSubmitted" value="Y"/>
                        <div class="input-group max-w-xs grid grid-cols-3 gap-4">
                            <input type="number" name="quantity" value="1" min="1" class="input-text"/>
                            <a href="javascript:document.theform.submit()" class="btn btn-neutral col-span-2">${uiLabelMap.OrderAddToCart}</a>
                        </div>
                    </div>
                </form>
            </#if>-->
                <#assign switch = {"CH_ORCHIDEE": "1", "CH_EPI": "2", "CH_CHENE": "3"}/>
                <script type="text/javascript" src="//gadget.open-system.fr/widgets-libs/rel/noyau-1.0.min.js"></script>
                <script type="text/javascript">
                    ( function() {
                        var widgetProduit = AllianceReseaux.Widget.Instance( "Produit", { idPanier:"U3RSU1M", idIntegration:646, langue:"fr", ui:"OSCH-72080-${switch[product.productId]}" } );
                        widgetProduit.Initialise();
                    })();
                </script>
                <div id="widget-produit-OSCH-72080-${switch[product.productId]}"></div>
            </div>
        </div>

    </section>

    <section class="container pb-10 md:py-20 px-6" id="more-descr">
        <div class="tabs">
            <ul>
                <li class="tab-link current" data-tab="description-product">${uiLabelMap.CommonDescription}</li>
                <#if prodCatMem?? && prodCatMem.comments?has_content>
                <li class="tab-link" data-tab="comments-product">${uiLabelMap.CommonComments} </li>
                </#if>
            </ul>
        </div>
        <div id="description-product" class="tab-content current">
            <p id="long-desc" class="mt-6 mb-2 text-neutral-700">${productContentWrapper.get("LONG_DESCRIPTION", "html")!}</p>
        </div>
        <#if prodCatMem?? && prodCatMem.comments?has_content>
        <div id="comments-product" class="tab-content">
            <p>${prodCatMem.comments}</p>
        </div>
        </#if>

    </section>

    <#if relatedContentIds?? && (relatedContentIds?size > 0)>
    <section class="container pb-20 px-4 text-center" id="related-contents">
        <h2 class="mb-6">${uiLabelMap.EcommerceArticleTalkAbout}</h2>
        <ul class="md:flex items-center justify-center gap-8">
        <#list relatedContentIds as articleContentId>
            <@ofbizScreen>BlogSummary</@ofbizScreen>
        </#list>
        </ul>
    </section>
    </#if>

    <#else>
    <section class="container text-center py-20">
        <h2>${uiLabelMap.ProductErrorProductNotFound}</h2>
    </section>
    </#if>
