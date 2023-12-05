
function fileExists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

function readFile(file)
	if not fileExists(file) then return {} end
	local bytes = ""
	local f = io.open(file, "rb")
	bytes = f:read("*all")
	f:close()
	return bytes
end

function readLines(file)
	if not fileExists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do 
		table.insert(lines, line)
	end
	return lines
end

function string.startsWith(str, start)
	return string.sub(str,1,string.len(start))==start
end

function string.endsWith(str, ending)
	return ending == '' or string.sub(str,-string.len(ending))==ending
end

function string.trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function string.split(str, separator)
	assert(type(str) == "string" and type(separator) == "string", "invalid arguments")
	local o = {}
	while true do
		local pos1, pos2 = str:find(separator)
		if (not pos1) then
			o[#o+1] = str
			break
		end
		o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
	end
	return o
end
