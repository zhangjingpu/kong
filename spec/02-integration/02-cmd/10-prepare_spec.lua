local helpers = require "spec.helpers"

describe("kong prepare", function()
  setup(function()
    helpers.clean_prefix()
  end)
  teardown(function()
    helpers.clean_prefix()
  end)

  it("prepares prefix with default conf/prefix", function()
    assert(helpers.kong_exec "prepare")
  end)
  
  describe("errors", function()
    it("prepare inexistent Kong conf file", function()
      local ok, stderr = helpers.kong_exec "prepare --conf foobar.conf"
      assert.False(ok)
      assert.is_string(stderr)
      assert.matches("Error: no file at: foobar.conf", stderr, nil, true)
    end)
  end)
end)
