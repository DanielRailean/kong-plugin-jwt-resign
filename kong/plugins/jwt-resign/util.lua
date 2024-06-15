local pkey = require("resty.openssl.pkey")
local json = require("cjson")

local plugin_name = "jwt-resign"

local util = {}

function util.get_key_name(name)
  return plugin_name .. "-" .. name
end

function util.generate_kong_key(name)
  local key = pkey.new()
  local jwk_str, _ = key:tostring("PrivateKey", "JWK")
  local jwk = json.decode(jwk_str)
  local kong_key = { name = name, jwk = jwk_str, kid = jwk.kid }
  return kong_key
end

return util