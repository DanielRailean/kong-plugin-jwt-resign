local PLUGIN_NAME = "kong-plugin-jwt-oidc-validate"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            discovery_url = {
              type = "string",
              required = true
            }
          },
          {
            header_name = {
              type = "string",
              required = true,
              default = "authorization"
            }
          }
        }
      },
    },
  },
}

return schema
