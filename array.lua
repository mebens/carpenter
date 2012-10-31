array = {}

local function append(self, t)
  return table.append(table.copy(self), t)
end

function array:__call(i, j)
  if j then
    local ret = {}
    for index = i, j do ret[#ret + 1] = self[index] end
    return ret
  else
    return self[i]
  end
end

function array:__unm()
  return table.reverse(table.copy(self))
end

array.__index = table
array.__add = append
array.__concat = append
array.__sub = table.reject

setmetatable(array, { __call = function(self, t)
  return setmetatable(t or {}, self)
end })
