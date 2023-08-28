--根据Proto文件自动生成【工具：SGEngine/程序工具/网络/Proto导出工具一键生成】
local ProtoMsgFunc = {}


function SendCSStateMove(float_posX,float_posY,float_posZ,float_angle,int32_syncType)
	local msg = {posX = float_posX,posY = float_posY,posZ = float_posZ,angle = float_angle,syncType = int32_syncType}
	NetManager.SendMsg(OpCodeTypeEnum.CS_State_Move,msg)
end

function SendCSCorrectPosition(float_posX,float_posY,float_posZ,float_angle)
	local msg = {posX = float_posX,posY = float_posY,posZ = float_posZ,angle = float_angle}
	NetManager.SendMsg(OpCodeTypeEnum.PT_CORR_POS_HERO,msg)
end

function SendCSUseSkill(int32_skillId,int32_targetObjId)
	local msg = {skillId = int32_skillId,targetObjId = int32_targetObjId}
	NetManager.SendMsg(OpCodeTypeEnum.CS_Use_Skill,msg)
end

function SendCSChatInfoReq(int32_id,int32_channel,string_constr)
	local msg = {id = int32_id,channel = int32_channel,constr = string_constr}
	NetManager.SendMsg(OpCodeTypeEnum.CS_ChatInfo_Req,msg)
end

function SendCSSetupReq(uint32_qport,string_credential,int32_mtu,int32_ms,int32_retry,int32_max)
	local msg = {qport = uint32_qport,credential = string_credential,mtu = int32_mtu,ms = int32_ms,retry = int32_retry,max = int32_max}
	NetManager.SendMsg(OpCodeTypeEnum.CS_Setup_Req,msg)
end

function SendCSSelectOnWarReq(repeated_Role_roles)
	local msg = {roles = repeated_Role_roles}
	NetManager.SendMsg(OpCodeTypeEnum.CS_SelectOnWar_Req,msg)
end

return ProtoMsgFunc
