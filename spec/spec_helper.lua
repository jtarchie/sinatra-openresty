local _ = require("underscore")
local App = require("sinatra/app")
local MockRequest = require("mock_request")
local http = require("socket.http")

local response, app = nil, nil

function mock_app(declared)
  app = App:new()
  declared(app)
  return app
end

function get(current_path)
  response = nil
  local request = MockRequest:new(app)
  response = request:request("GET", current_path, function(self)end)
  return response
end

function visit(path)
  local body, status, headers = http.request('http://localhost:3001'..path)
  local response = {body=body, status=status, headers=headers}
  return response
end
