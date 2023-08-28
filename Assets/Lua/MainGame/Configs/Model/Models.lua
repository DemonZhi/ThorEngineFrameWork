local _key2index = {Id=1,Address=2,LODAddress=3,DefaultSubpartList=4,AnimationType=5,LoadType=6}

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

---@type ModelConfig[]
local _T=
{
    [1] = setmetatable({1,"pre_male_2110","",{8,21},0,0}, _o),
    [2] = setmetatable({2,"DropItem","",nil,0,0}, _o),
    [3] = setmetatable({3,"sword_soul_red","",nil,0,0}, _o),
    [5] = setmetatable({5,"pre_ms002","",nil,0,0}, _o),
    [6] = setmetatable({6,"pre_Ms007","",nil,0,0}, _o),
    [7] = setmetatable({7,"pre_Sm003","",nil,0,0}, _o),
    [8] = setmetatable({8,"pre_rw021","",nil,0,0}, _o),
    [9] = setmetatable({9,"pre_rw022","",nil,0,0}, _o),
    [10] = setmetatable({10,"pre_rw023","",nil,0,0}, _o),
    [11] = setmetatable({11,"pre_rw024","",nil,0,0}, _o),
    [12] = setmetatable({12,"pre_rw025","",nil,0,0}, _o),
    [13] = setmetatable({13,"pre_rw026","",nil,0,0}, _o),
    [14] = setmetatable({14,"pre_rw027","",nil,0,0}, _o),
    [15] = setmetatable({15,"pre_Sm000","",nil,0,0}, _o),
    [16] = setmetatable({16,"pre_female_2020","",{6,17},0,0}, _o),
    [20] = setmetatable({20,"3301","",nil,0,0}, _o),
    [21] = setmetatable({21,"pre_ms_gbl","",nil,0,0}, _o),
    [22] = setmetatable({22,"pre_ms_icedragon","",nil,0,0}, _o),
    [24] = setmetatable({24,"pre_male_2110","",{8,21},0,0}, _o),
    [25] = setmetatable({25,"pre_main_ms_lod1","",nil,0,0}, _o),
    [26] = setmetatable({26,"pre_main_zs_lod1","",nil,0,0}, _o),
    [27] = setmetatable({27,"pre_freeLich","",nil,1,0}, _o),
    [28] = setmetatable({28,"pre_freeLichNoInstance","",nil,0,0}, _o),
    [29] = setmetatable({29,"2041","",nil,0,0}, _o),
    [30] = setmetatable({30,"pre_male_2120","",{12,25},0,0}, _o),
    [31] = setmetatable({31,"pre_female_2010","",{1,14},0,0}, _o),
    [32] = setmetatable({32,"pre_npc_3202","",nil,0,0}, _o),
    [33] = setmetatable({33,"pre_npc_3206","",nil,0,0}, _o),
    [34] = setmetatable({34,"2060","",nil,0,0}, _o),
    [35] = setmetatable({35,"2357","",nil,0,0}, _o),
    [36] = setmetatable({36,"pre_role_1001_new","",{31},0,0}, _o),
    [37] = setmetatable({37,"pre_role_1001_nielian","",nil,0,0}, _o),
    [38] = setmetatable({38,"pre_sr5_kate","",nil,0,0}, _o),
    [39] = setmetatable({39,"pre_npc_3051","",nil,0,0}, _o),
    [40] = setmetatable({40,"2313","",nil,1,0}, _o),
    [41] = setmetatable({41,"pre_trigger_test01","",nil,0,1}, _o),

}

return _T