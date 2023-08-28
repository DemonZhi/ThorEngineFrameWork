local _key2index = {ID=1,CID=2,StepID=3,StepType=4,Name=5,IsEnd=6,StepJump=7,Dialogue=8,TimeLinePath=9,CustomTimeLinePosition=10,TimeLinePosition=11,NpcList=12,CustomNpcPositionRotation=13,AutoDestoryNPC=14,SelectTitleList=15,SelectJumpStepList=16,NodePosition=17}

local _o = 
{
    __index = function(myTable, key)
        local temp = _key2index[key]
        if temp == nil then
            --error("don't have the key in the table, key = "..key)
            return nil
        end
        return myTable[temp]
    end,
    __newindex = function(myTable, key, value)
        error("can't modify read-only table!")
    end
}

---@type CinemaConfigs[]
local _T=
{
    [2001] = setmetatable({2001,2,1,0,"琛哥问",0,2,"琛哥：是他吗？","",0,nil,nil,0,0,nil,nil,{361,31}}, _o),
    [2002] = setmetatable({2002,2,2,2,"星驰回",0,-1,"周星驰：”内衣裤拖鞋是挺标新立异的，好好干应该会有前途”","",0,nil,nil,0,0,{"看琛哥","看邪神"},{3,4},{358,90}}, _o),
    [2003] = setmetatable({2003,2,3,1,"表演",0,5,"","Assets/Art/TimeLine/Prefab/TestTimeLine02.prefab",0,{364.4,13.7,94},{2},0,1,nil,nil,{277,153}}, _o),
    [2004] = setmetatable({2004,2,4,0,"邪神",0,-1,"邪神：“用力！”","",0,nil,nil,0,0,nil,nil,{480,154}}, _o),
    [2005] = setmetatable({2005,2,5,0,"琛哥",0,6,"琛哥：“去你妈的是不是救错人了！”","",0,nil,nil,0,0,nil,nil,{275,227}}, _o),
    [2006] = setmetatable({2006,2,6,2,"星驰",0,-1,"周星驰：“绝对没有啊，琛哥，我都是按你吩咐做的，哎！火云邪神，漏俩手啊！？”","",0,nil,nil,0,0,{"看琛哥","看邪神"},{7,8},{272,295}}, _o),
    [2007] = setmetatable({2007,2,7,0,"琛哥",0,9,"琛哥：“？？？？？“","",0,nil,nil,0,0,nil,nil,{191,376}}, _o),
    [2008] = setmetatable({2008,2,8,0,"星驰",0,10,"周星驰：”老伯！沙包大的拳头见过没有啊你！不要逼我出手啊！“","",0,nil,nil,0,0,nil,nil,{368,371}}, _o),
    [2009] = setmetatable({2009,2,9,0,"琛哥",0,6,"琛哥：”看我？！看他啦！！我顶你个肺！“","",0,nil,nil,0,0,nil,nil,{185,461}}, _o),
    [2010] = setmetatable({2010,2,10,0,"邪神",0,-1,"邪神：”是吗？出手吧“","",0,nil,nil,0,0,nil,nil,{373,456}}, _o),

}

return _T