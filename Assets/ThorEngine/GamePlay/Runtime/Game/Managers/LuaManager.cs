using LuaInterface;
using System;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Profiling;

namespace ThorEngine.Core
{
    public class LuaManager : Singleton<LuaManager>, IManager
    {
        private LuaState m_LuaState = null;
        private LuaTable m_Profiler = null;

        private LuaFunction m_UpdateFunction = null;
        private LuaFunction m_LateUpdateFunction = null;
        private LuaFunction m_RestartFunction = null;
        private LuaFunction m_DestroyFunction = null;
        private LuaFunction m_BeforeChangeSceneFunction = null;
        private LuaFunction m_AfterChangeSceneFunction = null;

        public Action registerGlobalValuesCallBack; 

        private LuaManager() { }

        public void Init()
        {
            InitLoader();
            m_LuaState = new LuaState();
            OpenLibs();
            m_LuaState.LuaSetTop(0);
            Bind();
            SetGlobalValues();
            LoadLuaFiles();
        }

        private LuaFileUtils InitLoader()
        {
            LuaFileUtils fileUtils = LuaFileUtils.Instance;

            if (Main.GameConfig.useBundleMode)
            {
                fileUtils.beZip = true; 
            }
            else
            {
                fileUtils.beZip = false;
            }

            return fileUtils; 
        } 

