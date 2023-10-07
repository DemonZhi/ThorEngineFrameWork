using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.Core 
{
    public class AssemblyLoader : MonoBehaviour
    {
        public const string k_GameLoaderAssemblyFileName = "ThorEngine.HybridCLRCustom.Runtime.dll.bytes";

        private const string k_GameLoaderAssemblyName = "ThorEngine.HybridCLRCustom.Runtime";
        private const string k_GameLoaderEntryTypeName = "ThorEngine.Core.GameLoaderEntry";
        private const string k_GameLoaderEntryMethod = "Start";

        public static AssemblyLoader Instance { get; private set; }
        public static bool s_EnableHybridCLR = false;

        //public GameLoaderConfig 

        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }
    }

}
