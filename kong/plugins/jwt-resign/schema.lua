local PLUGIN_NAME = "kong-plugin-jwt-resign"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            override_claims = {
              required = false,
              type = "map",
              keys = { type = "string" },
              values = { type = "string" }
            }
          },
          {
            header_name = {
              type = "string",
              required = true,
              default = "authorization"
            }
          },
          {
            resigned_header_name = {
              type = "string",
              required = true,
              default = "x-gateway-authorization"
            }
          },
          {
            header_key_id = {
              type = "string",
              required = false,
            }
          },
          {
            return_discovery_keys = {
              type = "boolean",
              required = false,
              default = false
            }
          },
          {
            resign_algorithm = {
              type = "string",
              required = true,
              one_of = {
                "RS256",
                "RS512",
              },
              default = "RS256"
            }
          },
          {
            resign_keyset_name = {
              type = "string",
              required = false
            }
          }
        }
      },
    },
  },
}

return schema
