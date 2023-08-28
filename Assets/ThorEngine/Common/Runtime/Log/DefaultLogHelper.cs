using UnityEngine;

namespace ThorEngine.Core 
{
    public class DefaultLogHelper : ILogHelper
    {
        public void Log(ThorEngineLogLevel level, string message)
        {
            switch (level)
            {
                case ThorEngineLogLevel.Debug:
#if UNITY_EDITOR
                    message = StringUtility.Format("<color=#008000>{0}</color>", message);
#endif
                    Debug.Log(message);
                    break;

                case ThorEngineLogLevel.Info:
                    Debug.Log(message);
                    break;

                case ThorEngineLogLevel.Warning:
                    Debug.LogWarning(message);
                    break;

                case ThorEngineLogLevel.Error:
                    Debug.LogError(message);
                    break;
                default:
                    Debug.LogError(StringUtility.Format("Invalid LogLevel:[{0}]", level));
                    break;
            }
        }

        public void Dispose()
        {
        }
    }
}
