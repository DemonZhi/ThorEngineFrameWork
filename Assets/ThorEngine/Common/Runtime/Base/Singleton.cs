using System;

namespace ThorEngine.Core
{
    public class Singleton<T> where T : class
    {
        private static T m_Instance;

        public static T Instance => m_Instance ??= Activator.CreateInstance(typeof(T), true) as T;

        protected Singleton() { }
    }
}
