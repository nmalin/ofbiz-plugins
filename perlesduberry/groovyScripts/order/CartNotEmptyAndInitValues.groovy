import org.apache.ofbiz.base.util.UtilProperties
import org.apache.ofbiz.entity.GenericValue
import org.apache.ofbiz.order.shoppingcart.ShoppingCart
import org.apache.ofbiz.order.shoppingcart.ShoppingCartEvents
import org.apache.ofbiz.party.contact.ContactHelper

ShoppingCart cart = ShoppingCartEvents.getCartObject(request)

if (! cart.items()) {
    return error(UtilProperties.getMessage("OrderErrorUiLabels", "checkevents.cart_empty", cart.getLocale()))
}

if (! cart.getShippingAddress()) {
    GenericValue shipToParty = from("Party").where("partyId", cart.getShipToCustomerPartyId()).cache().queryOne()
    List shippingAddresses = ContactHelper.getContactMech(shipToParty, "SHIPPING_LOCATION", "POSTAL_ADDRESS", false)
    if (shippingAddresses) {
        cart.setShippingContactMechId(0, shippingAddresses[0].contactMechId)
    }
}

return success()