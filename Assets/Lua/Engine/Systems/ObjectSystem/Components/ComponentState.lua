--Lua状态机
local ComponentDefine = require("Engine/Systems/ObjectSystem/Components/ComponentDefine")
local ComponentState = class("ComponentState", ComponentBase)

ComponentState.m_ComponentId = ComponentDefine.ComponentType.k_ComponentState
local StateStageDefine = { k_StateEnter = 0, k_StateUpdate = 1, k_StateExit = 2 }
local SyncConsts = ComponentDefine.SyncConsts
local Core_EntityUtility = SGEngine.Core.EntityUtility
local StateDefine = SGEngine.Core.StateDefine
local StateDefineMax = StateDefine.k_Max
local MonsterMoveSyncType = ComponentDefine.MoveSyncTypeMonster

function ComponentState:Init(object)
    ComponentState.__super.Init(self, object)
    self.m_CurrentStateSet = { 0, 0 }
    self.m_AllStates = {}
    self.m_DeserializedStatesParam = {}
    self:InitState(object)
end

function ComponentState:InitState(owner)
    if owner:IsMonster() then
        self.m_AllStates[StateDefine.k_StateIdle] = StateIdleMonster
        self.m_AllStates[StateDefine.k_StateMove] = StateMoveMonster
    elseif owner:IsPlayer() then
        self.m_AllStates[StateDefine.k_StateIdle] = StateIdle
        self.m_AllStates[StateDefine.k_StateRide] = StateRide
        self.m_AllStates[StateDefine.k_StateJump] = StateJump
        self.m_AllStates[StateDefine.k_StateDodge] = StateDodge
        local isHero = owner:IsHero()
        if isHero then
            self.m_AllStates[StateDefine.k_StateSwim] = StateSwimHero
            self.m_AllStates[StateDefine.k_StateMove] = StateMoveHero
            self.m_AllStates[StateDefine.k_StateCinema] = StateCinema
        else
            self.m_AllStates[StateDefine.k_StateSwim] = StateSwim3rd
            self.m_AllStates[StateDefine.k_StateMove] = StateMove3rd
        end
    end
    self.m_AllStates[StateDefine.k_StateDead] = StateDead
    self.m_AllStates[StateDefine.k_StateHit] = StateHit
    self.m_AllStates[StateDefine.k_StateHitFloat] = StateHitFloat
    self.m_AllStates[StateDefine.k_StatePull] = StatePull
    self.m_AllStates[StateDefine.k_StateSkill] = StateSkill
    self.m_AllStates[StateDefine.k_StateDaze] = StateDaze
    self.m_AllStates[StateDefine.k_StateCaught] = StateCaught
    self.m_AllStates[StateDefine.k_StateNavigate] = StateNavigation
    self.m_AllStates[StateDefine.k_StateFreeze] = StateFreeze

    for stateDefine, state in pairs(self.m_AllStates) do
        state.Ctor(owner, self)
    end
end

function ComponentState:Deserialize(netBuffer)
    local owner = self.m_Owner
    self:ClearCurrentState()
    owner.m_Core:DeleteAllState()
    ---Spirit owner = owner_ as Spirit;
    local num = netBuffer:ReadUByte()
    for i = 1, num do
        local stateDefine = netBuffer:ReadUByte()
        local data_num = netBuffer:ReadUByte()

        self.m_DeserializedStatesParam[stateDefine] = {}
        for i = 1, data_num do
            local id = netBuffer:ReadUByte()
            local data = netBuffer:ReadInt()

            ---set_param(index, id, data);
            self.m_DeserializedStatesParam[stateDefine][id] = data
        end

        if stateDefine == StateDefine.k_StateRide then
            local rideId = self.m_DeserializedStatesParam[StateDefine.k_StateRide][0]
            owner.m_RideComponent:OnGetOnRide(rideId)
        elseif stateDefine == StateDefine.k_StateSwim then
            if owner:IsHero() then
                owner:ChangeToSwim()
            else
                local syncInfo = {}
                local position = Vector3.New()
                local angle = 0
                position.x = math.floor(self.m_DeserializedStatesParam[stateDefine][0]) * SyncConsts.k_Int2FloatFactor
                position.y = math.floor(self.m_DeserializedStatesParam[stateDefine][1]) * SyncConsts.k_Int2FloatFactor
                position.z = math.floor(self.m_DeserializedStatesParam[stateDefine][2]) * SyncConsts.k_Int2FloatFactor
                angle = math.floor(self.m_DeserializedStatesParam[stateDefine][3]) * SyncConsts.k_Int2FloatFactor
                local clientAngle = Core_EntityUtility.ServerAngleToClientAngle(angle)
                local type = self.m_DeserializedStatesParam[stateDefine][5]
                syncInfo.m_TargetPosition = position
                syncInfo.m_SyncType = type
                syncInfo.m_Angle = clientAngle
                owner:OnSyncStateSwim(syncInfo)
            end
        elseif stateDefine == StateDefine.k_StateDead then
            owner:ChangeToDead()
        elseif stateDefine == StateDefine.k_StateMove then
            if owner:IsMonster() then
                local syncInfo = {}
                local position = Vector3.New()
                position.x = math.floor(self:GetStateDeserializedParam(stateDefine, 0)) * SyncConsts.k_Int2FloatFactor
                position.y = math.floor(self:GetStateDeserializedParam(stateDefine, 1)) * SyncConsts.k_Int2FloatFactor
                position.z = math.floor(self:GetStateDeserializedParam(stateDefine, 2)) * SyncConsts.k_Int2FloatFactor
                syncInfo.m_TargetPosition = position
                local angle = math.floor(self:GetStateDeserializedParam(stateDefine, 3)) * SyncConsts.k_Int2FloatFactor
                syncInfo.m_Angle = Core_EntityUtility.ServerAngleToClientAngle(angle)
                ---speed
                syncInfo.m_JoystickAngle = math.floor(self:GetStateDeserializedParam(stateDefine, 4)) * SyncConsts.k_Int2FloatFactor
                syncInfo.m_SyncType = math.floor(self:GetStateDeserializedParam(stateDefine, 5))
                --syncInfo.m_SyncType = MonsterMoveSyncType.k_Move
                owner:OnStateMoveGround(syncInfo)
            end
        end
    end
    self.m_DeserializedStatesParam = {}
