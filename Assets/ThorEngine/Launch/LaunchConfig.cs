using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.Croe
{
    [CreateAssetMenu(fileName = "LaunchConfig.asset", menuName = "ThorEngine/Setting/Creat LaunchConfig")]
    public class LaunchConfig : ScriptableObject
    {
        [Header("��Ϸ��ڷ�����Ϣ")]
        public string entryAssembly;
        public string entryType;
        public string entryMethod;

        [Header("�Ƿ�ʹ��remoteURL")]
        public bool enableRemoteURL;

        [Header("�ȸ�Dll��ַ")]
        public string[] assemblyRemoteURL;

        [Header("�Ƿ�AndroidAB��")]
        public bool isAndroidAB;

        [Header("����UWA")]
        public bool enableUWA;

    }
}

