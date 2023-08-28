﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_TimeWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("Time");
		L.RegVar("time", get_time, null);
		L.RegVar("timeAsDouble", get_timeAsDouble, null);
		L.RegVar("timeSinceLevelLoad", get_timeSinceLevelLoad, null);
		L.RegVar("timeSinceLevelLoadAsDouble", get_timeSinceLevelLoadAsDouble, null);
		L.RegVar("deltaTime", get_deltaTime, null);
		L.RegVar("fixedTime", get_fixedTime, null);
		L.RegVar("fixedTimeAsDouble", get_fixedTimeAsDouble, null);
		L.RegVar("unscaledTime", get_unscaledTime, null);
		L.RegVar("unscaledTimeAsDouble", get_unscaledTimeAsDouble, null);
		L.RegVar("fixedUnscaledTime", get_fixedUnscaledTime, null);
		L.RegVar("fixedUnscaledTimeAsDouble", get_fixedUnscaledTimeAsDouble, null);
		L.RegVar("unscaledDeltaTime", get_unscaledDeltaTime, null);
		L.RegVar("fixedUnscaledDeltaTime", get_fixedUnscaledDeltaTime, null);
		L.RegVar("fixedDeltaTime", get_fixedDeltaTime, set_fixedDeltaTime);
		L.RegVar("maximumDeltaTime", get_maximumDeltaTime, set_maximumDeltaTime);
		L.RegVar("smoothDeltaTime", get_smoothDeltaTime, null);
		L.RegVar("maximumParticleDeltaTime", get_maximumParticleDeltaTime, set_maximumParticleDeltaTime);
		L.RegVar("timeScale", get_timeScale, set_timeScale);
		L.RegVar("frameCount", get_frameCount, null);
		L.RegVar("renderedFrameCount", get_renderedFrameCount, null);
		L.RegVar("realtimeSinceStartup", get_realtimeSinceStartup, null);
		L.RegVar("realtimeSinceStartupAsDouble", get_realtimeSinceStartupAsDouble, null);
		L.RegVar("captureDeltaTime", get_captureDeltaTime, set_captureDeltaTime);
		L.RegVar("captureFramerate", get_captureFramerate, set_captureFramerate);
		L.RegVar("inFixedTimeStep", get_inFixedTimeStep, null);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_time(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.time);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_timeAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.timeAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_timeSinceLevelLoad(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.timeSinceLevelLoad);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_timeSinceLevelLoadAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.timeSinceLevelLoadAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_deltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.deltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedTimeAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedTimeAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_unscaledTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.unscaledTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_unscaledTimeAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.unscaledTimeAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedUnscaledTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedUnscaledTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedUnscaledTimeAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedUnscaledTimeAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_unscaledDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.unscaledDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedUnscaledDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedUnscaledDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fixedDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.fixedDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maximumDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.maximumDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_smoothDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.smoothDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maximumParticleDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.maximumParticleDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_timeScale(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.timeScale);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_frameCount(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, UnityEngine.Time.frameCount);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderedFrameCount(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, UnityEngine.Time.renderedFrameCount);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_realtimeSinceStartup(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.realtimeSinceStartup);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_realtimeSinceStartupAsDouble(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.realtimeSinceStartupAsDouble);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_captureDeltaTime(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, UnityEngine.Time.captureDeltaTime);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_captureFramerate(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, UnityEngine.Time.captureFramerate);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_inFixedTimeStep(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, UnityEngine.Time.inFixedTimeStep);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fixedDeltaTime(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.fixedDeltaTime = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maximumDeltaTime(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.maximumDeltaTime = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maximumParticleDeltaTime(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.maximumParticleDeltaTime = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_timeScale(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.timeScale = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_captureDeltaTime(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.captureDeltaTime = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_captureFramerate(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Time.captureFramerate = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

