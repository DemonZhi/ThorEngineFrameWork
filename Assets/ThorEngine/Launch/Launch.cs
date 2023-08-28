using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;


namespace ThorEngine.Croe 
{
    public class Launch : MonoBehaviour
    {
        
        private void Start()
        {
            Debug.Log("[Launch](Start) Init");
            Init();
;        }

        private async void Init() 
        {
            InitBugly();
            InitUWA();
        }

        private void InitBugly() 
        {

        }

        private void InitUWA() 
        {

        }

        private Task HotUpdateAssembly() 
        {
            TaskCompletionSource<bool> taskSource = new TaskCompletionSource<bool>();
            GameObject HotUpdateAssemblyLoader = new GameObject("HotUpdateAssemblyLoader");
            return taskSource.Task;
        }

    }
}

