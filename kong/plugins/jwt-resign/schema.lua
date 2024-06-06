local PLUGIN_NAME = "kong-plugin-jwt-resign"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          { override_claims = {
            required = false,
            type = "map",
            keys = { type = "string" },
            values = { type = "string"}
          } },
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
            private_key_pem_env_name = {
              type = "string",
              required = true,
              default = "KONG_PLUGIN_PRIORITY_JWT_RESIGN_PEM_PRIVATE"
            }
          }
        }
      },
    },
  },
}

return schema
