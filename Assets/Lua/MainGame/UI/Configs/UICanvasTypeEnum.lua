local s_menuIndex = 0
local function MenuIndex()
    s_menuIndex = s_menuIndex + 1
    return s_menuIndex
end

---@class UICanvasTypeEnum
local UICanvasTypeEnum =
{
    -- 遥感层
    JoyStickLayer = MenuIndex(),

    -- 场景层
    SceneLayer = MenuIndex(),
    LowMainLayer = MenuIndex(),

    -- 主界面层
    MainLayer = MenuIndex(),


}