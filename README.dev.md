# getting started with developing the plugin

## build the image

```sh
docker build . -t kong-plugin-jwt-resign
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
    -e "KONG_PLUGIN_PRIORITY_JWT_RESIGN=1060" \
    -e "KONG_PLUGIN_PRIORITY_JWT_RESIGN_PEM_PRIVATE=-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4KmXwhe6tXTFx
L7CxIXf4wew7qkVhZa8qqSuaHQ9z8sED0c6JUGPpfMJorfDxeOn8HjgoRSYFCFxa
ubQG7+kIR4ZpS9nuLgEzyOu8hoTBKs5srI5EffGBTAaV9FAvLE0gpl5SlvAaQctb
6mfmxES2JcS8n5Ug0e9HGbKL0BEACxZHbYXl7pVtcHqJWcM1mYVEj3xAwArjpY7j
O2CjM/GKA3FSC57wviNSNQm4oxj+f4kepdFoszRRB1/NHkK2dIhc32qa5skA8h6H
KhcHewlqnQN5tJOxdy4a4qyVBEJtZb6iNZXooikViHJMj+gowOGiQ0R70VQmI9Ip
jy4nBPXPAgMBAAECggEAART2rlgLE+elP7X5AsFglAyHl74jVDQluElwISKkkZjO
e3hDD1lyjM+X0Mecz75XGY0P5WSqmYL4D+xhW10TcGIDLyEr8ZNBnI1EnUHpC711
ovvMhih7P7gznbPmuLA478Uqbq/GT1EtoaeZ3qgugydrpXQGiz/QeQl0nA+n2ek0
NLoUV8DkkXUaFnOXNqmr4c2+KZkXEITBlcnH4p0PRkW0yjy5G5bxzD5N1+Fu6XZD
jM+IE7jN/VBOUcywQpdcTriGy1cxXhqKR96NvAaetU+y1ozcjSmOk1hcZCMV/M5a
9r+n/dh9oGNNe10m0G+IawnzVpeCdcYw8ZG8cYdi+QKBgQDoQnkCJl7dxEijlQ+e
SZc6K7xQFcNJin7+X7lj0vg8A5pUM0LZQxm9cMSvK3m5KPZMjjuGVkVLS6v3+U2W
hgK5OosVkVU9FXjCuaYV0iyi9m7PNFfU9/I0azNnV8DYnFAsLLf4Lec2+TNqqDYg
wfuWnM9nyUjR//OzAxdwSWyhTQKBgQDK/XN4jjMT2pSGy0cK0icq3Trsxb/OPgHs
k+NJBMy9SJWffDLuskMPUGpPyibaQHlFKKGOuhJXUksGrT5Y4uY9dY6BAu2AazPz
IrzJoh6zocpdVNsD3LBe0k2zSZRz3NM7SIcZEtiNyUMpxoGOfdAHe5DeVODpBoDE
NqOeb/5liwKBgBKPRUYztL758WgJAE+Ax/HhDtJDevCEfbNsCM9+S1HYY9u4oO3l
m8f0m/L3gWmXaV8iuoT4nd7vdBWDuXx+xvbwQ678hxgzgAvnc+soeWKoWKB8KUye
Z59itZ/bdlCY5Rsyk5zkZiaRcVdji7fAaI9XhodfoU8OqfWzGItjgqe9AoGBAJuC
BZdC4RCBsK1/R4KbstPcvgqsCCAZUuIJ/eJvoeYUmEOhI2fH+yXdRkSwKomjQQRh
dztfgzOQYNfRmuT/lsFYsP5W3to1xouqfhS+dWTKOry7iDnyNM+/rzT91pPYhZ5y
FsV3sZ0VpbV4VMJz0g4ZdMdPISqEB9vJvBlh1PO3AoGAJ5pdojpkTm/JhQ1RS366
6qTASLTv+MDtQdt/Va2gQN04K8lskAGEHpOCHdnRrFydnQLsflOL2B98bQOVg2Ao
B1L/V7l0TIkT1vms2Tk2dALChKNtZ4jLLU09i+4a36d7TInEg9krEduX1snoiHn4
CFgUQ/MGl8Y7vTspHa/irJE=
-----END PRIVATE KEY-----" \
    -e "KONG_NGINX_HTTP_LUA_SHARED_DICT=prometheus_metrics 5m;lua_shared_dict jwks 5m;lua_shared_dict discovery 5m" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    -v /host/kong-plugin-jwt-resign/kong/plugins/jwt-resign:/usr/local/share/lua/5.1/kong/plugins/jwt-resign \
    kong-plugin-jwt-resign
```

## post the config

```http
http :8001/config config=@kong.yml
```

## call the route

```http
http :8000/testroute
```
