---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2021/1/26 20:10
---

local StateConsts = {
     k_RunAnimationName = "run",
     k_RunStopAnimationName = "run_stop",
     k_BattleRunAnimationName = "battle_run",
     k_TorchRunAnimationName = "torch_run",
     k_SprintAnimationName = "sprint",
     k_SprintTurnAnimationName = "sprint_turn",
     k_SprintStopAnimationName = "sprint_stop",
     k_HitAnimationName = "hit",
     k_HitDownAnimationName = "hitdown",
     k_HitFlyAnimationName = "hitfly",
     k_HitFloatAnimationName = "hitfloat",
     k_IdleAnimationName = "stand",
     k_BattleIdleAnimationName = "guard",
     k_TorchIdleAnimationName = "torch_idle",
     k_OnBattleStandAnimationName = "stand_to_guard",
     k_OffBattleStandAnimationName = "guard_to_stand",
     k_OffBattleRunAnimationName = "off_battle_run",
     k_JumpAnimationName = "jump",
     k_DeadAnimationName = "die",
     k_DeathFliesAnimationName = "fly",
     k_WalkAnimationName = "walk",

     k_NormalToSprintMotorName = "NormalToSprint",
     k_SprintToNormalMotorName = "SprintToNormal",
     k_NormalMotorName = "3D",
     k_StandJumpPre = "jump_pre",
     k_StandJumpIdle = "jump_idle",
     k_StandJumpCast = "jump_cast",

     k_RunJumpPre = "run_jump_pre",
     k_RunJumpIdle = "run_jump_idle",
     k_RunJumpCast = "run_jump_cast",

     k_SprintJumpPre = "sprint_jump_pre",
     k_SprintJumpIdle = "sprint_jump_idle",
     k_SprintJumpCast = "sprint_jump_cast2",
     k_SprintJumpCastMove = "sprint_jump_cast",

     k_RideJumpPre = "ride_jump_pre",
     k_RideJumpIdle = "ride_jump_idle",
     k_RideJumpCast = "ride_jump_cast",

     k_DiveJumpPre = "run_swim_pre",
     k_DiveJumpIdle = "run_swim_idle",
     k_DiveJumpCast = "run_swim_cast",

     k_SwimIdle = "swim_idle",
     k_SwimMove = "swim",
     k_SwimSprint = "swim_sprint",
     k_SwimPoint = "v_swim",
     k_SwimDive = "swim",

     k_Daze = "stun",
     k_DodgeAnimationName = "dodge",
}

StateConsts.BattleStatus = 
{
     OnBattle = 1,
     OffBattle = 2
}

StateConsts.HitTypeEnum =
{
     NormalHit = 1,
     HitBack = 2,
     HitDown = 3,
     HitFly = 4,
     HitFloat = 5,
}

return StateConsts