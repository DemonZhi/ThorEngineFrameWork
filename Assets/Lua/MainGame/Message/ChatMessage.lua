ChatMessage = ChatMessage or {}

function ChatMessage.Init()
    ClientNetManager.Register(Message.ST_SHOW_HEAD_DIALOG, ChatMessage.OnShowHeadDialog)
    ClientNetManager.Register(Message.ST_CHAT_MSG, ChatMessage.OnShowChatMessage)
end

function ChatMessage.Destroy()
    ClientNetManager.UnRegister(Message.ST_SHOW_HEAD_DIALOG, ChatMessage.OnShowHeadDialog)
    ClientNetManager.UnRegister(Message.ST_CHAT_MSG, ChatMessage.OnShowChatMessage)
end

function ChatMessage.OnShowHeadDialog(buffer)
    local objID = buffer:ReadInt()
    local isShow = buffer:ReadUByte() > 0
    local dialogueID = buffer:ReadInt()
    local object = ObjectManager.GetObject(objID)
    --Logger.LogInfo("[ChatMessage](OnShowHeadDialog), objID : %s, isShow:%s, dialogueID:%s", objID, isShow, dialogueID)
    if not object then
        return
    end

    local dialogueConfig = DialogueConfig[dialogueID]
    if not dialogueConfig then
        return
    end
    local hudComponent = object.m_HUDComponent
    if not hudComponent then
        return
    end
    hudComponent:SetDialogueContent(dialogueConfig.Content)
    hudComponent:SetDialogueEnable(isShow)
end

function ChatMessage.OnShowChatMessage(buffer)
    -- TODO: Chat Message Deseralize
end

return ChatMessage
