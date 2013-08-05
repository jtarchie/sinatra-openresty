package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")
local rand = math.random
local App = require("sinatra/app")
local MockRequest = require("mock_request")

function mock_app(declared)
  local app = App:new()
  declared(app)
  return app
end

function get(app, current_path)
  local request = MockRequest:new(app)
  return request:request("GET", current_path, function(self)end)
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

  describe('informational?', function()
    it('is true for 1xx status', function()
      local response = status_app(100 + rand(100), function(self) return self:is_informational() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status > 199', function()
      local response = status_app(200 + rand(400), function(self) return self:is_informational() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('success?', function()
    it('is true for 2xx status', function()
      local response = status_app(200 + rand(100), function(self) return self:is_success() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 200', function()
      local response = status_app(100 + rand(100), function(self) return self:is_success() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 299', function()
      local response = status_app(300 + rand(300), function(self) return self:is_success() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('redirect?', function()
    it('is true for 3xx status', function()
      local response = status_app(300 + rand(100), function(self) return self:is_redirect() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 300', function()
      local response = status_app(200 + rand(100), function(self) return self:is_redirect() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 399', function()
      local response = status_app(400 + rand(200), function(self) return self:is_redirect() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('client_error?', function()
    it('is true for 4xx status', function()
      local response = status_app(400 + rand(100), function(self) return self:is_client_error() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 400', function()
      local response = status_app(200 + rand(200), function(self) return self:is_client_error() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 499', function()
      local response = status_app(500 + rand(100), function(self) return self:is_client_error() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('server_error?', function()
    it('is true for 5xx status', function()
      local response = status_app(500 + rand(100), function(self) return self:is_server_error() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 500', function()
      local response = status_app(200 + rand(300), function(self) return self:is_server_error() end)
      assert.same(response.body, 'false')
    end)
  end)
end)
