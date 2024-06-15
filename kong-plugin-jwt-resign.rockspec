local plugin_name = "jwt-resign"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "1.0.0"
local rockspec_revision = "1"

local github_account_name = "DanielRailean"
local github_repo_name = package_name

package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }

source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = "main",
}


description = {
  summary = "Allow resigning a token to validate the request is coming from the gateway",
  homepage = "https://"..github_account_name..".github.io/"..github_repo_name,
  license = "Apache 2.0 https://github.com/".. github_account_name .. "/".. github_repo_name .. "/blob/main/LICENSE",
}

dependencies = {
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
    ["kong.plugins."..plugin_name..".util"] = "kong/plugins/"..plugin_name.."/util.lua",
    ["kong.plugins."..plugin_name..".api"] = "kong/plugins/"..plugin_name.."/api.lua",
  }
}