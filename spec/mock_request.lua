local MockRequest = {}
MockRequest.__index = MockRequest

function MockRequest:new(app)
  return setmetatable({
    app=app
  }, MockRequest)
end

function MockRequest:request(verb, request_path, headers)
  local body = ""
  ngx={
    header={},
    log=function(...) print(...) end,
    var={
      uri=request_path
    },
    req={
      get_method=function() return verb end,
      get_uri_args=function() return {} end
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
