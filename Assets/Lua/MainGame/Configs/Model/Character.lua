local _key2index = {Id=1,HitAnim=2,MoveSpeed=3,RotateSpeed=4,SprintSpeed=5,SprintTurnAngle=6,SprintRotateSpeed=7,JumpHeight=8,SprintJumpHeight=9,SpringJumpAddYSpeedFactor=10,SpringJumpAddXZSpeedFactor=11,SpringJumpGravityFactor=12,CheckRunJumpSpeed=13,CheckSprintJumpSpeed=14,RideAddGravityFactor=15,FallGravity=16,FallHeight=17,SwimRotateSpeed=18,SwimSpeed=19,SwimSprintSpeed=20,SwimSprintRotateSpeed=21,SwimSprintAcceleration=22,SwimSprintTime=23,SwimDiveSpeed=24,InWaterOffset=25,InWaterDepth=26,ExitWaterDepth=27,CameraAnchorHeight=28,RideCameraAnchorHeight=29,CloseupAnchorHeight=30,SwimIdleEffectId=31,SwimEffectId=32,SwimSprintEffectId=33,JumpWaveStrength=34}

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

---@type CharacterConfig[]
local _T=
{
    [-1] = setmetatable({-1,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.35,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.45,2005,2006,2007,-15}, _o),
    [15] = setmetatable({15,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.6,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.45,2005,2006,2007,-15}, _o),
    [16] = setmetatable({16,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.6,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.35,2.4,1.5,2005,2006,2007,-15}, _o),
    [17] = setmetatable({17,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.6,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.45,2005,2006,2007,-15}, _o),
    [23] = setmetatable({23,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.6,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.65,2005,2006,2007,-15}, _o),
    [24] = setmetatable({24,{"hit"},6,675,9,130,405,2,3.5,1.5,1.2,0.35,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.55,2005,2006,2007,-15}, _o),
    [29] = setmetatable({29,{"hit"},6,675,9,130,405,0.5,0.5,1.5,1.2,0.35,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.55,2005,2006,2007,-15}, _o),
    [34] = setmetatable({34,{"hit"},6,675,9,360,405,4,7,1.5,1.2,0.35,0.05,8,0.7,50,0.3,180,4,5,100,3,2,1,1.5,1.4,1.3,1.45,2.4,1.55,2005,2006,2007,-15}, _o),

}

return _T