import org.apache.ofbiz.entity.GenericValue
import org.apache.ofbiz.entity.condition.EntityCondition
import org.apache.ofbiz.entity.condition.EntityConditionBuilder
import org.apache.ofbiz.security.SecurityUtil
import org.apache.ofbiz.webapp.control.JWTManager

//prepare a token with parameters to save the email context
Map claims = [:]
if (context.bodyEmailContext) {
    for (String key : context.bodyEmailContext.keySet()) {
        if (context.bodyEmailContext[key] instanceof String) {
            claims[key] = context.bodyEmailContext[key]
        }
    }
}
context.queryToken = JWTManager.createJwt(delegator, claims)

//Resolve enabled userLogin from the sendTo address for generate a correct token
GenericValue userLogin
if (sendEmailServiceContext && sendEmailServiceContext.sendTo) {
    userLogin = from("UserLogin").where("userLoginId", sendEmailServiceContext.sendTo, "enabled", "Y").cache().queryFirst()
    if (!userLogin) {
        List partyIds = from("PartyAndContactMech")
                .where("infoString", sendEmailServiceContext.sendTo)
                .cache()
                .filterByDate()
                .getFieldList("partyId")
        if (partyIds) {
            EntityCondition condition = new EntityConditionBuilder().AND() {
                IN(partyId: partyIds)
                EQUALS(enabled: 'Y')
            }
            List userLogins = from("UserLogin").where(condition).cache().queryList()
            if (userLogins && userLogins.size() == 1) {
                userLogin = userLogins[0]
            }
        }
    }
}
if (userLogin) {
    context.token = SecurityUtil.generateJwtToAuthenticateUserLogin(delegator, userLogin.userLoginId)
}

