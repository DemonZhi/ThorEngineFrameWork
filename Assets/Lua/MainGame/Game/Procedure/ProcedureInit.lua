ProcedureInit = ProcedureInit or {}

function ProcedureInit.Init()
    AndroidUtil.CheckAndroidSimulatorWithCallBack(DeviceUtil.OnAndroidSimulatorNotified)
    DeviceUtil.AutoSetRenderingQuality()
    ProcedureHandler.Init()
end

function ProcedureInit.Enter()
    ProcedureInit.InitCollisionLayer()
    EffectManager.RegisterAllEffectToStaticInstantiateCallback()
    
    ProcedureManager.ChangeProcedure(ProcedureTypeEnum.Login)
end

function ProcedureInit.Update(deltaTime)

end

function ProcedureInit.Leave()

end

function ProcedureInit.Destroy()
    ProcedureHandler.Destroy()
end


function ProcedureInit.InitCollisionLayer()
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Monster'), LayerMask.NameToLayer('Hero'))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Monster'), LayerMask.NameToLayer('Player'))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Player'), LayerMask.NameToLayer('Hero'))
    --Physics.IgnoreLayerCollision(LayerMask.NameToLayer("Hero"), LayerMask.NameToLayer("Default"))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Hero'), LayerMask.NameToLayer('Water'))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Hero'), LayerMask.NameToLayer('Hero'))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Player'), LayerMask.NameToLayer('Player'))
    Physics.IgnoreLayerCollision(LayerMask.NameToLayer('Hero'), LayerMask.NameToLayer('Trigger'))
end

return ProcedureInit