end

function ComponentState:GetStateDeserializedParam(stateDefine, index)
    local stateParams = self.m_DeserializedStatesParam[stateDefine]
    if stateParams == nil then
        return 0
    end
    local value = stateParams[index]
    if value == nil then
       return 0
    end
    return value
end

function ComponentState:Destroy()
    self:ClearCurrentState()
    self.m_AllStates = {}
    ComponentState.__super.Destroy(self)
end

--三十二个state占用一个currentSet的data，与c#保持一致，index+1是因为lua集合下表从1开始
local function HasBit(dataSet, index)
    local currentIndex = (index >> 5) + 1
    local current = dataSet[currentIndex]
    local dest = 1 << index
    return (current & dest) > 0
end

local function SetBit(dataSet, index)
    local currentIndex = (index >> 5) + 1
    local current = dataSet[currentIndex]
    local dest = 1 << index
    current = current | dest
    dataSet[currentIndex] = current
end

local function RemoveBit(dataSet, index)
    local dest = 1 << index
    dest = ~dest
    local currentIndex = (index >> 5) + 1
    local current = dataSet[currentIndex]
    current = current & dest
    dataSet[currentIndex] = current
end

function ComponentState:Update(deltaTime)
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.Update(deltaTime, self.m_Owner, self)
            end
        end
    end
end

function ComponentState:LateUpdate()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.LateUpdate(self.m_Owner, self)
            end
        end
    end
end

function ComponentState:OnModelLoadComplete()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnModelLoadComplete(self.m_Owner, self)
            end
        end
    end
end

local function StateEnter(self, stateDefine)
    --Logger.LogInfo("StateEnter-> ".. stateDefine)
    local state = self.m_AllStates[stateDefine]
    if state == nil then
        return
    end
    state.Init(self.m_Owner, self)
    SetBit(self.m_CurrentStateSet, stateDefine)
end

local function StateExit(self, stateDefine)
    -- Logger.LogInfo("StateExit-> ".. stateDefine)
    local state = self.m_AllStates[stateDefine]
    if state == nil then
        return
    end
    state.Destroy(self.m_Owner, self)
    RemoveBit(self.m_CurrentStateSet, stateDefine)
end

function ComponentState:Dispatch(stateDefine, stateMsg)
    if stateMsg == StateStageDefine.k_StateEnter then
        StateEnter(self, stateDefine)
    elseif stateMsg == StateStageDefine.k_StateExit then
        StateExit(self, stateDefine)
    end
end

function ComponentState:OnBeginMove()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnBeginMove(self.m_Owner, self)
            end
        end
    end
end

function ComponentState:OnStopMove()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnStopMove(self.m_Owner, self)
            end
        end
    end
end

function ComponentState:GetState(stateDefine)
    return self.m_AllStates[stateDefine]
end

function ComponentState:ClearCurrentState()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.Destroy(self.m_Owner, self)
            end
        end
    end
    self.m_CurrentStateSet = { 0, 0 }
end

function ComponentState:OnSkillButtonDown(angle)
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnSkillButtonDown(self.m_Owner, self, angle)
            end
        end
    end
end

function ComponentState:OnSkillButtonMove(angle)
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnSkillButtonMove(self.m_Owner, self, angle)
            end
        end
    end
end

function ComponentState:OnSkillButtonUp()
    for i = 0, StateDefineMax do
        if HasBit(self.m_CurrentStateSet, i) then
            local state = self.m_AllStates[i]
            if state then
                state.OnSkillButtonUp(self.m_Owner, self)
            end
        end
    end
end

function ComponentState:Reset()
    self.m_Owner.m_Core:DeleteAllState()
    self:ClearCurrentState()
end

return ComponentState