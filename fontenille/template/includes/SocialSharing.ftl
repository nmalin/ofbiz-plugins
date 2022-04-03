
<section class="w-full p-4 md:py-10 text-center bg-green-200 bg-opacity-25">
    <div class="container text-center">
        <h4>Les Avis</h4>
        <p class="my-4 md:mb-20 text-lg"></p>
        <ul class="md:grid grid-cols-2 gap-8 text-left">
            <li class="grid grid-cols-1 md:pr-6 lg-pr-20 border-0 md:border-r my-10 md:my-3 gap-4">
                <div id="TA_selfserveprop918" class="TA_selfserveprop">
                    <ul id="bXWvGXXVI7" class="TA_links WQUy80G"><li id="W2H6dKl7U3B" class="M3RgZQk">
                            <a target="_blank" href="https://www.tripadvisor.fr/Hotel_Review-g2569753-d2522577-Reviews-Chambres_d_hotes_de_La_Fontenille-Lapan_Cher_Berry_Centre_Val_de_Loire.html">
                                <img src="https://www.tripadvisor.fr/img/cdsi/img2/branding/v2/Tripadvisor_lockup_horizontal_secondary_registered-11900-2.svg" alt="TripAdvisor"/>
                            </a>
                        </li>
                    </ul>
                </div>
                <script async src="https://www.jscache.com/wejs?wtype=selfserveprop&amp;uniq=918&amp;locationId=2522577&amp;lang=fr&amp;rating=true&amp;nreviews=4&amp;writereviewlink=false&amp;popIdx=false&amp;iswide=true&amp;border=true&amp;display_version=2" data-loadtrk onload="this.loadtrk=true"></script>
            </li>
            <li class="grid grid-cols-1 md:pr-6 lg-pr-20 border-0 md:border-r my-10 md:my-3 gap-4">
                <div class="cybevasion-widgetAvisGen-27946_2"></div>
                <script src="https://www.cybevasion.fr/adherents/jsavis_widget_v2_27946_2_fr.js?utf" type="text/javascript"></script>
            </li>
        </ul>
    </div>
</section>
<section class="w-full p-4 md:py-10 text-center bg-orange-200 bg-opacity-25">
    <div class="container text-center">
        <h4>Gallerie</h4>
        <a href="https://www2.lafontenille.fr:443/Gallery">
            <img src="https://www2.lafontenille.fr:443/img?imgId=10003" alt="">
        </a>
        <a href="https://www2.lafontenille.fr:443/Gallery" class="btn btn-white animated animate__fadeInUp">Nos Photos</a>
    </div>
</section>
<section class="w-full p-4 md:py-10 text-center bg-green-200 bg-opacity-25">
    <div class="container text-center">
        <h4>Réserver en ligne</h4>
        <p class="my-4 md:mb-20 text-lg"></p>
        <ul class="md:grid grid-cols-3 gap-8 text-center">
            <#assign switch = {"CH_ORCHIDEE": "1", "CH_EPI": "2", "CH_CHENE": "3"}/>
            <#assign chambres = ["CH_ORCHIDEE", "CH_EPI", "CH_CHENE"]/>
            <#list chambres as chambre>
            <#assign product = delegator.findOne("Product", true, "productId", chambre)/>
            <#assign productUrl><@ofbizCatalogAltUrl productId=product.productId/></#assign>
            <li class="grid grid-cols-1 md:pr-6 lg-pr-20 border-0 md:border-r my-10 md:my-3 gap-4">
                <a href="${productUrl}" class="">${product.internalName}</a>
                <script type="text/javascript" src="//gadget.open-system.fr/widgets-libs/rel/noyau-1.0.min.js"></script>
                <script type="text/javascript">
                    ( function() {
                        var widgetProduit = AllianceReseaux.Widget.Instance( "Produit", { idPanier:"U3RSU1M", idIntegration:646, langue:"fr", ui:"OSCH-72080-${switch[chambre]}" } );
                        widgetProduit.Initialise();
                    })();
                </script>
                <div id="widget-produit-OSCH-72080-${switch[chambre]}"></div>
                </#list>
            </li>
        </ul>
    </div>
</section>