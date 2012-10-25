require("carpenter")
require("array")

local function contentsEqual(t, test)
  local status = true
  
  for k, v in pairs(test) do
    if t[k] ~= v then
      status = false
      break
    end
  end
  
  assert_true(status)
end

local function contentsContain(t, test)
  local status = false
  local count = 0
  
  for _, v in pairs(t) do
    for _, tv in ipairs(test) do
      if v == tv then
        count = count + 1
        break
      end
    end
    
    if count == #test then
      status = true
      break
    end
  end
  
  assert_true(status)
end

-- this one appears a few times
local function inplaceTest(a, b)
  test("It should modify the table in-place and return it", function()
    assert_equal(a, b)
  end)
end

-- common tests for both map and imap
-- relies on table.count to be functional
local function testMap(func)
  local x = { 1, 2, 3 }
  local y = func(x, function(v) return v * 2 end)
  
  test("It should run the function on each value, and modify the table in-place", function()
    contentsEqual(x, { 2, 4, 6 })
  end)
  
  test("It should not change the number of elements in the table", function()
    assert_equal(table.count(x), 3)
  end)
  
  test("It should return the table", function()
    assert_equal(x, y)
  end)
end

context("Table functions", function()
  context("table.copy", function()
    local x = setmetatable({ "foo", a = 1, b = 2 }, { __test = true })
    local y = table.copy(x)
    y.c = 4
    
    test("It should copy all values", function()
      contentsEqual(y, x)
    end)
    
    test("It should result in a unique table", function()
      assert_not_equal(x, y)
      assert_nil(x.c)
    end)
    
    test("It should assign the same metatable", function()
      assert_true(getmetatable(y).__test)
      assert_equal(getmetatable(x), getmetatable(y))
    end)
  end)
  
  context("table.count", function()
    local x = { 1, 2, 3, 4, 5 }
    local y = { foo = 3, bar = 5, [5] = "bar" }
    
    test("It should work on both 'array' and 'set' tables", function()
      assert_equal(table.count(x), 5)
      assert_equal(table.count(y), 3)
    end)
    
    test("It should work the same as the length operator on 'array' tables", function()
      assert_equal(table.count(x), #x)
    end)
  end)
  
  context("table.map", function()
    testMap(table.map)
    
    test("It should also work on 'set' tables", function()
      local x = table.map({ foo = 3, bar = 4 }, function(v) return v * 2 end)
      contentsEqual(x, { foo = 6, bar = 8 })
    end)
  end)
  
  context("table.imap", function()
    testMap(table.imap)
    
    test("It should only work on the 'array' part of tables", function()
      local x = table.imap({ 1, 2, foo = 3, bar = 4 }, function(v) return v * 2 end)
      contentsEqual(x, { 2, 4, foo = 3, bar = 4 })
    end)
  end)
  
  -- relies on table.copy to be functional
  context("table.merge", function()
    local x = { 1, 2, 3, 4, foo = "bar", bar = "foo" }
    local y = { [4] = 6, [5] = 7, foo = "foo", la = "bar" }
    local a = table.merge(x, y)
    local b = table.merge(table.copy(x), y, true)
    inplaceTest(x, a)
    
    test("It should always merge values that are initially nil", function()
      assert_equal(a[5], y[5])
      assert_equal(a.la, y.la)
      assert_equal(b[5], y[5])
      assert_equal(b.la, y.la)
    end)
    
    test("It should not overwrite values by default", function()
      assert_equal(a[4], 4)
      assert_equal(a.foo, "bar")
    end)
    
    test("It should overwrite values if specified", function()
      assert_equal(b[4], 6)
      assert_equal(b.foo, "foo")
    end)
  end)
  
  context("table.append", function()
    local x = { 2, 5 }
    local y = { 3, 4 }
    local z = table.append(x, y)
    inplaceTest(x, z)
    
    test("It should append the elements from the second table", function()
      contentsEqual(x, { 2, 5, 3, 4 })
    end)
  end)
  
  context("table.reject", function()
    local a = { 1, 2, 2, 2, 3, 4 }
    local b = { 1, 2, 3, 4, 5 }
    local c = { 1, 2, 3, foo = "foo" }
    local d = table.reject(a, 2)
    table.reject(b, function(x) return x < 4 end)
    table.reject(c, function() return true end)
    inplaceTest(a, d)
    
    test("If called with a value, it should remove all elements equal to that value", function()
      contentsEqual(a, { 1, 3, 4 })
    end)
    
    test("If called with a function, it should remove all elements for which that functions returns false", function()
      contentsEqual(b, { 4, 5 })
    end)
    
    test("It should ignore values with non-integer keys", function()
      assert_equal(c.foo, "foo")
    end)
  end)
  
  context("table.reverse", function()
    local x = { 1, "foo", 3, 4, 5 }
    local y = table.reverse(x)
    inplaceTest(x, y)
    
    test("It should reverse the table", function()
      contentsEqual(x, { 5, 4, 3, "foo", 1 })
    end)
  end)
    
  test("table.keys should return a table containing the keys of the provided table", function()
    local x = { 2, 4, foo = "bar", bar = "foo" }
    contentsContain(table.keys(x), { 1, 2, "foo", "bar" })
  end)
end)

context("array", function()
  context("Initialisation", function()
    local x = array{1, "foo"}
    local y = array.new{2, "bar"}
    local z = array()
    
    test("array{}", function()
      contentsEqual(x, { 1, "foo" })
    end)
    
    test("array.new{}", function()
      contentsEqual(y, { 2, "bar" })
    end)
    
    test("array() should return an empty table", function()
      assert_equal(#z, 0)
    end)
  end)
  
  test("arrays should index the table module", function()
    local x = array{3, 4, 5}
    x:map(function(v) return v * 2 end):reverse()
    contentsEqual(x, { 10, 8, 6 })
  end)
  
  context("Operators", function()
    context("__add and __concat", function()
      local a = array{2, "foo"}
      local b = array{4, "bar"}
      local c = a + b
      local d = a .. b
      
      test("They should append", function()
        contentsEqual(c, { 2, "foo", 4, "bar" })
        contentsEqual(d, c)
      end)
      
      test("They should return unique tables and not alter the originals", function()
        assert_not_equal(a, c)
        assert_not_equal(a, d)
        contentsEqual(a, { 2, "foo" })
        contentsEqual(b, { 4, "bar" })
      end)
    end)
    
    context("__call", function()
      local x = array{10, 20, 30, 40, 50}
      
      test("When called with a single integer, it should return the item at that index", function()
        assert_equal(x(2), 20)
      end)
      
      test("When called with two integers, it should return items in that range", function()
        contentsEqual(x(2, 4), { 20, 30, 40 })
      end)
    end)
    
    context("__unm", function()
      local x = array{10, 20, 30}
      local y = -x
      
      test("It should reverse the table", function()
        contentsEqual(y, { 30, 20, 10 })
      end)
      
      test("It should return a unique and not alter the original", function()
        assert_not_equal(x, y)
        contentsEqual(x, { 10, 20, 30 })
      end)
    end)
  end)
end)
