GmMessage = GmMessage or {}

function GmMessage.Init()
end

function GmMessage.Destroy()
end

function GmMessage.SendGmCommand(funcName, args)
    local buffer = ClientNetManager.GetSendBuffer(Message.PT_GM_MSG)
    buffer:WriteString(funcName)
    buffer:WriteString(args)
    ClientNetManager.Send(buffer)
end

return GmMessage
