package.path = package.path .. ";src/?.lua;src/lib/?.lua;src/lib/?/init.lua"
local Validator = require("validator")
local Argparse = require("argparse")
local sha1 = require("sha1")
local color = require("ansicolors")
local parser = Argparse("validator", "Darkmatter LLVM-IR assemly integrity validator.")

function prettyPrintSource(src, error_line)
	error_line = error_line or 0
	for line, src in pairs(src:split("\n")) do
		local spaces = "      "
		local line_color = "blue"
		local src_color = "reset"
		local digits = #tostring(line)
		local amount = #spaces - digits + 1
		spaces = spaces:sub(1, amount)
		
		if src:startsWith(";") then
			src_color = "green"
		end

		if error_line > 0 and line == error_line then
			spaces = spaces:sub(digits+1) .. ">"
			line_color = "red"
			src_color = "redbg"
		end
		print(color(("%%{%s}%s%%{reset}%s| %%{%s}%s%%{reset}"):format(line_color, line, spaces, src_color, src)))
	end
end

function performAnalysis(file_path)
	local validator = Validator:init(file_path)

	-- TODO:
	-- replace this with a dynamic spinner and remove the text when it's done analyzing
	--print("Parsing ...")

	local status = validator:analyze()
	local error_line = 0

	local valid_llvm_ir = status["valid_ir"]
	local metadata_status = status["metadata"]
	local status_header = status["header_signature"]
	local status_integrity = status["integrity_seal"]

	if valid_llvm_ir[1] then
		valid_llvm_ir[1] = "%{green} ok %{reset}"
		table.insert(valid_llvm_ir, "")
	else
		valid_llvm_ir[1] = "%{red}fail%{reset}"
		valid_llvm_ir[2] = " - " .. valid_llvm_ir[2]
	end

	if metadata_status[1] then
		metadata_status[1] = "%{green} ok %{reset}"
		table.insert(metadata_status, "")
	else
		metadata_status[1] = "%{red}fail%{reset}"
		metadata_status[2] = " - " .. metadata_status[2]
	end

	if status_header[1] then
		status_header[1] = "%{green} ok %{reset}"
		table.insert(status_header, "")
	else
		status_header[1] = "%{red}fail%{reset}"
		status_header[2] = " - " .. status_header[2]
	end

	if status_integrity[1] then
		status_integrity[1] = "%{green} ok %{reset}"
		table.insert(status_integrity, "")
	else
		status_integrity[1] = "%{red}fail%{reset}"
		status_integrity[2] = " - " .. status_integrity[2]
	end

	--[[
	print()
	print(color("%{underline}Assembly Source%{reset}"))
	print("________")
	prettyPrintSource(validator:getSource(), 7)
	print()
	--]]

	local stats_lines = 0
	local stats_global_vars = 0
	local stats_local_vars = 0

	for _, line in pairs(validator:getSource():split("\n")) do
		line = line:trim()

		if line:startsWith("@") then
			stats_global_vars = stats_global_vars + 1
		end

		if line:startsWith("%") then
			stats_local_vars = stats_local_vars + 1
		end

		stats_lines = stats_lines + 1
	end

	print()
	print(color(("%%{underline}Analysis Report: %s%%{reset}"):format(file_path)))
	print()
	print(color(("  File Size..................: %d %s"):format(#validator:getSource(), "bytes")))
	print(color(("  File Hash..................: %s"):format(sha1(validator:getSource()))))
	print(color(("  Total Lines................: %d"):format(stats_lines)))
	print(color(("  Local Vars/Registers.......: %d"):format(stats_local_vars)))
	print(color(("  Global Variables...........: %d"):format(stats_global_vars)))
	print()
	if validator:getCreationTime() then
		print(color(("  Creation Date..............: %s"):format(os.date(color("%{cyan}%A, %B %m, %Y%{reset} at %{cyan}%H:%M:%S%{reset}"), validator:getCreationTime()))))
	end
	if validator:isValidIntegrityHash() then
		print(color(("  Integrity Checksum.........: %%{greenbg}%s%%{reset}"):format(validator:getIntegrityHash())))
	else
		print(color(("  Integrity Checksum.........: %%{redbg}%s%%{reset}"):format(validator:getIntegrityHash() or "<NONE>")))
	end
	print()
	print(color(("  Valid Assembly.............: [%s]%s"):format(valid_llvm_ir[1], valid_llvm_ir[2])))
	print(color(("  Metadata...................: [%s]%s"):format(metadata_status[1], metadata_status[2])))
	print(color(("  Header Signature...........: [%s]%s"):format(status_header[1], status_header[2])))
	print(color(("  Integrity Seal.............: [%s]%s"):format(status_integrity[1], status_integrity[2])))
	print()
end









parser:argument("command", "Validation command to execute."):args("1")
parser:argument("file", "Input LLVM-IR assembly file."):args("+")
--parser:option("-l --log-level", "Console log level.", "info")
local args = parser:parse()

--[[
for k, v in pairs(args) do
	print(color("args: " .. k .. " => " .. tostring(v)))
end
--]]

if args["command"] == "analyze" then
	print(("Performing deep-analysis on %d file(s) ..."):format(#args["file"]))
	for _, file in pairs(args["file"]) do
		performAnalysis(file)
		print()
	end
elseif args["command"] == "check" then
	for _, file in pairs(args["file"]) do
		local validator = Validator:init(file)
		print(("%s %s"):format(file, validator:isValidIntegrityHash() and "ok" or "fail"))
	end
else
	print("Valid commands:")
	print(color("  - analyze"))
	print(color("  - check"))
	--print(color("  - validate"))
	--print(color("  - assemble"))
end
