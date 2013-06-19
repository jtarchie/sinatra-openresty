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

describe("Routing within application", function()
  local methods = {"get", "put", "post", "delete", "options", "patch", "link", "unlink"}
  _.each(methods, function(method)
    it("defines ".. method:upper() .. " request handlers with #" .. method, function()
      local app = mock_app(function(app)
        app[method](app, '/hello', function()
          return "Hello World"
        end)
      end)

      local request = MockRequest:new(app)
      local response = request:request(method:upper(), "/hello", {})
      assert.same(response.status, 200)
      assert.same(response.body, "Hello World")
    end)
  end)

  it("defined HEAD request handlers with #head", function()
    local app = mock_app(function(app)
      app:head("/hello", function()
        return 'remove me'
      end)
    end)

    local request = MockRequest:new(app)
    local response = request:request("HEAD", "/hello", {})
    assert.same(response.status, 200)
    assert.same(response.body, "")
  end)

  it("404s when no route satisfies the request", function()
    local app = mock_app(function(app)
      app:get("/foo", function() end)
    end)

    local response = get(app, "/")
    assert.same(response.status, 404)
  end)
end)
