using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
using UnityEngine.Rendering;
using Random = Unity.Mathematics;

public class GPUInstancingTest : MonoBehaviour
{
    public GameObject role1Prefab;
    public DynamicArray<GameObject> roleObjects = new DynamicArray<GameObject>();
    private Random.Random random;
    // Start is called before the first frame update
    private void Start()
    {
        random = Random.Random.CreateFromIndex(1);
        CreatRole();
    }

    // Update is called once per frame
    private void Update()
    {
        
    }

    private void CreatRole() 
    {
        int col = 30, row = 40;
        float3 min = new float3(-col, -row, 0);
        float3 max = new float3(col, row, 100);
        for (int i = 0; i < col; i++)
        {
            for (int j = 0; j < col; j++) 
            {
                float3 randPosition = random.NextFloat3(min, max);
                GameObject roleObject = GameObject.Instantiate(role1Prefab, randPosition, Quaternion.identity);
                roleObjects.Add(roleObject);
            }
        }
    }
}
