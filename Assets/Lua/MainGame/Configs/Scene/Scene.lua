local _key2index = {Id=1,SceneName=2,SceneAddress=3,SceneType=4,DefaultMusicID=5,BornPosition=6,CameraConfigPath=7,IsOpenLookAt=8,IsOpenSprintCamera=9,IsOpenSwimCamera=10}

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

---@type SceneConfig[]
local _T=
{
    [0] = setmetatable({0,"绿林仙境","20001",3,412724438,{286, 38.4, 71},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [1] = setmetatable({1,"TestGaia","Gaia1",3,412724437,{198.7, 50.24, 185.7},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [2] = setmetatable({2,"圣心大教堂","scene_syc_church",3,412724438,{40.07, 12, 15},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [3] = setmetatable({3,"星空之城","scene_tkjjc",3,412724437,{70.645, 25.59, 39.033},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [4] = setmetatable({4,"Kate的家","scence_sr",3,412724438,{0, 1, 0},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [5] = setmetatable({5,"TestSLG","scene_slg",6,412724438,{512,37,512},"Assets/Art/CameraData/MOBACameraData.asset",0,0,0}, _o),
    [6] = setmetatable({6,"Login","Login",2,412724437,{0, 1, 0},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [7] = setmetatable({7,"回合制Demo","RTSDemo",5,412724437,{0, 0, 0},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),
    [8] = setmetatable({8,"龙宫","scene_hdjjc",3,412724437,{151.39,36.96,142.61},"Assets/Art/CameraData/RPGCameraData.asset",1,1,1}, _o),

}

return _T