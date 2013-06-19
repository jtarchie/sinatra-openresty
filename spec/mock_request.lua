local MockRequest = {}
MockRequest.__index = MockRequest

function MockRequest:new(app)
  return setmetatable({
    app=app
  }, MockRequest)
end

function MockRequest:request(verb, request_path, headers)
  ngx={
    log=function(...) print(...) end,
    var={
      request_method=verb,
      uri=request_path
    },
    req={
      get_uri_args=function() end
    },
    say=function() end
  }
  local response = self.app:run()
  return response
end

return MockRequest
