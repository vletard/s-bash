#!/usr/bin/env lua

local f1 = io.open(arg[1])
local f2 = io.open(arg[2])

local c1 = 1
local c2 = 1
local l1 = f1:read()
local l2 = f2:read()

while l1 or l2 do
  if l1 ~= l2 then
    if l1 == nil then
      c1 = c1 - 1
      print(string.format("%da%d\n> %s", c1, c2, l2)) -- addition
    elseif l2 == nil then
      c2 = c2 - 1
      print(string.format("%da%d\n< %s", c1, c2, l1)) -- addition
    elseif l1 == "" then
--      print(string.format("%dc%d\n< %s\n---\n> %s", c1, c2, l1, l2)) -- change
    elseif l2 == "" then
--      print(string.format("%dc%d\n< %s\n---\n> %s", c1, c2, l1, l2)) -- change
    else
      print(string.format("%dc%d\n< %s\n---\n> %s", c1, c2, l1, l2)) -- change
    end
  end
  c1 = c1 + 1
  c2 = c2 + 1
  l1 = f1:read()
  l2 = f2:read()
end
