local k_MakeupView = 'MakeupView'
local k_MODView = 'MODView'

MakeupController = MakeupController or {}

function MakeupController.Init()
end

function MakeupController.RegisterCommand()
end

function MakeupController.GetViewsName()
    return {k_MakeupView}
end

function MakeupController.OpenView()
    UIManager.OpenUI(k_MakeupView)
end

function MakeupController.CloseView()
    UIManager.CloseUI(k_MakeupView)
end

function MakeupController.GetMakeupView()
    UIManager.GetUI(k_MakeupView)
end

function MakeupController.RefreshTypeView()
    local makeupView = UIManager.GetUI(k_MakeupView)
    if makeupView ~= nil and makeupView:IsActive() then
        makeupView:RefreshTypeView()
    end
end

function MakeupController.RefreshStyleView(index)
    local makeupView = UIManager.GetUI(k_MakeupView)
    if makeupView ~= nil and makeupView:IsActive() then
        makeupView:RefreshStyleView(index)
    end
end

function MakeupController.RefreshGridView(index)
    local makeupView = UIManager.GetUI(k_MakeupView)
    if makeupView ~= nil and makeupView:IsActive() then
        makeupView:RefreshGridView(index)
    end
end

function MakeupController.RefreshSliderView(data)
    local makeupView = UIManager.GetUI(k_MakeupView)
    if makeupView ~= nil and makeupView:IsActive() then
        makeupView:RefreshSliderView(data)
    end
end

function MakeupController.GetSGUIModel()
    if ProcedureCreateRole and ProcedureCreateRole.m_ShowObj and  ProcedureCreateRole.m_ShowObj.m_Core then
        return ProcedureCreateRole.m_ShowObj.m_Core
    else
        return nil
    end
end

function MakeupController.GetUIModelMakeupComponent()
    if ProcedureCreateRole then
        local componentFaceMakeup = ProcedureCreateRole.m_ComponentFaceMakeup
        
        if componentFaceMakeup then
            return componentFaceMakeup
        else
            return nil
        end
    else
        return nil
    end
end

function MakeupController.SetFaceBlendShapeValue(id, value)
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        componentFaceMakeup:SetFaceBlendShapeValue(id, value)
    end
end

function MakeupController.GetFaceBlendShapeByIndex(id)
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        return componentFaceMakeup:GetBlendShapeByIndex(id)
    end

    return 0
end

function MakeupController.RefreshFace()
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        componentFaceMakeup:RefreshFace()
    end
end

function MakeupController.FocusModel()

    local model = MakeupController.GetSGUIModel()
    if model then
        model:ActivateMotorWithName('Makeup')
        local offset = MakeupController.model:GetEnterCameraOffset()
        model:SetAnchorHeight(offset)
    end
end

function MakeupController.UnFocusModel()
    local model = MakeupController.GetSGUIModel()
    if model then
        model:ActivateMotorWithName('CreateRole')
        local offset = MakeupController.model:GetLeaveCameraOffset()
        model:SetAnchorHeight(offset)
    end
end

function MakeupController.GetFaceBlendShapeList()
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        return componentFaceMakeup:GetFaceBlendShapeList()
    end

    return {}
end

function MakeupController.GetFaceTextureIndexList()
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        return componentFaceMakeup:GetFaceTextureIndexList()
    end
    return {}
end

function MakeupController.SetFaceMakeupData(type, value)
    local componentFaceMakeup = MakeupController.GetUIModelMakeupComponent()
    if componentFaceMakeup then
        componentFaceMakeup:SetFaceMakeupData(type, value)
    end
end

function MakeupController.SetGender(gender)
    MakeupController.model:SetGender(gender)
end

function MakeupController.GetGender()
    return MakeupController.model:GetGender()
end

function MakeupController.SetRoleJobID(id)
    MakeupController.model:SetRoleJobID(id)
end

function MakeupController.GetRoleJobID()
    return MakeupController.model:GetRoleJobID()
end

function MakeupController.OpenMODView()
    UIManager.OpenUI(k_MODView)
end

function MakeupController.CloseMODView()
    UIManager.CloseUI(k_MODView)
end

function MakeupController.PinchFace(config, value)
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:PichFacce(config, value)
    end
end

function MakeupController.BakeFace(facialID)
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:BakeFace(facialID)
    end
end

function MakeupController.SetFaceMakeupValue(makeupType, value, iLatitudeType, iMakeupID)
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:SetFaceMakeupValue(makeupType, value, iLatitudeType, iMakeupID)
    end
end

function MakeupController.RefreshModViewFace()
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:RefreshFace()
    end
end

function MakeupController.GetUIComponentFaceMakeUp()
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        return modView:GetUIComponentFaceMakeUp()
    end
end

function MakeupController.ChangePart(index)
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:ChangePart(index)
    end
end

function MakeupController.StopFaceCustomizeMask()
    local modView = UIManager.GetUI(k_MODView)
    if modView then 
        modView:StopFaceCustomizeMask()
    end
end

return MakeupController