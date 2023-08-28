MessageManager = MessageManager or {}
require("MainGame/Message/LoginMessage")
require("MainGame/Message/BattleMessage")
require("MainGame/Message/CreateRoleMessage")
require("MainGame/Message/GmMessage")
require("MainGame/Message/ItemMessage")
require("MainGame/Message/AvatarMessage")
require("MainGame/Message/ChatMessage")
require("MainGame/Message/SceneMessage")

function MessageManager.Init()
    --各自的模块在这里注册
    LoginMessage.Init()
    BattleMessage.Init()
    CreateRoleMessage.Init()
    GmMessage.Init()
    ItemMessage.Init()
    AvatarMessage.Init()
    ChatMessage.Init()
    SceneMessage.Init()
end

function MessageManager.Destroy()
	--各自的模块在这里注销
	LoginMessage.Destroy()
    BattleMessage.Destroy()
    CreateRoleMessage.Destroy()
    GmMessage.Destroy()
    ItemMessage.Destroy()
    AvatarMessage.Destroy()
    ChatMessage.Destroy()
    SceneMessage.Destroy()
end

return MessageManager