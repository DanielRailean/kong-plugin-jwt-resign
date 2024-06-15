local kong = kong
-- https://github.com/cdbattags/lua-resty-jwt
local jwt = require("resty.jwt")
-- https://github.com/fffonion/lua-resty-openssl
local pkey = require("resty.openssl.pkey")
local json = require("cjson")
local util = require("kong.plugins.jwt-resign.util")

local jwt_resign = {
  -- same default priority as jwt-signer (enterprise)
  -- https://docs.konghq.com/gateway/3.4.x/plugin-development/custom-logic/#plugins-execution-order
  PRIORITY = tonumber(os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN")) or 1020,
  DBLESS = (os.getenv("KONG_PLUGIN_JWT_RESIGN_DBLESS")) or false,
  VERSION = "1.0.0",
}

local env_public_jwk
local env_private_pem

if jwt_resign.DBLESS then
  env_private_pem = os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN_PEM_PRIVATE")
  -- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeynew
  local key = pkey.new(env_private_pem)
  -- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeytostring
  local jwk_str, _ = key:tostring("PublicKey", "JWK")
  env_public_jwk = json.decode(jwk_str)
  env_public_jwk["use"] = "sig"
end


function jwt_resign:access(conf)
  if jwt_resign.DBLESS then
    env_public_jwk["alg"] = conf.resign_algorithm
  end

  if conf.return_discovery_keys then
    kong.response.exit(200, { keys = { env_public_jwk } })
  end

  if conf.resign_keyset_name then
    if jwt_resign.DBLESS then
      return kong.response.exit(500, { message = "cannot use keyset names in dbless mode"})
    end
    local name = util.get_key_name(conf.resign_keyset_name) .. "-current"
    local exists, err = kong.db.keys:select_by_name(name)

    if err then
      return kong.response.exit(500, { err = err, message = "failed reading current key", name = name })
    end

    if not err and not exists then
      local new_key = util.generate_kong_key(name)
      local create, insert_err = kong.db.keys:insert(new_key)

      if insert_err then
        return kong.response.exit(500, { err = insert_err, message = "failed creating current key", name = name })
      end

      return kong.response.exit(200, {create = create})
    end

    kong.response.exit(200, { exists = exists, err = err })
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
    env_private_pem,
    {
      header = { typ = "JWT", alg = conf.resign_algorithm, kid = conf.header_key_id or env_public_jwk.kid },
      payload = payload
    }
  )
  kong.service.request.set_headers({
    [conf.resigned_header_name] = "Bearer " .. jwt_token
  })
end

return jwt_resign
