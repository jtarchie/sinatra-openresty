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
  describe("status", function()
    function status_app(code, block)
      block = block or function() end
      local app = mock_app(function(app)
        app:get("/", function()
          self:status(code)
          return block()
        end)
      end)
      return get(app, "/")
    end

    it("sets the response status code", function()
      local response = status_app(207)
      assert.same(response.status, 207)
    end)
  end)
end)
