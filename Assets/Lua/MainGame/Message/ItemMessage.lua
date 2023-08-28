ItemMessage = ItemMessage or {}

function ItemMessage.Init()
    ClientNetManager.Register(Message.ST_ADD_ITEM, ItemMessage.OnAddItem)
    ClientNetManager.Register(Message.ST_REMOVE_ITEM, ItemMessage.OnRemoveItem)
    ClientNetManager.Register(Message.ST_UPDATE_ITEM, ItemMessage.OnUpdateItem)
    ClientNetManager.Register(Message.ST_MISC_MSG_RESULT, ItemMessage.OnMiscMsg)
end

function ItemMessage.Destroy()
    ClientNetManager.UnRegister(Message.ST_ADD_ITEM, ItemMessage.OnAddItem)
    ClientNetManager.UnRegister(Message.ST_REMOVE_ITEM, ItemMessage.OnRemoveItem)
    ClientNetManager.UnRegister(Message.ST_UPDATE_ITEM, ItemMessage.OnUpdateItem)
    ClientNetManager.UnRegister(Message.ST_MISC_MSG_RESULT, ItemMessage.OnMiscMsg)
end

function ItemMessage.OnAddItem(buffer)
    local objID = buffer:ReadInt()
    local badType = buffer:ReadUByte()
    ComponentBag.DeserializeSingleItem(buffer)

    --TODO
end

function ItemMessage.OnRemoveItem(buffer)
    local objID = buffer:ReadInt()
    local bagType = buffer:ReadUByte()
    local index = buffer:ReadInt()

    --TODO
end

function ItemMessage.OnUpdateItem(buffer)
    local objID = buffer:ReadInt()
    local bagType = buffer:ReadUByte()
    local index = buffer:ReadInt()

    --TODO
end

function ItemMessage.OnMiscMsg(buffer)
    local msgID = buffer:ReadInt()
    local contentNum = buffer:ReadByte()
    --string[] args = new string[arg_num]
    for i = 1, contentNum do
        local content = buffer:ReadString()
    end
end

return ItemMessage
