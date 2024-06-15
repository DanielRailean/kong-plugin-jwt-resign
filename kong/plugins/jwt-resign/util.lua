local pkey = require("resty.openssl.pkey")
local json = require("cjson")


local util = {}
local plugin_name = "jwt-resign"
util.plugin_name = plugin_name

function util.get_key_name(name)
  return plugin_name .. "-" .. name
end

function util.generate_kong_key(name)
  -- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeynew
  local key = pkey.new()
  -- https://github.com/fffonion/lua-resty-openssl?tab=readme-ov-file#pkeytostring
  local jwk_str, _ = key:tostring("private", "JWK")
  local jwk = json.decode(jwk_str)
  local kong_key = { name = name, jwk = jwk_str, kid = jwk.kid }
  return kong_key
end

function util.runtime_data_cache_key(keyset_name)
  return plugin_name .. "-" .. keyset_name .. "-cache_key"
end

return util