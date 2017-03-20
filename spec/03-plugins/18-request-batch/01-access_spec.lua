local helpers = require "spec.helpers"

describe("Plugin: Request Batch (access)", function()
  local client, api_client

  setup(function()
    local api1 = assert(helpers.dao.apis:insert {
      name = "request-batch.com",
      hosts = { "request-batch.com" } ,
      upstream_url = "http://httpbin.org"
    })

    assert(helpers.dao.plugins:insert {
      name = "request-batch",
      api_id = api1.id,
      config = {
        requests = {
          ["request_one"] = {
            method = "GET",
            url = "http://httpbin.org"
          }
        }
      }
    })

    assert(helpers.start_kong())
  end)

  before_each(function()
    client = helpers.proxy_client()
    api_client = helpers.admin_client()
  end)

  after_each(function ()
    client:close()
    api_client:close()
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  it("batches one request", function()
    local res = assert(client:send {
      method = "GET",
      path = "/get?key1=some_value1&key2=some_value2&key3=some_value3",
      headers = {
        ["Host"] = "request-batch.com"
      }
    })
    local body = assert.res_status(200, res)
  end)
end)
