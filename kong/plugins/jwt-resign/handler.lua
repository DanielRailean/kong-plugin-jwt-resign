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


local keys = {
}

local function read_key_from_env(key)
  local is = keys[key]
  if is == "err" then
    return nil
  end
  if is == nil then
    local secret = os.getenv(key)
    local pkey_priv, err = pkey.new(secret)
    if err ~= nil then
      keys[key] = "err"
      return nil
    end
    local jwk_str, err = pkey_priv:tostring("PublicKey", "JWK")

    if err ~= nil then
      keys[key] = "err"
      return nil
    end

    local jwk = json.decode(jwk_str)

    keys[key] = {
      public_jwk = jwk,
      private_key = pkey_priv,
      secret_pem = secret
    }
    return keys[key]
  end
end

function jwt_resign:access(conf)
  local key = read_key_from_env(conf.private_key_pem_env_name)
  if key == nil then
    kong.response.exit(500, { message = "Cannot fetch the key!" })
  end

  local headers = kong.request.get_headers()
  local bearer = headers[conf.header_name]

  local words = {}
  for w in bearer:gmatch("%S+") do
    table.insert(words, w)
  end

  local jwt_obj = jwt:load_jwt(words[2])

  local payload = {

  }
  payload = jwt_obj.payload

  if conf.override_claims then
    for k, v in pairs(conf.override_claims) do payload[k] = v end
  end

  local jwt_token = jwt:sign(
    key.secret_pem,
    {
      header = { typ = "JWT", alg = "RS256", kid = key.public_jwk.kid },
      payload = payload
    }
  )
  kong.service.request.set_headers({
    [conf.resigned_header_name] = "Bearer " .. jwt_token
  })
end

return jwt_resign
