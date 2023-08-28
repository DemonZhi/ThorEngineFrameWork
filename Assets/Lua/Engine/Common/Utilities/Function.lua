function math.clamp01(a)
    if a < 0 then
        return 0
    end

    if a > 1 then
        return 1
    end
    return a
end

function math.lerp(a, b, t)
    return a + (b - a) * math.clamp01(t)
end

function tonumberWithDefault(v, base, default)
    return tonumber(v, base) or default
end

function toint(value)
    return math.floor(tonumber(value))
end

function tobool(value)
    return math.floor(tonumber(value))
end

function totable(value)
    if type(v) ~= "table" then
        v = {}
    end
    return v
end

function format(...)
    return string.format(...)
end

function replace(format, vars)
    for i = 1, #vars do
        format = string.gsub(format, "{" .. i .. "}", vars[i])
    end
    return format
end

string.Empty = ""
function string.split(str, delimiter)
    if str == nil or str == "" then
        return {}
    end
    if (delimiter == "") then
        local a = 0
        local result = {}
        for i = 1, utf8.len(str) do
            a = a + 1
            result[#result + 1] = utf8.sub(str, a, a)
        end
        return result
    end
    local pos, arr = 1, {}
    for s in string.gmatch(str, "([^"..delimiter .."]+)") do
        table.insert(arr,s)
    end
    return arr
end

function string.IsNullOrEmpty(str)
    return str == nil or str == ""
end

function string.GetValueByIndex(dataList, index, default)
    local str = dataList[index]
    if string.IsNullOrEmpty(str) then
        return default
    end
    return str
end

function table.findFirstIndex(table, predictFun)
    for i, v in pairs(table) do
        if predictFun(v) then
            return i
        end
    end
end

function table.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(object)
end

--不设元表，适用于简单值
function table.cloneSimple(object)
    if object == nil then
        return
    end
    local temp = {}
    for key, value in pairs(object) do
        if  type(value) == "table" then
            temp[k] = table.cloneSimple(value)
        else 
            temp[k] = v
        end
    end
    return temp
end

-- 查找数组下标
function table.index(table, value)
    if value ~= nil and table ~= nil then
        for i, v in ipairs(table) do
            if value == v then
                return i
            end
        end
    end
    return nil
end

function table.findFirstIndex(table, predictFun)
    if table == nil then
        return
    end
end

function makeReadonly(table)
    local metatable = getmetatable(table)
    if metatable == nil then
        metatable = {}
        setmetatable(table, metatable)
    end

    function metatable.__newindex(t, k, v)
        Logger.LogErrorFormat("Cloud not change readonly tabl, key:{0}, value:{1}", k, v)
    end
end

table.Empty = {}
table.makeReadonly(table.Empty)

function list.concat(...)
    local r = {}
    for _, l in ipairs({ ... }) do
        for _, v in ipairs(l) do
            table.insert(r, v)
        end
    end
    return r
end

function _G.bind_self(func, self)
    
end