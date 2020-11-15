import org.apache.ofbiz.webapp.control.JWTManager
if (parameters.queryToken) {
    Map claims = JWTManager.validateToken(parameters.queryToken, JWTManager.getJWTKey(delegator))
    context << claims
    context.parameters << claims
}