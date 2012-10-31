function table.copy(t)
  local ret = {}
  for k, v in pairs(t) do ret[k] = v end
  return setmetatable(ret, getmetatable(t))
end

function table.count(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function table.keys(t)
  local ret = {}
  for k in pairs(t) do ret[#ret + 1] = k end
  return ret
end

function table.map(t, func)
  for k, v in pairs(t) do t[k] = func(v) end
  return t
end

function table.imap(t, func)
  for i, v in ipairs(t) do t[i] = func(v) end
  return t
end

function table.reject(t, val)
  if type(val) == "function" then
    for k, v in pairs(t) do
      if not val(v) then t[k] = nil end
    end
  else
    for k, v in pairs(t) do
      if v ~= val then t[k] = nil end
    end
  end
  
  return t
end

function table.ireject(t, val, inplace)
  if inplace then
    
  else
    
  end
end

function table.merge(a, b, overwrite)
  for k, v in pairs(b) do
    if not a[k] or overwrite then a[k] = v end      
  end
  
  return a
end

function table.append(a, b)
  for _, v in ipairs(b) do a[#a + 1] = v end
  return a
end

function table.reverse(t)
  local len = #t + 1
  
  for i = 1, math.floor(#t / 2) do
    t[i], t[len - i] = t[len - i], t[i]
  end
  
  return t
end
