package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")
local App = require("sinatra/app")
local MockRequest = require("mock_request")

function mock_app(declared)
  local app = App:new()
  declared(app)
  return app
end

function get(app, current_path)
  local request = MockRequest:new(app)
  return request:request("GET", current_path, {})
end

describe("helper DSL functions", function()
  function status_app(code, block)
    block = block or function() return "" end
    local app = mock_app(function(app)
      app:get("/", function()
        self:status(code)
        return tostring(block(self))
      end)
    end)
    return get(app, "/")
  end
  describe("#status", function()
    it("sets the response status code", function()
      local response = status_app(207)
      assert.same(response.status, 207)
    end)
  end)
  describe("#not_found", function()
    it("is true for status == 404", function()
      local response = status_app(404, function(self) return self:is_not_found() end)
      assert.same(response.body, 'true')
    end)
    it("is true for status != 404", function()
      local response = status_app(405, function(self) return self:is_not_found() end)
      assert.same(response.body, 'false')
    end)
  end)
end)
