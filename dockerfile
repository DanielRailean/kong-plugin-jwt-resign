FROM bitnami/kong

### Change user to perform privileged actions
USER 0
### Install 'vim'
RUN apt update
RUN apt install unzip luarocks -y
RUN luarocks install lua-resty-jwt --check-lua-versions
RUN luarocks install lua-resty-openidc --check-lua-versions
### Revert to the original non-root user

USER 1001