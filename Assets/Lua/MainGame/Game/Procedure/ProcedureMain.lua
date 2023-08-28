ProcedureMain = ProcedureMain or {}

function ProcedureMain.Init()

end

function ProcedureMain.Enter()
    LoadingController.AddOtherLoader(ProcedureMain, "正在加载主角..")
end

function ProcedureMain.Update(deltaTime)

end

function ProcedureMain.Leave()
    --释放对象池
    ObjectManager.Restart()
end

function ProcedureMain.Destroy()

end

function ProcedureMain.IsChangeSceneTaskDone()
    local hero = ObjectManager.GetHero()
    if hero == nil then
        return false
    end
    if hero:IsModelLoadFinish() == true then
        return true
    end
    return false
end

return ProcedureMain