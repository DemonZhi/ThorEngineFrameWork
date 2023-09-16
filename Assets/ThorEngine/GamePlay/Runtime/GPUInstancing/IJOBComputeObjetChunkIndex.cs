using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;


public struct MyJob : IJobParallelFor
{
    [ReadOnly]
    public NativeArray<float> a;
    [ReadOnly]
    public NativeArray<float> b;

    public NativeArray<float> result;

    public void Execute(int index)
    {
        result[index] = a[index] + b[index];
    }
}

public class IJOBComputeObjetChunkIndex : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        NativeArray<float> result = new NativeArray<float>(1, Allocator.TempJob);
        NativeArray<float> a = new NativeArray<float>(2, Allocator.TempJob);
        NativeArray<float> b = new NativeArray<float>(2, Allocator.TempJob);

        MyJob jobData = new MyJob();
        jobData.a = a;
        jobData.b = b;
        jobData.result = result;


        result.Dispose();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
