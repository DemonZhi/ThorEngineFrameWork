using UnityEngine;

namespace ThorEngine.Core
{
    public interface IManager
    {
        void Init();

        void Update();

        void LateUpdate();

        void FixedUpdate();

        void Restart();

        void Destroy();

        void BeforeChangeScene(int prevSceneType, int nextSceneType);

        void AfterChangeScene(int prevSceneType, int nextSceneType);

        bool IsAutoUpdate();
    }
}
