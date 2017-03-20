local Errors = require "kong.dao.errors"

return {
  fields = {
    timeout = {type = "number", default = 60000, required = true },
    keepalive = {type = "number", default = 60000, required = true },
    requests = { type = "table",
      schema = {
        flexible = true,
        fields = {
          method = { type = "string" },
          url = { type = "url" }
        }
      }
    }
  },
  self_check = function(schema, plugin_t, dao, is_update)
    -- This will have to be removed once the schema validation can properly
    -- handle complex use-cases
    if not plugin_t.requests or (not next(plugin_t.requests)) then
      return false, Errors.schema "You need to set at least one request"
    else
      for _, v in pairs(plugin_t.requests) do
        if not v.url then
          return false, Errors.schema "You need to set an URL"
        end
      end
    end

    return true
  end
}
