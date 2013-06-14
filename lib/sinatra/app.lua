local table, _ = table, require("underscore")
local App, Request, Response = {}, require("sinatra/request"), require("sinatra/response")

App.__index = App

function log(...)
  ngx.log(ngx.ERR, "SINATRA: ", ...)
end

function halt(...)
  error(Response:new(...))
end

function App:new(route_table)
  local self = setmetatable({
    routes={}
  }, self)
  return self
end

function App:get(path, callback)
  self:set_route('GET', path, callback)
end

function compile_pattern(pattern)
  local keys = {}
  local compiled_pattern = pattern:gsub(":([%w]+)", function(match)
    table.insert(keys, match)
    return '([^/?#]+)'
  end)
  return({
    original=pattern,
    matcher='^' .. compiled_pattern .. '$',
    matched_keys=keys
  })
end

function App:set_route(method, pattern, callback)
  self.routes[method] = self.routes[method] or {}
  table.insert(self.routes[method], {
    method=method,
    pattern=compile_pattern(pattern),
    callback=callback
  })
end

function process_route(request, route)
  local matches = { string.match(request.current_path, route.pattern.matcher) }
  if #matches > 0 then
    local matched_keys = _.object(route.pattern.matched_keys, matches)
    local route_env = setmetatable({
      request=request,
      params=_.extend(request:params(), matched_keys)
    }, { __index = _G})
    local callback = setfenv(route.callback, route_env)
    return callback(unpack(matches))
  end
end

function App:apply_routes(request)
  local routes = self.routes[request.request_method]
  for index, route in ipairs(routes) do
    local response = {process_route(request, route)}
    if #response > 0 then
      halt(response)
    end
  end
end

function process_request(app)
  local request = Request:new()
  app:apply_routes(request)
end

function App:run()
  local ok, status = pcall(process_request, self)
  if getmetatable(status) == Response then
    status:send()
  else
    log(tostring(status))
  end
end

return App
