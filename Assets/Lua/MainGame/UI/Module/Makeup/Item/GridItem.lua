local GridItem = class('GridItem', BaseItem)


function GridItem:InitUI()
    self:AddButtonListener(self.btnGrid, function ()
        self.texture = ResourceManager.LoadTexture(self.path)
        MakeupController.SetFaceMakeupData(self.type, self.texture)  
    end)
end

function GridItem:OnGUI(itemData)
    self.imageGrid.color = itemData.color
    self.imageGrid.sprite = ResourceManager.LoadSprite(itemData.sprite)
    self.path = itemData.path
    self.type = itemData.type
    self.texture = null
end

function GridItem:OnDestroy()
    --to do remove texture
    if self.texture then
        ResourceManager.ReleaseTexture(self.texture)
    end

    if self.imageGrid.sprite then
        ResourceManager.ReleaseSprite(self.imageGrid.sprite)
    end
end


return GridItem