local sinatra = require('sinatra');

local app = sinatra.app:new()

app:get("/", function()
  return "Hello, World"
end)

app:get("/:name", function()
  return "Hello, " .. params.name;
end)

app:get("/age/:age", function(age)
  if (params.name) then
    return params.name .. " are " .. tostring(age) .. " years old."
  else
    return "You are " .. tostring(age) .. " years old."
  end
end)

app:run()

