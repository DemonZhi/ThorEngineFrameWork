--- @class ImageLoader
local ImageLoader = class("ImageLoader")

local k_AssetImage = 1
local k_AssetRawImage = 2

function ImageLoader:Ctor()
    self.m_IsLoading = false
    self.m_AssetType = 0
    self.m_Image = nil
    self.m_Callback = nil
    self.m_ImagePath = nil
    self.m_Asset = nil
    self.m_OnLoadComplete = function(asset, imagePath)
        self:OnLoadComplete(asset, imagePath)
    end
end

function ImageLoader:LoadImage(image, imagePath, loadCallback)
    -- 资源相同不加载
    if self.m_ImagePath == imagePath then
        -- loading==false 说明资源已加载完成，执行回调
        if self.m_IsLoading == false then
            if loadCallback then
                loadCallback(image)
            end
        end
        return
    end
    self.m_Image = image
    self.m_AssetType = k_AssetImage
    self.m_Callback = loadCallback
    self.m_ImagePath = imagePath
    self.m_IsLoading = true
    ResourceManager.LoadSpriteAsync(self.m_ImagePath, self.m_OnLoadComplete, imagePath)
end

function ImageLoader:LoadRawImage(rawImage, imagePath, loadCallback)
    -- 资源相同不加载
    if self.m_ImagePath == imagePath then
        -- loading==false 说明资源已加载完成，执行回调
        if self.m_IsLoading == false then
            if loadCallback then
                loadCallback(rawImage)
            end
        end
        return
    end
    self.m_Image = rawImage
    self.m_ImagePath = imagePath
    self.m_Callback = loadCallback
    self.m_AssetType = k_AssetRawImage
    self.m_IsLoading = true
    ResourceManager.LoadTextureAsync(self.m_ImagePath, self.m_OnLoadComplete, imagePath)
end

function ImageLoader:OnLoadComplete(asset, imagePath)
    if self.m_ImagePath ~= imagePath then
        self:ReleaseAsset(asset, self.m_AssetType)
        return
    end
    self.m_IsLoading = false
    if self.m_Asset then
        self:ReleaseAsset(self.m_Asset, self.m_AssetType)
        self.m_Asset = nil
    end
    self.m_Asset = asset
    if self.m_AssetType == k_AssetImage then
        self.m_Image.sprite = asset
    elseif self.m_AssetType == k_AssetRawImage then
        self.m_Image.texture = asset
    end
    if self.m_Callback then
        self.m_Callback(self.m_Image)
    end
end

function ImageLoader:Destroy()
    if self.m_Asset then
        self:ReleaseAsset(self.m_Asset, self.m_AssetType)
    end
    self.m_Asset = nil
    self.m_Image = nil
    self.m_ImagePath = nil
    self.m_Callback = nil
    self.m_AssetType = 0
    self.m_IsLoading = false
end

function ImageLoader:ReleaseAsset(asset, iAssetType)
    if iAssetType == k_AssetImage then
        ResourceManager.ReleaseSprite(asset)
    elseif iAssetType == k_AssetRawImage then
        ResourceManager.ReleaseTexture(asset)
    end
end

return ImageLoader