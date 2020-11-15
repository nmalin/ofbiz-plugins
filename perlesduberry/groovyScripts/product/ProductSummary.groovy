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

import org.apache.ofbiz.product.product.ProductContentWrapper

// make the productContentWrapper
ProductContentWrapper productContentWrapper = new ProductContentWrapper(dispatcher, product, locale, "text/html; charset=utf-8")
context.productContentWrapper = productContentWrapper

context.imageUrl = productContentWrapper.get("SMALL_IMAGE_URL", "url") ?: "/images/defaultImage.jpg"

String productName = productContentWrapper.get("PRODUCT_NAME", "html") ?: product.brandName
context.productName = productName ?: product.internalName
