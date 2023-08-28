--[["
	wenze
 "]]

local Core_Logger = SGEngine.Core.Logger

local string_format = string.format
local string_len = string.len
local string_rep = string.rep
local string_sub = string.sub
local string_gsub = string.gsub
local string_find = string.find
local table_insert = table.insert
local debug_traceback = debug.traceback
local table_sort = table.sort

local tostring = tostring
local type = type
local pairs = pairs
local xpcall = xpcall
local tblunpack = table.unpack
Logger = Logger or {}

local function GetFuncName(traceBackStr)
    local strArr = string.split(traceBackStr, "\n")
    if strArr and #strArr > 4 then
        local str = strArr[4]
        local strArr = string.split(str, ":")
        local fileNameFull = strArr[1]
        local lineStr = strArr[2]
        local filePath = string.split(fileNameFull, "/")
        local fileName = filePath[#filePath] or "nofile"
        return fileName .. ".lua[line" .. lineStr .. "]\n"
    end
    return ""
end

function Logger.Error(...)
	local str = string_format(...)
	if str == nil then return end
	str = debug_traceback(tostring(str))
	Core_Logger.LogError(GetFuncName(str)..str)
end

function Logger.Warn(...)
	if ENABLE_DEBUG_AND_ABOVE_LOG or ENABLE_INFO_AND_ABOVE_LOG or ENABLE_WARNING_AND_ABOVE_LOG then
	   local str = string_format(...)
	   if str == nil then return end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogWarning(GetFuncName(str)..str)
	end
end

function Logger.LogInfo(...)
	if ENABLE_DEBUG_AND_ABOVE_LOG or ENABLE_INFO_AND_ABOVE_LOG then
	   local str = string_format(...)
	   if str == nil then return end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogInfo(GetFuncName(str)..str)
	end
end

function Logger.LogDebug(...)
	if ENABLE_DEBUG_AND_ABOVE_LOG then
	   local str = string_format(...)
	   if str == nil then return end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogDebug(GetFuncName(str)..str)	
	end
end

function Logger.LogDebugFormat( ... )
	if ENABLE_DEBUG_AND_ABOVE_LOG then
	   if str == nil then
	      return
	   end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogDebugFormat(str,...)
	end	
end

function Logger.LogInfoFormat(str , ...)
	if ENABLE_DEBUG_AND_ABOVE_LOG or ENABLE_INFO_AND_ABOVE_LOG then	
	   if str == nil then
	      return
	   end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogInfoFormat(str,...)
	end
end

function Logger.LogErrorFormat(str, ... )
	if str == nil then
	   return
	end
	str = debug_traceback(tostring(str))
	Core_Logger.LogErrorFormat(str,...)
end

function Logger.LogWarningFormat(str, ... )
	if ENABLE_DEBUG_AND_ABOVE_LOG or ENABLE_INFO_AND_ABOVE_LOG or ENABLE_WARNING_AND_ABOVE_LOG then
	   if str == nil then
	      return
	   end
	   str = debug_traceback(tostring(str))
	   Core_Logger.LogWarningFormat(str,...)
	end
end

--兼具log.LogInfo 和 Logger.table功能
function Logger.Print(value, desciption, nesting)
	if ENABLE_DEBUG_AND_ABOVE_LOG then
	   local tType = type(value)
	   if tType == "table" then
		  Logger.Table(value,desciption, nesting or 3)
	   elseif tType == 'string' or tType == 'number' then
		  Logger.LogDebug(value)
	   else
		  Logger.LogDebug(tType)
	   end
	end
end

--[[
打印一个table
@value [table] 必须参数  
@desciption [string] [非必要参数] 描述标记 
@nesting [number] [非必要参数] table最大嵌套 若不设置 默认为3层
--]]
function Logger.Table(value, desciption, nesting)
	if not ENABLE_DEBUG_AND_ABOVE_LOG then
	   return
	end
	if type(nesting) ~= "number" then nesting = 3 end
	
	local lookup = {}
	local result = {}

	local function trim(input)
		input = string_gsub(input, "^[ \t\n\r]+", "")
		return string_gsub(input, "[ \t\n\r]+$", "")
	end
	local function split(input, delimiter)
		input = tostring(input)
		delimiter = tostring(delimiter)
		if (delimiter=='') then return false end
		local pos,arr = 0, {}
		for st,sp in function() return string_find(input, delimiter, pos, true) end do
			table_insert(arr, string_sub(input, pos, st - 1))
			pos = sp + 1
		end
		table_insert(arr, string_sub(input, pos))
		return arr
	end
	local traceback = split(debug_traceback("", 2), "\n")
	local tLen = #traceback
	local fromStr = trim(traceback[3].."\n")
	if tLen > 3 then
		fromStr = trim(traceback[4].."\n")
	end
	local logStr = "dump from: " .. fromStr
	local function _dump_value(v)
		if type(v) == "string" then
			v = "\"" .. v .. "\""
		end
		return tostring(v)
	end
	local function _dump(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string_rep(" ", keylen - string_len(_dump_value(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string_format("%s%s%s = %s", indent, _dump_value(desciption), spc, _dump_value(value))
		elseif lookup[tostring(value)] then
			result[#result +1 ] = string_format("%s%s%s = *REF*", indent, _dump_value(desciption), spc)
		else
			lookup[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string_format("%s%s = *MAX NESTING*", indent, _dump_value(desciption))
			else
				result[#result +1 ] = string_format("%s%s = {", indent, _dump_value(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = _dump_value(k)
					local vkl = string_len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table_sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i = 1, #keys do
					local k = keys[i]
					_dump(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string_format("%s}", indent)
			end
		end
	end
	_dump(value, desciption, "", 1)
		
	local maxLine = #result
	for i = 1, maxLine do
		logStr = logStr .."\n" .. result[i]
		if string.len(logStr) > 13000 or i == maxLine then
			print(logStr)
			logStr = ""
		end
	end
	return result
end
return Logger