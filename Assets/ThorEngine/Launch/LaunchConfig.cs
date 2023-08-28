using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.Croe
{
    [CreateAssetMenu(fileName = "LaunchConfig.asset", menuName = "ThorEngine/Setting/Creat LaunchConfig")]
    public class LaunchConfig : ScriptableObject
    {
        [Header("游戏入口反射信息")]
        public string entryAssembly;
        public string entryType;
        public string entryMethod;

        [Header("是否使用remoteURL")]
        public bool enableRemoteURL;

        [Header("热更Dll地址")]
        public string[] assemblyRemoteURL;

        [Header("是否AndroidAB包")]
        public bool isAndroidAB;

        [Header("启动UWA")]
        public bool enableUWA;

    }
}

