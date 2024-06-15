local keys = kong.db.keys
local util = require("kong.plugins.jwt-resign.util")

return {
  ["/jwt-resign/:keyset_name"] = {
    schema = keys.schema,
    methods = {
      POST = function(self, db, helpers)
        local base_name = util.get_key_name(self.params.keyset_name)
        local current_name = base_name .. "-current"
        local entity, select_err = keys:select_by_name(current_name)

        if select_err then
          return kong.response.exit(500, { err = select_err })
        end

        if entity == nil and select_err == nil then
          local kong_key = util.generate_kong_key(current_name)
          local _, insert_err = keys:insert(kong_key)

          if insert_err then
            return kong.response.exit(500, { err = insert_err })
          end

          return kong.response.exit(200, { message = "key created", name = current_name })
        end

        return kong.response.exit(409, { message = "key exists", name = current_name })
      end,
    },
  },
  ["/jwt-resign/:keyset_name/rotate"] = {
    schema = keys.schema,
    methods = {
      POST = function(self, db, helpers)
        local base_name = util.get_key_name(self.params.keyset_name)
        local current_name = base_name .. "-current"
        local previous_name = base_name .. "-previous"
        local curr_key, err_curr = keys:select_by_name(current_name)
        local prev_key, err_prev = keys:select_by_name(previous_name)


        if err_curr then
          return kong.response.exit(500, { err = err_curr })
        end

        if curr_key == nil and err_curr == nil then
          return kong.response.exit(404, { message = "key does not exist", name = base_name })
        end

        local rotated_key = util.generate_kong_key(current_name)
        rotated_key.id = curr_key.id
        local res, err = keys:upsert({ id = curr_key.id }, rotated_key)

        if err then
          return kong.response.exit(500, { err = err, message = "failed updating current key" })
        end
        curr_key.name = previous_name

        if prev_key then
          local _, upsert_prev_err = keys:upsert({ id = prev_key.id }, curr_key)
          if upsert_prev_err then
            return kong.response.exit(500, { err = upsert_prev_err, message = "failed updating previous key" })
          end
        else
          curr_key.id = nil
          local _, insert_curr_err = keys:insert(curr_key)
          if insert_curr_err then
            return kong.response.exit(500, { err = insert_curr_err, message = "failed inserting previous key" })
          end
        end

        return kong.response.exit(200, { message = "key rotated", name = base_name })
      end,
    },
  },
}
