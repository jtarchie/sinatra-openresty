local table = table
local Pattern = {}
Pattern.__index = Pattern

function compile_pattern(pattern)
  local keys = {}
  local compiled_pattern = pattern:gsub(":([%w]+)", function(match)
    table.insert(keys, match)
    return '([^/?#]+)'
  end)
  return({
    original=pattern,
    matcher='^' .. compiled_pattern .. '$',
    keys=keys
  })
end

function Pattern:new(pattern)
  local self = setmetatable(compile_pattern(pattern), Pattern)
  return self
end

function Pattern:match(path)
  return string.match(path, self.matcher)
end

return Pattern
