#!/usr/bin/env lua

--
-- getopt(":a:b", ...)
--
function getopt(optstring, ...)
	local opts = { }
	local args = { ... }

	for optc, optv in optstring:gmatch"(%a)(:?)" do
		opts[optc] = { hasarg = optv == ":" }
	end

	return coroutine.wrap(function()
		local yield = coroutine.yield
		local i = 1

		while i <= #args do
			local arg = args[i]

			i = i + 1

			if arg == "--" then
				break
			elseif arg:sub(1, 1) == "-" then
				for j = 2, #arg do
					local opt = arg:sub(j, j)

					if opts[opt] then
						if opts[opt].hasarg then
							if j == #arg then
								if args[i] then
									yield(opt, args[i])
									i = i + 1
								elseif optstring:sub(1, 1) == ":" then
									yield(':', opt)
								else
									yield('?', opt)
								end
							else
								yield(opt, arg:sub(j + 1))
							end

							break
						else
							yield(opt, false)
						end
					else
						yield('?', opt)
					end
				end
			else
				yield(false, arg)
			end
		end

		for i = i, #args do
			yield(false, args[i])
		end
	end)
end

-----------------------------

local mode   = 'f'
local delim  = '\t'
local fd     = {}
local fields

for opt, argument in getopt("b:f:d:", ...) do
  if opt then
    if opt == '?' then
      io.stderr:write("Incorrect syntax for option "..argument.."\n\n")
      os.exit(1)
    elseif opt == 'b' then
      if fields then
        io.stderr:write(arg[0]..": only one type of list may be specified\n")
        os.exit(1)
      end
      mode = 'b'
      fields = argument
    elseif opt == 'f' then
      if fields then
        io.stderr:write(arg[0]..": only one type of list may be specified\n")
        os.exit(1)
      end
      fields = argument
    elseif opt == 'd' then
      if #argument ~= 1 then
        io.stderr:write(arg[0]..": the delimiter must be a single character\n")
        os.exit(1)
      end
      mode = 'f'
      delim = argument
    else
      io.stderr:write("Internal error\n\n")
      os.exit(1)
    end
  else -- command argument
    local f = io.open(argument) -- interpreted as file to open
    if not f then
      io.stderr:write(arg[0]..": "..argument..": No such file or directory\n")
      os.exit(1)
    else
      table.insert(fd, f)
    end
  end
end

if not fields then
  io.stderr:write(arg[0]..": you must specify a list of bytes, characters, or fields\n")
  os.exit(1)
end

if #fd == 0 then
  fd = { io.stdin }
end

if mode == 'b' then
  delim = ''
end

local fields_list = {}
do
  local field = fields:match("^[^,]+")
  local next_field = fields:gmatch(",([^,]+)")
  while field do
    if field:match("-") then
      local inf, sup = field:match("^(%d*)-(%d*)$")
      if inf == "" and sup == "" then
        io.stderr:write(arg[0]..": fields and positions are numbered from 1\n")
        os.exit(1)
      end
      if inf == "" then
        inf = 1
      else
        inf = tonumber(inf)
      end
      if sup == "" then
        table.insert(fields_list, inf.."+")
      else
        for i = inf,tonumber(sup) do
          table.insert(fields_list, i)
        end
      end
    else
      table.insert(fields_list, tonumber(field))
    end
    field = next_field()
  end
end

for _, f in ipairs(fd) do
  for line in f:lines() do
    local splitted_line = {}
    if mode == 'f' then
      local elt = line:match("^[^"..delim.."]*")
      local next_elt = line:gmatch(delim.."([^"..delim.."]*)")
      while elt do
        table.insert(splitted_line, elt)
        elt = next_elt()
      end
    else -- assert(mode == 'b')
      for elt in line:gmatch(".") do
        table.insert(splitted_line, elt)
      end
    end

    for i, field in ipairs(fields_list) do
      if i > 1 then
        io.stdout:write(delim)
      end
      if type(field) == "string" then
        local f_start = tonumber(field:match("^(%d+)%+$"))
        for j = f_start, #splitted_line do
          if j > f_start then
            io.stdout:write(delim)
          end
          io.stdout:write(splitted_line[j])
        end
      else
        io.stdout:write(splitted_line[field] or "")
      end
    end
    io.stdout:write('\n')
  end
end
