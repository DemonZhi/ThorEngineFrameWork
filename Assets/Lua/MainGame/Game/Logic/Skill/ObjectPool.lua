---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/8/31 11:31
---

local ObjectPool = class("ObjectPool")
function ObjectPool.CreatePool(class)
    local pool = ObjectPool.New()
    pool.m_Class = class
    pool.m_AvailableInstanceTable = {}
    return pool
end

function ObjectPool:Get()
    if #self.m_AvailableInstanceTable == 0 then
        local instance = self.m_Class.New()
        return instance
    end
    local instance = table.remove(self.m_AvailableInstanceTable)
    if instance.m_IsUsed == true then
        instance = self.m_Class.New()
    end
    instance.m_IsUsed = true
    return instance
end

function ObjectPool:Recycle(instance, isSkipTypeCheck)
    if not isSkipTypeCheck then
        if instance.__className == nil or instance.__className ~= self.m_Class.__className then
            return
        end
    end
    if instance.m_IsUsed == false then
        return
    end
    instance.m_IsUsed = false
    table.insert(self.m_AvailableInstanceTable, instance)
end

function ObjectPool:Destroy()
    self.m_AvailableInstanceTable = nil
end

return ObjectPool