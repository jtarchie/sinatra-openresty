local _ = require("underscore")
local Helper = {}

function Helper:is_not_found()
  return self:status() == 404
end

function Helper:is_informational()
  return 100 <= self:status() and self:status() < 200
end

function Helper:is_success()
  return 200 <= self:status() and self:status() < 300
end

function Helper:is_redirect()
  return 300 <= self:status() and self:status() < 400
end

function Helper:is_client_error()
  return 400 <= self:status() and self:status() < 500
end

function Helper:is_server_error()
  return self:status() >= 500
end

function Helper:status(code)
  if code then
    self.response.status = code
  end
  return self.response.status
end

function Helper:body(value)
  self.response.body = value
  return self.response.body
end

function Helper:headers(hash)
  if(_.isObject(hash)) then
    _.extend(self.response.headers, hash)
  end
  return self.response.headers
end

return Helper
