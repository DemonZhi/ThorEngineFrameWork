--1.通用方法庫
--2.Lua这边通用方法放在这边
CommonUtil = CommonUtil or {}

--返回新的函数，调用func时将self作为第一个参数传入
function CommonUtil.GetSelfFunc(self, func)
  if nil == func then
    return
  end
  local retFunc = function(...)
    func(self, ...)
  end

  return retFunc
end

return CommonUtil