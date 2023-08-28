namespace ThorEngine.Core
{
    public enum ThorEngineLogLevel : byte
    {
        Debug = 0,
        Info,
        Warning,
        Error,
    }

    public interface ILogHelper
    {
        void Log(ThorEngineLogLevel level, string message);

        void Dispose();
    }
}
