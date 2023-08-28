local BaseImage = class("BaseImage")
local Core_Utility = SGEngine.Core.Utility
function BaseImage:BaseImageInit()
    self.m_AtlaName = nil
    self.m_Atla = nil
    self.m_SpriteName = nil
    self.m_Sprite = nil
    self.m_AtlasHandle = nil
end

function BaseImage:GetSprite(spriteName, atlasName, callback)

    -- 同一个sprite
    if spriteName == self.m_SpriteName then
        return
    end

    -- 同一个 spriteAtlas 图集
    if atlasName == self.m_AtlaName then
        self.m_Sprite = self.m_Atla:GetSprite(spriteName)
        self.m_SpriteName = spriteName
    end

    BaseImage.ClearCurHandle(self)
    -- 清空上次的图集
    self.m_AtlasHandle = Core_Utility.LoadSpriteAtlasAsync(
            atlasName,
            function(atla)

                self.m_AtlaName = atlasName
                self.m_Atla = atla

                self.m_Sprite = self.m_Atla:GetSprite(spriteName)
                self.m_SpriteName = spriteName
                callback(self.m_Sprite)
            end
    )
    -- Core_Utility.ReleaseHandle(self.m_AtlasHandle)
end

-- 清理自身图集信息
function BaseImage:ClearCurHandle()
    if self.m_AtlasHandle then
        Core_Utility.ReleaseHandle(self.m_AtlasHandle)
    end
    self.m_AtlaName = nil
    self.m_Atla = nil
    self.m_Sprite = nil
    self.m_AtlasHandle = nil
end


return BaseImage