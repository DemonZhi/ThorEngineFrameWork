local Core_HexOutLineManagerInstance = SGEngine.Core.HexOutLineManager.Instance

OutlineManager = OutlineManager or {}


function OutlineManager.BeforeChangeScene(prevSceneType, nextSceneType)
    
end

function OutlineManager.AfterChangeScene(prevSceneType, nextSceneType)
    --slg Scene Draw Line
    --Logger.LogErrorFormat("OutlineManager AfterChangeScene nextSceneType:"..tostring(nextSceneType))
    if nextSceneType == 6 then
        Core_HexOutLineManagerInstance:StartDrawOutline()
    else
        Core_HexOutLineManagerInstance:StopDrawOutline()
    end    
end

function OutlineManager.SetNodeInObstacle(obstacleObject, layerMask, color)
    Core_HexOutLineManagerInstance:ChangeNodeColor(obstacleObject, layerMask, color)
end

return OutlineManager