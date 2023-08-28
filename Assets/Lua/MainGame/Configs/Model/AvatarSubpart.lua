local _key2index = {Id=1,SysType=2,SubpartType=3,GenderArray=4,JobArray=5,IconName=6,PrefabAddress=7,MountPointPath=8,BoneConfigAddress=9}

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

---@type AvatarSubpartConfig[]
local _T=
{
    [1] = setmetatable({1,{1},2,{2},{1},"Fashion_Clothes_1001","pre_female_2010_01_body","","avatar_config_pre_female_2010_01_body"}, _o),
    [2] = setmetatable({2,{1},2,{2},{1},"Fashion_Clothes_1002","pre_female_2010_02_body","","avatar_config_pre_female_2010_02_body"}, _o),
    [3] = setmetatable({3,{1},2,{2},{1},"Clothes_1001","pre_female_2010_03_body","","avatar_config_pre_female_2010_03_body"}, _o),
    [4] = setmetatable({4,{1},2,{2},{1},"Clothes_1003","pre_female_2010_04_body","","avatar_config_pre_female_2010_04_body"}, _o),
    [5] = setmetatable({5,{1},2,{2},{1},"Clothes_1001","pre_female_2010_05_body","","avatar_config_pre_female_2010_05_body"}, _o),
    [6] = setmetatable({6,{1},2,{2},{2},"Clothes_4001","pre_female_2020_01_body","","avatar_config_pre_female_2020_01_body"}, _o),
    [7] = setmetatable({7,{1},2,{2},{2},"Clothes_4002","pre_female_2020_02_body","","avatar_config_pre_female_2020_02_body"}, _o),
    [8] = setmetatable({8,{1},2,{1},{1},"Fashion_Clothes_1001_man","pre_male_2110_01_body","","avatar_config_pre_male_2110_01_body"}, _o),
    [9] = setmetatable({9,{1},2,{1},{1},"Clothes_1001_man","pre_male_2110_02_body","","avatar_config_pre_male_2110_02_body"}, _o),
    [10] = setmetatable({10,{1},2,{1},{1},"Clothes_1003_man","pre_male_2110_03_body","","avatar_config_pre_male_2110_03_body"}, _o),
    [11] = setmetatable({11,{1},2,{1},{1},"Clothes_1002_man","pre_male_2110_04_body","","avatar_config_pre_male_2110_04_body"}, _o),
    [12] = setmetatable({12,{1},2,{1},{2},"Clothes_4001_man","pre_male_2120_01_body","","avatar_config_pre_male_2120_01_body"}, _o),
    [13] = setmetatable({13,{1},2,{1},{2},"Clothes_4002_man","pre_male_2120_02_body","","avatar_config_pre_male_2120_02_body"}, _o),
    [14] = setmetatable({14,{1},1,{2},{1},"Fashion_Hair_1001","2010_01_Hair","Bip001 Head",""}, _o),
    [15] = setmetatable({15,{1},1,{2},{1},"Hair_1002","2010_02_Hair","Bip001 Head",""}, _o),
    [16] = setmetatable({16,{1},1,{2},{1},"Hair_1001","2010_03_Hair","Bip001 Head",""}, _o),
    [17] = setmetatable({17,{1},1,{2},{2},"Hair_4002","2020_01_Hair","Bip001 Head",""}, _o),
    [18] = setmetatable({18,{1},1,{2},{2},"Fashion_Hair_1005","2020_02_Hair","Bip001 Head",""}, _o),
    [19] = setmetatable({19,{1},1,{2},{2},"Fashion_Hair_1006","2020_03_Hair","Bip001 Head",""}, _o),
    [20] = setmetatable({20,{1},1,{2},{2},"Hair_4001","2020_04_Hair","Bip001 Head",""}, _o),
    [21] = setmetatable({21,{1},1,{1},{1},"Fashion_Hair_1001_man","2110_01_Hair","Bip001 Head",""}, _o),
    [22] = setmetatable({22,{1},1,{1},{1},"Hair_1001_man","2110_02_Hair","Bip001 Head",""}, _o),
    [23] = setmetatable({23,{1},1,{1},{1},"Hair_1002_man","2110_03_Hair","Bip001 Head",""}, _o),
    [24] = setmetatable({24,{1},1,{1},{1},"Hair_4001_man","2110_04_Hair","Bip001 Head",""}, _o),
    [25] = setmetatable({25,{1},1,{1},{2},"Hair_4002_man","2120_01_Hair","Bip001 Head",""}, _o),
    [26] = setmetatable({26,{1},3,{1,2},{1},"Weapon_1001","weapon_01_01","",""}, _o),
    [27] = setmetatable({27,{1},3,{1,2},{1},"Weapon_1003","weapon_01_02","",""}, _o),
    [28] = setmetatable({28,{1},3,{1,2},{2},"Weapon_4002","weapon_02_01","",""}, _o),
    [29] = setmetatable({29,{1},3,{1,2},{2},"Weapon_4001","weapon_02_02","",""}, _o),
    [30] = setmetatable({30,{1},3,{1,2},{2},"Weapon_4003","weapon_02_03","",""}, _o),
    [31] = setmetatable({31,{1},2,{2},{2},"Clothes_4002","pre_role_skin_1002","",""}, _o),

}

return _T