local Response = {}
Response.__index = Response
Response.__tostring = function(self)
  return "halt"
end

function Response:new(status, content)
  return setmetatable({
    status=status,
    content=content
  }, self)
end

function Response:send()
  ngx.say(self.content)
end

return Response
