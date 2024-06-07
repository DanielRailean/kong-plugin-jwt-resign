local kong = kong
-- https://github.com/cdbattags/lua-resty-jwt
local jwt = require("resty.jwt")
-- https://github.com/fffonion/lua-resty-openssl
local pkey = require("resty.openssl.pkey")
local json = require("cjson")

local jwt_resign = {
  -- same default priority as openid-connect (enterprise)
  -- https://docs.konghq.com/gateway/3.4.x/plugin-development/custom-logic/#plugins-execution-order
  PRIORITY = tonumber(os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN")) or 1000,
  VERSION = "1.0.0",
}

local secret = os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN_PEM_PRIVATE")
local key = pkey.new(secret)
local jwk_str, _ = key:tostring("PublicKey", "JWK")
local jwk = json.decode(jwk_str)
jwk["use"] = "sig"

function jwt_resign:access(conf)
  jwk["alg"] = conf.resign_algorithm
  if conf.return_discovery_keys then
    kong.response.exit(200, {keys = {jwk}})
  end

  local payload = {}

  local headers = kong.request.get_headers()
  local bearer = headers[conf.header_name]

  local words = {}
  for w in bearer:gmatch("%S+") do
    table.insert(words, w)
  end

  local jwt_obj = jwt:load_jwt(words[2])

  payload = jwt_obj.payload

  if conf.override_claims then
    for k, v in pairs(conf.override_claims) do payload[k] = v end
  end

  local jwt_token = jwt:sign(
    secret,
    {
      header = { typ = "JWT", alg = conf.resign_algorithm, kid = conf.header_key_id or jwk.kid },
      payload = payload
    }
  )
  kong.service.request.set_headers({
    [conf.resigned_header_name] = "Bearer " .. jwt_token
  })
end

return jwt_resign
