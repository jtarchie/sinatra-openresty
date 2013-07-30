local _ = require("underscore")
local table = table
local Response = {}
Response.__index = Response
Response.__tostring = function(self)
  return "Response"
end

function parse_arguments(args)
  if _.isString(args) then
    return 200, {}, args
  elseif _.isNumber(args) then
    return args, {}, " "
  elseif _.isArray(args) and _.isNumber(args[1]) then
    local status, body, headers = _.shift(args), _.pop(args), unpack(args)
    return status, headers or {}, body
  else
    return 200, {}, " "
  end
end

function Response:new(args)
  if tostring(args) == "Response" then
    return args
  end

  local status, headers, body = parse_arguments(args)
  if(ngx and ngx.req.get_method() == "HEAD") then
    body = ""
  end
  return setmetatable({
    status=status,
    body=body,
    headers=headers
  }, self)
end

function Response:finish()
  ngx.status = self.status
  for name, value in pairs(self.headers) do
    ngx.header[name] = value
  end
  ngx.say(self.body)
end

return Response