        public void OpenLibs()
        {
            m_LuaState.OpenLibs(LuaDLL.luaopen_struct);
            m_LuaState.OpenLibs(LuaDLL.luaopen_lpeg);

            OpenLuaPB(); 

            if (LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (LuaConst.openLuaDebugger)
            {
                OpenZbsDebugger();
            }

            if (LuaConst.openLuaCJson)
            {
                OpenCJson();
            }
        }

        //[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]

        //static int LuaOpen_PB(IntPtr L)
        //{
        //    return LuaDLL.luaopen_pb(L);
        //}


        //[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]

        //static int LuaOpen_PB_IO(IntPtr L)
        //{
        //    return LuaDLL.luaopen_pb_io(L);
        //}


        //[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]

        //static int LuaOpen_PB_Buffer(IntPtr L)
        //{
        //    return LuaDLL.luaopen_pb_buffer(L);
        //}


        //[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]

        //static int LuaOpen_PB_SLICE(IntPtr L)
        //{
        //    return LuaDLL.luaopen_pb_slice(L);
        //}

        //[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]

        //static int LuaOpen_PB_CONV(IntPtr L)
        //{
        //    return LuaDLL.luaopen_pb_conv(L);
        //}

        public void OpenLuaPB()
        {
            //m_LuaState.BeginPreLoad();
            //m_LuaState.RegFunction("pb", LuaOpen_PB);
            //m_LuaState.RegFunction("pb.io", LuaOpen_PB_IO);
            //m_LuaState.RegFunction("pb.buffer", LuaOpen_PB_Buffer);
            //m_LuaState.RegFunction("pb.conv", LuaOpen_PB_CONV);
            //m_LuaState.RegFunction("pb.slice", LuaOpen_PB_SLICE);
            //m_LuaState.EndPreLoad();
        }

        public void OpenZbsDebugger(string ip = "localhost")
        {
            if (!Directory.Exists(LuaConst.zbsDir))
            {
                Debugger.LogWarning("ZeroBraneStudio not install or LuaConst.zbsDir not right");
                return;
            }

            if (!LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (!string.IsNullOrEmpty(LuaConst.zbsDir))
            {
                m_LuaState.AddSearchPath(LuaConst.zbsDir);
            }

            m_LuaState.LuaDoString(string.Format("DebugServerIp = '{0}'", ip), "@LuaClient.cs");
        }

        private void OpenLuaSocket()
        {
            LuaConst.openLuaSocket = true;

            m_LuaState.BeginPreLoad();
            m_LuaState.RegFunction("socket.core", LuaOpen_Socket_Core);
            m_LuaState.RegFunction("mime.core", LuaOpen_Mime_Core);
            m_LuaState.EndPreLoad();
        }

        private void OpenCJson()
        {
            m_LuaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            m_LuaState.OpenLibs(LuaDLL.luaopen_cjson);
            m_LuaState.LuaSetField(-2, "cjson");

            m_LuaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
            m_LuaState.LuaSetField(-2, "cjson.safe");
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Mime_Core(IntPtr L)
        {
            return LuaDLL.luaopen_mime_core(L);
        }

        private void Bind()
        {
            LuaBinder.Bind(m_LuaState);
            DelegateFactory.Init();
        }

        private void SetGlobalValues()
        {
#if UNITY_EDITOR
            bool isUnityEditor = true;
#else
            bool isUnityEditor = false;
#endif
            m_LuaState.Push(isUnityEditor);
            m_LuaState.LuaSetGlobal("UNITY_EDITOR");

#if UNITY_STANDALONE
            bool isUnityStandalone = true;
            m_LuaState.Push(isUnityStandalone);
            m_LuaState.LuaSetGlobal("UNITY_STANDALONE");
#endif

            SetLogGlobalValues();

            registerGlobalValuesCallBack?.Invoke();
        }

        private void SetLogGlobalValues()
        {
#if ENABLE_DEBUG_AND_ABOVE_LOG
            m_LuaState.Push(true);
            m_LuaState.LuaSetGlobal("ENABLE_DEBUG_AND_ABOVE_LOG");
#endif

#if ENABLE_INFO_AND_ABOVE_LOG
            m_LuaState.Push(true);
            m_LuaState.LuaSetGlobal("ENABLE_INFO_AND_ABOVE_LOG");
#endif

#if ENABLE_WARNING_AND_ABOVE_LOG
            m_LuaState.Push(true);
            m_LuaState.LuaSetGlobal("ENABLE_WARNING_AND_ABOVE_LOG");
#endif

#if ENABLE_ERROR_AND_ABOVE_LOG
            m_LuaState.Push(true);
            m_LuaState.LuaSetGlobal("ENABLE_ERROR_AND_ABOVE_LOG");
#endif
        }

        private void LoadLuaFiles()
        {
            OnLoadFinished();
        }

        private void OnLoadFinished()
        {
            m_LuaState.Start();
            StartMain();
        }

        private void StartMain()
        {
            m_LuaState.DoFile("Main");
            BindGameLoopFunctions();
            CallMain();
        }

        private void CallMain()
        {
            LuaFunction main = m_LuaState.GetFunction("Main");
            main.Call();
            main.Dispose();
            main = null;
        }

        private void BindGameLoopFunctions()
        {
            m_UpdateFunction = m_LuaState.GetFunction("GameLoop.Update");
            m_LateUpdateFunction = m_LuaState.GetFunction("GameLoop.LateUpdate");
            m_RestartFunction = m_LuaState.GetFunction("GameLoop.Restart");
            m_DestroyFunction = m_LuaState.GetFunction("GameLoop.Destroy");
            m_BeforeChangeSceneFunction = m_LuaState.GetFunction("GameLoop.BeforeChangeScene");
            m_AfterChangeSceneFunction = m_LuaState.GetFunction("GameLoop.AfterChangeScene");
        }

        private void DisposeGameLoopFunctions()
        {
            m_UpdateFunction?.Dispose();
            m_UpdateFunction = null;

            m_LateUpdateFunction?.Dispose();
            m_LateUpdateFunction = null;

            m_RestartFunction?.Dispose();
            m_RestartFunction = null;

            m_DestroyFunction?.Dispose();
            m_DestroyFunction = null;

            m_BeforeChangeSceneFunction?.Dispose();
            m_BeforeChangeSceneFunction = null;

            m_BeforeChangeSceneFunction?.Dispose();
            m_BeforeChangeSceneFunction = null;
        }

        public void Update()
        {
            Profiler.BeginSample("LuaManager.Update");

            if(m_UpdateFunction != null)
            {
                m_UpdateFunction.Call(Time.deltaTime, Time.unscaledDeltaTime);
            }

            m_LuaState.Collect();

#if UNITY_EDITOR
            m_LuaState.CheckTop();
#endif

            Profiler.EndSample();
        }

        public void FixedUpdate()
        {
            // FixedUpdate is not needed for lua scripts
        }

        public void LateUpdate()
        {
            if (m_LateUpdateFunction != null)
            {
                m_LateUpdateFunction.Call();
            }

            m_LuaState.StepCollect();
        }

        void ThrowException()
        {
            string error = m_LuaState.LuaToString(-1);
            m_LuaState.LuaPop(2);
            throw new LuaException(error, LuaException.GetLastError());
        }

        public void Restart()
        {
            if(m_RestartFunction != null)
            {
                m_RestartFunction.Call();
            }
        }

        public void Destroy()
        {
            if (m_LuaState != null)
            {
                if(m_DestroyFunction != null)
                {
                    m_DestroyFunction.Call();
                }

                DisposeGameLoopFunctions();

                DetachProfiler();
                LuaState state = m_LuaState;
                m_LuaState = null;

                state.Dispose();
            }
        }

        public void BeforeChangeScene(int prevSceneType, int nextSceneType)
        {
            if(m_BeforeChangeSceneFunction != null)
            {
                m_BeforeChangeSceneFunction.Call(prevSceneType, nextSceneType);
            }
        }

        public void AfterChangeScene(int prevSceneType, int nextSceneType)
        {
            if(m_AfterChangeSceneFunction != null)
            {
                m_AfterChangeSceneFunction.Call(prevSceneType, nextSceneType);
            }
        }

        public bool IsAutoUpdate()
        {
            return true;
        }

        public void AttachProfiler()
        {
            if (m_Profiler == null)
            {
                m_Profiler = m_LuaState.Require<LuaTable>("UnityEngine.Profiler");
                m_Profiler.Call("start", m_Profiler);
            }
        }

        public void DetachProfiler()
        {
            if (m_Profiler != null)
            {
                m_Profiler.Call("stop", m_Profiler);
                m_Profiler.Dispose();
                LuaProfiler.Clear();
            }
        }

        public LuaTable GetTable(string name)
        {
            if (m_LuaState == null)
            {
                return null;
            }
            return m_LuaState.GetTable(name);
        }

        public LuaFunction GetFunction(string funcName)
        {
            if (m_LuaState == null)
            {
                return null;
            }
            return m_LuaState.GetFunction(funcName);
        }

        public LuaTable NewTable()
        {
            return m_LuaState.NewTable();
        }

        public void SetGlobalValue(string key, bool value)
        {
            m_LuaState.Push(value);
            m_LuaState.LuaSetGlobal(key);
        }
    }
}
