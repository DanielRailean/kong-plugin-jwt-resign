# getting started with developing the plugin

## build the image

```sh
docker build . -t kong-plugin
```

## run the image

```sh
  docker run -d --name kong \
    -e "KONG_DATABASE=off" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -e "KONG_PLUGINS=bundled,jwt-resign" \
    -e "KONG_ERROR_DEFAULT_TYPE=application/json" \
    -e "KONG_PLUGIN_PRIORITY_JWT_OIDC_VALIDATE=1060" \
    -e "KONG_NGINX_HTTP_LUA_SHARED_DICT=prometheus_metrics 5m;lua_shared_dict jwks 5m;lua_shared_dict discovery 5m" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    -v /host/kong-plugin-jwt-oidc-validate/kong/plugins/jwt-resign:/usr/local/share/lua/5.1/kong/plugins/jwt-resign \
    kong-plugin
```

## post the config

```http
http :8001/config config=@kong.yml
```

## call the route

```http
http :8000/testroute
```
