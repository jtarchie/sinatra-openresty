local class = require '30log'
local Request = class {}
Request.__name = "Request"

function Request:__init()
  self.request_method=ngx.req.get_method()
  self.current_path=ngx.var.uri
end

function Request:params()
  self.params_values = self.params_values or ngx.req.get_uri_args()
  return self.params_values
end

return Request
