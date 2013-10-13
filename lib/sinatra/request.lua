local class = require 'sinatra/30log'
local _ = require("sinatra/underscore")
local Request = class {}
Request.__name = "Request"

local function content_type()
  local content_type = ngx.var.content_type
  if content_type == "" or content_type == nil then
    return nil
  else
    return content_type
  end
end

local function form_data()
  return ngx.var.request_method == "POST"
end

local function params()
  local params = _.extend({}, ngx.req.get_uri_args())
  if form_data() then
    ngx.req.read_body()
    params = _.extend(params, ngx.req.get_post_args())
  end
  return params
end

function Request:__init()
  self.content_length = ngx.var.content_length
  self.content_type = content_type()
  self.headers = ngx.req.get_headers()
  self.hostname = ngx.var.hostname
  self.params = params()
  self.path_info = ngx.var.uri
  self.query_string = ngx.var.query_string or ""
  self.path = self.path_info .. "?" .. self.query_string
  self.request_method = ngx.var.request_method
  self.schema = ngx.var.schema
  self.is_ssl = self.schema == "https"
  self.host = ngx.var.host
  self.port = ngx.var.server_port
  self.host_and_port = self.host .. ":" .. self.port
  self.user_agent = ngx.var.http_user_agent
  self.is_xhr = ngx.var.http_x_requested_with == "XMLHttpRequest"
  self.referer = ngx.var.http_referer
end

return Request
