package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local Request = require("sinatra/request")
local _ = require("underscore")
ngx = {}

describe("Request", function()
  before_each(function()
    ngx = {
      var={
        content_length="1234",
        content_type="text/html",
        filename="index.html",
        host="www.example.com",
        hostname="example",
        query_string="a=b&1=2",
        request_method="GET",
        schema="http",
        uri="/uri",
        http_user_agent="Chrome",
        http_referer="http://another.com",
        server_port=80
      },
      req={
        get_headers=function() end,
        get_post_args=function() end,
        get_uri_args=function() end,
        read_body=function() end
      }
    }
  end)

  describe("with ngx.var", function()
    it("returns the request method", function()
      local request = Request:new()
      assert.same(request.request_method, "GET")
    end)

    it("returns the current path", function()
      local request = Request:new()
      assert.same(request.path_info, "/uri")
    end)

    it("returns content length", function()
      local request = Request:new()
      assert.same(request.content_length, "1234")
    end)

    describe("#content_type", function()
      it("returns nil when empty", function()
        ngx.var.content_type = nil
        local request = Request:new()
        assert.same(request.content_type, nil)

        ngx.var.content_type = ""
        local request = Request:new()
        assert.same(request.content_type, nil)
      end)

      it("returns the value when set", function()
        local request = Request:new()
        assert.same(request.content_type, "text/html")
      end)
    end)

    describe("#schema", function()
      it("returns schema of request", function()
        local request = Request:new()
        assert.same("http", request.schema)
      end)
    end)

    describe("#is_ssl", function()
      it("returns false", function()
        local request = Request:new()
        assert.same(false, request.is_ssl)
      end)

      describe("when schema is https", function()
        it("returns true", function()
          ngx.var.schema = "https"
          local request = Request:new()
          assert.same(true, request.is_ssl)
        end)
      end)
    end)

    describe("#host", function()
      it("returns the domain the request made", function()
        local request = Request:new()
        assert.same("www.example.com", request.host)
      end)
    end)

    describe("#hostname", function()
      it("returns the hostname of the machine", function()
        local request = Request:new()
        assert.same("example", request.hostname)
      end)
    end)

    describe("#port", function()
      it("returns the port number the of the server", function()
        local request = Request:new()
        assert.same(80, request.port)
      end)
    end)

    describe("#host_and_port", function()
      it("returns a host:port", function()
        local request = Request:new()
        assert.same("www.example.com:80", request.host_and_port)
      end)
    end)

    describe("#query_string", function()
      it("returns the original query string", function()
        local request = Request:new()
        assert.same("a=b&1=2", request.query_string)
      end)
    end)

    describe("#path", function()
      it("returns the current path with query string", function()
        local request = Request:new()
        assert.same("/uri?a=b&1=2", request.path)
      end)
    end)

    describe("#user_agent", function()
      it("returns the request user agent", function()
        local request = Request:new()
        assert.same("Chrome", request.user_agent)
      end)
    end)

    describe("#referer", function()
      it("returns the http referer", function()
        local request = Request:new()
        assert.same("http://another.com", request.referer)
      end)
    end)

    describe("#is_xhr", function()
      describe("when requested with XMLHttpRequest", function()
        before_each(function()
          ngx.var.http_x_requested_with = "XMLHttpRequest"
        end)

        it("returns true", function()
          local request = Request:new()
          assert.same(true, request.is_xhr)
        end)
      end)

      describe("with a normal request", function()
        it("returns false", function()
          local request = Request:new()
          assert.same(false, request.is_xhr)
        end)
      end)
    end)
  end)

  describe("with ngx.req", function()
    describe("form paramteres from #params", function()
      local function args(get, post)
        ngx.req.get_uri_args=function() return(get) end
        ngx.req.get_post_args=function() return(post) end
      end

      it("returns a hash from query string", function()
        args({a='1',b='2'},{b='3',c='4'})
        local request = Request:new()
        assert.same({a='1',b='2'},request.params)
      end)

      describe("when the request is a post", function()
        before_each(function()
          ngx.var.request_method = "POST"
        end)

        it("merges GET and POST params", function()
          args({a='1',b='2'},{b='3',c='4'})
          local request = Request:new()
          assert.same({a='1',b='3',c='4'}, request.params)
        end)
      end)
    end)

    describe("accessing headers", function()
      before_each(function()
        ngx.req.get_headers=function()
          return({
            ['Accept']='application/json'
          })
        end
      end)

      it("returns headers from the request", function()
        local request = Request:new()
        assert.same(request.headers, {['Accept']='application/json'})
      end)
    end)
  end)
end)
