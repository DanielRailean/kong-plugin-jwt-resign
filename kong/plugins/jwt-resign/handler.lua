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
  VERSION = "1.0.0",
}

RESIGN_ALG = "RS256"
ENV_PRIVATE_PEM = os.getenv("KONG_PLUGIN_PRIORITY_JWT_RESIGN_PEM_PRIVATE")

-- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeynew
local key = pkey.new(ENV_PRIVATE_PEM)
-- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeytostring
local jwk_str, _ = key:tostring("PublicKey", "JWK")
ENV_PUBLIC_JWK = json.decode(jwk_str)

local function get_runtime_data(keyset_name)
  local private_jwk
  -- if jwt_resign.DBLESS then
  --   return kong.response.exit(500, { message = "cannot use keyset names in dbless mode"})
  -- end
  local name = util.get_key_name(keyset_name) .. "-current"
  local exists, err = kong.db.keys:select_by_name(name)
  private_jwk = exists

  -- if err thenP
  --   return kong.response.exit(500, { err = err, message = "failed reading current key", name = name })
  -- end

  if not err and not exists then
    local new_key = util.generate_kong_key(name)
    local create, insert_err = kong.db.keys:insert(new_key)

    -- if insert_err then
    --   return kong.response.exit(500, { err = insert_err, message = "failed creating current key", name = name })
    -- end

    private_jwk = create
  end

  local key, err = pkey.new(private_jwk.jwk, { format = "JWK" })
  local private_pem, err = key:tostring("private", "PEM")
  local public_jwk_str, err = key:tostring("public", "JWK")
  local public_jwk = json.decode(public_jwk_str)

  -- using the kid from the database
  public_jwk.kid = private_jwk.kid

  return {
    private_pem = private_pem,
    public_jwk = public_jwk
  }
end

function jwt_resign:access(conf)
  if not conf.resign_key_name and not ENV_PRIVATE_PEM then
    return kong.response.exit(400, { message = "Bad Config", plugin = util.plugin_name })
  end

  local data = {
    private_pem = ENV_PRIVATE_PEM,
    public_jwk = ENV_PUBLIC_JWK
  }

  if conf.resign_key_name then
    local cache_key = util.runtime_data_cache_key(conf.resign_key_name)
    local cache_data, err = kong.cache:get(cache_key, nil, get_runtime_data, conf.resign_key_name)
    if cache_data then
      data = cache_data
    end
  end

  if not data.private_pem or not data.public_jwk then
    kong.response.exit(500, { message = "Internal Error", plugin = util.plugin_name })
  end

  data.public_jwk["use"] = "sig"
  data.public_jwk["alg"] = RESIGN_ALG

  if conf.return_discovery_keys then
    return kong.response.exit(200, { keys = { data.public_jwk } })
  end

  local payload = {}

  local headers = kong.request.get_headers()
  local bearer = headers[conf.header_name_token]

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
    data.private_pem,
    {
      header = { typ = "JWT", alg = RESIGN_ALG, kid = conf.override_kid or data.public_jwk.kid },
      payload = payload
    }
  )
  kong.service.request.set_headers({
    [conf.header_name_resigned] = "Bearer " .. jwt_token
  })
end

return jwt_resign
