package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")
local App = require("sinatra/app")
local MockRequest = require("mock_request")

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

  it("defines HEAD method for every GET method", function()
    local app = mock_app(function(app)
      app:get("/hello", function()
        return 'remove me'
      end)
    end)

    local request = MockRequest:new(app)
    local response = request:request("HEAD", "/hello", {})
    assert.same(response.status, 200)
    assert.same(response.body, "")
  end)

  it("404s when no route satisfies the request", function()
    mock_app(function(app)
      app:get("/foo", function() end)
    end)

    local response = get("/")
    assert.same(response.status, 404)
  end)

  it("allows using unicode", function()
    mock_app(function(app)
      app:get("/föö", function() end)
    end)

    local response = get("/f%C3%B6%C3%B6")
    assert.same(response.status, 200)
    local response = get("/f%c3%b6%c3%b6")
    assert.same(response.status, 200)
  end)

  it("handles encoded slashes correctly", function()
    mock_app(function(app)
      app:get("/:a", function(a) return a end)
    end)

    local response = get("/foo%2Fbar")
    assert.same(response.status, 200)
    assert.same(response.body, "foo/bar")

    local response = get("/foo%2fbar")
    assert.same(response.status, 200)
    assert.same(response.body, "foo/bar")
  end)

  it("supports single splat params like /*", function()
    mock_app(function(app)
      app:get("/*", function(splat)
        return _.join(params.splat, ",")
      end)
    end)

    local response = get("/foo")
    assert.same(response.status, 200)
    assert.same(response.body, "foo")

    local response = get("/foo/bar/baz")
    assert.same(response.status, 200)
    assert.same(response.body, "foo/bar/baz")
  end)

  it("supports mixing multiple splat params", function()
    mock_app(function(app)
      app:get("/*/foo/*/*", function(splat)
        return _.join(params.splat, ",")
      end)
    end)

    local response = get("/bar/foo/bling/baz/boom")
    assert.same(response.status, 200)
    assert.same(response.body, "bar,bling,baz/boom")

    local response = get("/bar/foo/baz")
    assert.same(response.status, 404)
  end)

  it("supports mixing named and splat params", function()
    mock_app(function(app)
      app:get("/:foo/*", function(splat)
        return _.join(_.flatten({params.foo, params.splat}),",")
      end)
    end)

    local response = get("/foo/bar/baz")
    assert.same(response.status, 200)
    assert.same(response.body, "foo,bar/baz")
  end)

  it("URL decodes named parameters and splats", function()
    mock_app(function(app)
      app:get("/:foo/*", function(splat)
        return _.join(_.flatten({params.foo, params.splat}),",")
      end)
    end)

    local response = get("/hello%20world/how%20are%20you")
    assert.same(response.status, 200)
    assert.same(response.body, "hello world,how are you")
  end)

  it("supports mixing multiple splat params as block parameters", function()
    mock_app(function(app)
      app:get("/*/foo/*/*", function(foo, bar, baz)
        return _.join({foo, bar, baz}, ",")
      end)
    end)

    local response = get("/bar/foo/bling/baz/boom")
    assert.same(response.status, 200)
    assert.same(response.body, "bar,bling,baz/boom")
  end)
end)
