local class = require "30log"
local table, _ = table, require("underscore")
local App = class {}
local Request = require("sinatra/request")
local Response = require("sinatra/response")
local Pattern = require("sinatra/pattern")
local Utils = require("sinatra/utils")
local Helper = require("sinatra/app/helper")

local NotFound = Response:new({404})

local function log(...)
  ngx.log(ngx.ERR, "SINATRA: ", ...)
end

local function halt(...)
  coroutine.yield(...)
end

function App:__init()
  self.routes={}
  self.filters={['before']={},['after']={}}
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

local function compile(method, pattern, callback)
  return {
    method=method,
    pattern=Pattern:new(pattern),
    callback=callback
  }
end

function App:set_route(method, pattern, callback)
  self.routes[method] = self.routes[method] or {}
  table.insert(self.routes[method], compile(method, pattern, callback))
end

function App:process_route(route, block)
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
    local context = setmetatable({
      self=self,
      request=self.request,
      response=self.response,
      params=params
    }, { __index = _G})
    local callback = setfenv(route.callback, context)
    block = block or function() end
    block(callback(unpack(matches)))
  end
end

function App:after(...) self:add_filter('after', ...) end
function App:before(...) self:add_filter('before', ...) end

function App:add_filter(filter_type, pattern, callback)
  if(_.isFunction(pattern)) then
    callback, pattern = pattern, '*'
  end

  self.filters[filter_type] = self.filters[filter_type] or {}
  table.insert(self.filters[filter_type], compile(filter_type, pattern, callback))
end

function App:process_filters(filter_type)
  local filters = self.filters[filter_type]
  for index, route in ipairs(filters) do
    self:process_route(route)
  end
end

function App:process_routes()
  self:process_filters('before')

  local routes = self.routes[self.request.request_method]
  for index, route in ipairs(routes) do
    self:process_route(route, halt)
  end
  halt(NotFound)
end

function App:dispatch()
  self:invoke(self.process_routes)
  self:process_filters('after')
end

function App:invoke(callback)
  local ok, response = coroutine.resume(coroutine.create(callback), self)
  if getmetatable(response) == Response then
    self.response = response
  elseif response then
    self.response:update(response)
  end
  return ok
end

function App:run()
  self.request = Request:new()
  self.response = Response:new()

  self:invoke(self.dispatch)
  self.response:finish()
  return self.response
end

App:with(Helper)

return App
