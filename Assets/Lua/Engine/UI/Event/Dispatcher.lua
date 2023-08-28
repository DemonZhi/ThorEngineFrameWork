Dispatcher = Dispatcher or {}

local k_HandlerIndex = 1
local k_ParamsIndex = 2

function Dispatcher.Init()
	Dispatcher.m_EventDic = {}
end

--添加监听事件
function Dispatcher.AddEventListener(event, handler, params)
	local handlers = Dispatcher.m_EventDic[event] or {}
	for i=1,#handlers do
		if handler == handlers[i][k_HandlerIndex] then 
			Logger.LogErrorFormat("[Dispatcher](AddEventListener)重复添加回调事件!")
			return
		end
	end

	local vo = {handler, params}
	table.insert(handlers,vo)
	if event == nil then 
		Logger.LogErrorFormat("[Dispatcher](AddEventListener)未定义事件!")
	end
	Dispatcher.m_EventDic[event] = handlers
end

--删除监听事件
function Dispatcher.RemoveEventListener(event, handler)
	if handler == nil then 
		Dispatcher.m_EventDic[event] = nil
		return
	end

	local handlers = Dispatcher.m_EventDic[event]
	if handlers == nil then return end
	for i=#handlers, 1, -1 do
		if handlers[i][k_HandlerIndex] == handler then 
			table.remove(handlers, i)
			return
		end
	end
end

--事件分发
function Dispatcher.Dispatch(event, ...)
	local handlers = Dispatcher.m_EventDic[event]
	local params = {...}

	if handlers ~= nil then
		for i = #handlers, 1, -1 do
		 	if handlers[i][k_ParamsIndex] == nil then 
		 		handlers[i][k_HandlerIndex](table.unpack(params))
		 	else
		 		handlers[i][k_HandlerIndex](handlers[i][k_ParamsIndex],table.unpack(params))
		 	end
		end 
	end
end

return Dispatcher