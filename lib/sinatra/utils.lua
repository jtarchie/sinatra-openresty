local Utils = {}

function Utils.escape(str)
  return str:gsub("\n", "\r\n"):gsub("([^%w %-%_%.%~])", function (c)
    return string.format("%%%02X", string.byte(c))
  end):gsub(" ", "+")
end

function Utils.unescape(str)
  return(str:gsub("+", " "):gsub("%%(%x%x)", function (h)
    return string.char(tonumber(h, 16))
  end))
end

return Utils
