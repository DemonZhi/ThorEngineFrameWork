using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using ThorEngine.Core;
using ThorEngine.UI;
using Unity.VisualScripting;
using UnityEngine;
using Logger = UnityEngine.Logger;

namespace ThorEngine.Core
{
    public class GameLoop : MonoBehaviour
    {
        private static List<IManager> s_AllManager = new List<IManager>();

        public static List<IManager> AllManagers 
        {
            get
            {
                return AllManagers;
            }
        }

        private static bool m_IsInited = false;

        public static async Task Init(Func<float, string, Task> processCallback)
        {
            m_IsInited = false;
            s_AllManager.Clear();
            s_AllManager.Add(UIManager.Instance);
            s_AllManager.Add(TimerManager.Instance);
            s_AllManager.Add(LuaManager.Instance);

            float count = s_AllManager.Count;
            for (int i = 0; i < s_AllManager.Count; i++)
            {
                Logger.LogDebugFormat("[GameLoop](Init) step:[{0}] ", i + 1);
                await processCallback(i / count, string.Empty);
                s_AllManager[i].Init();
            }

            m_IsInited = true;
        }

        public void Update()
        {
            if (!m_IsInited)
            {
                return;
            }

            float currentTime = Time.time;
            
            for (int i = 0; i < s_AllManager.Count; i++)
            {
                if (s_AllManager[i].IsAutoUpdate())
                {
                    s_AllManager[i].Update();
                }
            }
        }
    }
    
    
}
