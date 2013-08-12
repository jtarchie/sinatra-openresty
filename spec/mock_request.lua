local _ = require("underscore")
local MockRequest = {}
local Utils = require("sinatra/utils")
MockRequest.__index = MockRequest

function MockRequest:new(app)
  return setmetatable({
    app=app
  }, MockRequest)
end

local function convert_qs(str)
  local groups = _.split(str, "&")
  return _.reduce(groups, function(memo, group)
    local name, value = unpack(_.split(group, "="))
    memo[Utils.unescape(name)] = Utils.unescape(value)
    return memo
  end, {})
end

function MockRequest:request(verb, request_path, headers)
  local path, qs = unpack(_.split(request_path, "?"))
  local params = convert_qs(qs)
  local body = ""
  ngx={
    header={},
    log=function(...) print(...) end,
    var={
      uri=path
    },
    req={
      get_method=function() return verb end,
      get_uri_args=function() return params end
    },
    say=function(str) body = body .. str end
  }
  local response = self.app:run()

  return {
    status=response.status,
    headers=response.headers,
    body=body
  }
end

return MockRequest
