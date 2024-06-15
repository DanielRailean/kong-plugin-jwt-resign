local PLUGIN_NAME = "kong-plugin-jwt-resign"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            header_name_token = {
              type = "string",
              required = true,
              default = "authorization"
            }
          },
          {
            header_name_resigned = {
              type = "string",
              required = true,
              default = "x-gateway-authorization"
            }
          },
          {
            override_kid = {
              type = "string",
              required = false,
            }
          },
          {
            override_claims = {
              required = false,
              type = "map",
              keys = { type = "string" },
              values = { type = "string" }
            }
          },
          {
            resign_key_name = {
              type = "string",
              required = false,
              not_match = "%s"
            }
          },
          {
            return_discovery_keys = {
              type = "boolean",
              required = false,
              default = false
            }
          },
        }
      },
    },
  },
}

return schema
