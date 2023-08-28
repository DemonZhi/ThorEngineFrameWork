using System.Diagnostics;

namespace ThorEngine.Core
{
    public static class Logger
    {
        
        public const string k_EnableDebugAndAboveLogScriptingDefineSymbol = "ENABLE_DEBUG_AND_ABOVE_LOG";
        
        public const string k_EnableInfoAndAboveLogScriptingDefineSymbol = "ENABLE_INFO_AND_ABOVE_LOG";
        
        public const string k_EnableWarningAndAboveLogScriptingDefineSymbol = "ENABLE_WARNING_AND_ABOVE_LOG";
        
        public const string k_EnableErrorAndAboveLogScriptingDefineSymbol = "ENABLE_ERROR_AND_ABOVE_LOG";
                
        private static ThorEngineLogLevel s_LogLevel = ThorEngineLogLevel.Debug;
        private static ILogHelper s_LogHelper = new DefaultLogHelper();

        public static void SetLogHelper(ILogHelper logHelper)
        {
            s_LogHelper = logHelper;
        }

        public static void SetLogLevel(ThorEngineLogLevel level)
        {
            s_LogLevel = level;
        }

        public static void DisposeLogger()
        {
            if (s_LogHelper != null)
            {
                s_LogHelper.Dispose();
                s_LogHelper = null;
            }
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebug(string message)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebug(params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            string message = StringUtility.Concat(args);
            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebugFormat(string format, object arg0)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0);
            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebugFormat(string format, object arg0, object arg1)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1);
            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebugFormat(string format, object arg0, object arg1, object arg2)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1, arg2);
            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        public static void LogDebugFormat(string format, params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Debug)
            {
                return;
            }

            string message = StringUtility.Format(format, args);
            s_LogHelper.Log(ThorEngineLogLevel.Debug, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfo(string message)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfo(params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            string message = StringUtility.Concat(args);
            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfoFormat(string format, object arg0)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0);
            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfoFormat(string format, object arg0, object arg1)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1);
            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfoFormat(string format, object arg0, object arg1, object arg2)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1, arg2);
            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        public static void LogInfoFormat(string format, params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Info)
            {
                return;
            }

            string message = StringUtility.Format(format, args);
            s_LogHelper.Log(ThorEngineLogLevel.Info, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarning(string message)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarning(params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }
            string message = StringUtility.Concat(args);
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarningFormat(string format, object arg0)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0);
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarningFormat(string format, object arg0, object arg1)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1);
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarningFormat(string format, object arg0, object arg1, object arg2)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1, arg2);
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        public static void LogWarningFormat(string format, params object[] args)
        {
            if (s_LogHelper == null || s_LogLevel > ThorEngineLogLevel.Warning)
            {
                return;
            }

            string message = StringUtility.Format(format, args);
            s_LogHelper.Log(ThorEngineLogLevel.Warning, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogError(string message)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogError(params object[] args)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            string message = StringUtility.Concat(args);
            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogErrorFormat(string format, object arg0)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0);
            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogErrorFormat(string format, object arg0, object arg1)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1);
            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogErrorFormat(string format, object arg0, object arg1, object arg2)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            string message = StringUtility.Format(format, arg0, arg1, arg2);
            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }

        //[Conditional("DEBUG")]
        [Conditional(k_EnableDebugAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableInfoAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableWarningAndAboveLogScriptingDefineSymbol)]
        [Conditional(k_EnableErrorAndAboveLogScriptingDefineSymbol)]
        public static void LogErrorFormat(string format, params object[] args)
        {
            if (s_LogHelper == null)
            {
                return;
            }

            string message = StringUtility.Format(format, args);
            s_LogHelper.Log(ThorEngineLogLevel.Error, message);
        }
    }
}
