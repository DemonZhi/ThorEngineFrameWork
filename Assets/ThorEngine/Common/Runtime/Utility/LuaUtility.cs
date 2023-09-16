using LuaInterface;
using System;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Profiling;

namespace ThorEngine.Core
{
    public class LuaUtiltiy
    {
        public enum LogLevel
        {
            All = 0,
            Info = 1,
            Warn = 2,
            Error = 3,
            Disable = 4,
        }
    }    
}
