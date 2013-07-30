local table, _ = table, require("underscore")
local App, Request, Response, Pattern, Utils =
  {}, require("sinatra/request"), require("sinatra/response"), require("sinatra/pattern"), require("sinatra/utils")

App.__index = App

function log(...)
  ngx.log(ngx.ERR, "SINATRA: ", ...)
end

function halt(...)
  error(Response:new(...))
end

function App:new()
  local instance = setmetatable({
    routes={}
  }, self)
  return instance
end

function App:delete(pattern, callback) self:set_route('DELETE', pattern, callback) end
function App:get(pattern, callback)
  self:set_route('GET', pattern, callback)
  self:head(pattern, callback)
end
function App:head(pattern, callback) self:set_route('HEAD', pattern, callback) end
function App:link(pattern, callback) self:set_route('LINK', pattern, callback) end
function App:options(pattern, callback) self:set_route('OPTIONS', pattern, callback) end
function App:patch(pattern, callback) self:set_route('PATCH', pattern, callback) end
function App:post(pattern, callback) self:set_route('POST', pattern, callback) end
function App:put(pattern, callback) self:set_route('PUT', pattern, callback) end
function App:unlink(pattern, callback) self:set_route('UNLINK', pattern, callback) end

function App:set_route(method, pattern, callback)
  self.routes[method] = self.routes[method] or {}
  table.insert(self.routes[method], {
    method=method,
    pattern=Pattern:new(pattern),
    callback=callback
  })
end

function App:process_route(route)
  local request = self.request
  local matches = { route.pattern:match(request.current_path) }
  if #matches > 0 then
    matches = _.map(matches, Utils.unescape)
    local params = _.extend(request:params(), {splat={},captues=matches})
    _.each(_.zip(route.pattern.keys, matches), function(matched)
      local key, value = matched[1], matched[2]
      if _.isArray(params[key]) then
        table.insert(params[key], value)
      else
        params[key] = value
      end
    end)
    local contextDSL = function(table, key)
      return function(...) return self[key](self, ...) end
    end
    local context = setmetatable({
      request=request,
      response=response,
      params=params
    }, { __index = contextDSL})
    local callback = setfenv(route.callback, context)
    halt(callback(unpack(matches)) or self.response)
  end
end

function App:status(code)
  if code then
    self.response.status = code
  end

  return self.response.status
end

function App:dispatch()
  local routes = self.routes[self.request.request_method]
  for index, route in ipairs(routes) do
    self:process_route(route)
  end

  halt(404)
end

function App:invoke(callback)
  local ok, response = pcall(callback, self)

  if getmetatable(response) == Response then
    self.response = response
  else
    log(tostring(response))
  end
end

function App:run()
  self.request = Request:new()
  self.response = Response:new()

  self:invoke(self.dispatch)
  self.response:finish()
  return self.response
end

return App
