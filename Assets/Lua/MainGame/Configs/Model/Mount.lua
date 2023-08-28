local _key2index = {Id=1,ResourceId=2,MoveSpeed=3,RotateSpeed=4,JumpHeight=5,JumpSpeed=6,IdleAnimation=7,RunAnimation=8,RunStopAnimation=9,JumpPreAnimation=10,JumpIdleAnimation=11,JumpCastAnimation=12}

local _o = 
{
    __index = function(myTable, key)
        local temp = _key2index[key]
        if temp == nil then
            --error("don't have the key in the table, key = "..key)
            return nil
        end
        return myTable[temp]
    end,
    __newindex = function(myTable, key, value)
        error("can't modify read-only table!")
    end
}

---@type MountConfig[]
local _T=
{
    [1] = setmetatable({1,20,8,575,1,10,"idle_horse","run_horse","ride_run_stop","ride_jump_pre","ride_jump_idle","ride_jump_cast"}, _o),

}

return _T