# kong-plugin-jwt-resign

a replacement for [KONG jwt-signer enterprize plugin](https://docs.konghq.com/hub/kong-inc/jwt-signer/)

## features

- works in dbless mode (uses a private key passed in ENV, check readme.dev.md for docker example)
- uses [`keys` kong entity](https://docs.konghq.com/gateway/3.4.x/admin-api/#keys-object) for private key management
- generates private keys on demand when enabled (if not exists), after the first execution
- extends Admin API to add endpoint for key generation/ rotation
  - POST {admin_url}/jwt-resign/{key_name} -> will generate the key
  - POST {admin_url}/jwt-resign/{key_name}/rotate -> will rotate the key
- can use existing keys after import (name format for import: `jwt-signer-{plugin_configuration.resign_key_name}-current`)
- can overwrite any token claim (`plugin_configuration.override_claims`)
- can return public jwk behaving as the discovery OIDC endpoint. (`plugin_configuration.return_discovery_keys`)
- unlike `jwt-signer`, private keys are accessible via the Admin API
- small memory footprint
- priority can be overwritten using ENV var (check docker example in readme.dev.md)

## limitations

- cannot perform token validation (use [jwt-oidc-validate](https://github.com/DanielRailean/kong-plugin-jwt-oidc-validate) for a free and simple validation plugin)
- cannot perform claims validation (FOSS solution coming soon)
- only supports `RS256` for now
- still a work in progress, use with caution.
