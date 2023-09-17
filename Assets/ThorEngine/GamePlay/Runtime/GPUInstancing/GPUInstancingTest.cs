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
    public List<Transform> roleTramsfromList = new List<Transform>();
    public List<Vector3> roleTramsfromPosition = new List<Vector3>();
    public List<int> viewChunkIndex = new List<int>();
    private Random.Random random;
    private ComputeChunkIndexJob m_ComputeIndexJob;

    private void Awake()
    {
        m_ComputeIndexJob = this.gameObject.GetComponent<ComputeChunkIndexJob>();
    }

    // Start is called before the first frame update
    private void Start()
    {
        random = Random.Random.CreateFromIndex(1);
        viewChunkIndex.Add(68);
        CreatRole();
    }

    // Update is called once per frame
    private void Update()
    {
        m_ComputeIndexJob.SetObjectsPosition(roleTramsfromPosition.ToArray(), viewChunkIndex);
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
                roleTramsfromList.Add(roleObject.transform);
                roleTramsfromPosition.Add(roleObject.transform.position);
                roleObjects.Add(roleObject);
            }
        }
    }
}
