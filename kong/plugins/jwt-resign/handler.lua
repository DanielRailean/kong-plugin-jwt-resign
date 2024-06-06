local kong = kong
-- https://github.com/cdbattags/lua-resty-jwt
local jwt = require("resty.jwt")

local jwt_resign = {
  -- same default priority as openid-connect (enterprise)
  -- https://docs.konghq.com/gateway/3.4.x/plugin-development/custom-logic/#plugins-execution-order
  PRIORITY = tonumber(os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN")) or 1000,
  VERSION = "1.0.0",
}

function jwt_resign:access(conf)
  local opts = {
    -- The discovery endpoint of the OP. Enable to get the URI of all endpoints (Token, introspection, logout...)
    discovery = conf.discovery_url,
    auth_accept_token_as = "header",
    auth_accept_token_as_header_name = conf.header_name,
  }
  local jwt_token = jwt:sign(
                    "lua-resty-jwt",
                    {
                        header={typ="JWT", alg="HS256"},
                        payload={foo="bar"}
                    }
                )
  -- call authenticate for OpenID Connect user authentication
  -- local res, err = oidc.bearer_jwt_verify(opts)
  -- if err then
  --   kong.response.exit(401)
  -- end
    kong.response.exit(200, {jwt = jwt_token})
end

return jwt_resign
