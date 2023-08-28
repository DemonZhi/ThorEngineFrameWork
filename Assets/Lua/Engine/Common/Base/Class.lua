---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/6/29 10:44
---
local class = function (className, super)

    if type(className) ~= "string" then
        error("class name must string type")
    end

    local cls = {__className = className, __isClass = true}
    if type(super) == "table" then
        if not cls.__super then
            cls.__super = super
        end
    end

    cls.__index = cls
    if cls.__super then
        setmetatable(cls, {__index = cls.__super})
    end

    cls.Ctor = function ( ... )
        -- default constructor
    end

    cls.New = function ( ... )
        local instance = {}
        setmetatable(instance, {__index = cls})
        instance.__class = cls
        instance:Ctor(...)
        return instance
    end

    cls.Create = function ( ... )
        return cls:New(...)
    end

    return cls
end

return class