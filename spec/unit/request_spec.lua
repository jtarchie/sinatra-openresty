package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local Request = require("sinatra/request")
ngx = {}

describe("Request", function()
  before_each(function()
    ngx = {var={}}
  end)

  it("returns the request method", function()
    ngx.var = {request_method="GET"}
    local request = Request:new()
    assert.same(request.request_method, "GET")
  end)

  it("returns the current path", function()
    ngx.var = {uri="/path"}
    local request = Request:new()
    assert.same(request.current_path, "/path")
  end)

  describe("form paramteres from #params", function()
    before_each(function()
      ngx.req = {get_uri_args=function()
        return({
          a='1',
          b='2'
        }) 
      end}
    end)

    it("returns a hash from query string", function()
      local request = Request:new()
      assert.same(request:params(), {a='1',b='2'})
    end)
  end)
end)
