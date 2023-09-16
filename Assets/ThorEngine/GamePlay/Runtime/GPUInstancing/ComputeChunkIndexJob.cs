using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEngine;

public class ComputeChunkIndexJob : MonoBehaviour
{
    public struct ComputeIndexJob : IJobParallelFor
    {        
        [ReadOnly]
        public NativeArray<Vector3> position;
        [ReadOnly]
        public NativeList<int> viewChunkIndex;

        
        public NativeArray<int> chunkIndex;
        public int ExcuteCount;

        private float m_OrignalX;
        private float m_OrignalY;
        private float m_ChunkSizeRcp;
        private int m_ChunkMaxCoord;

        public void InitChunkData(float orignalX, float orignalY, float chunSizeRcp, int chunkMaxCoord) 
        {
            m_OrignalX = orignalX;
            m_OrignalY = orignalY;
            m_ChunkSizeRcp = chunSizeRcp;
            m_ChunkMaxCoord = chunkMaxCoord;
        }

        public void Execute(int index)
        {             
            chunkIndex[index] = GetChunkIndexWithCoord(GetChunkCoordWithPositionWS(position[index].x, position[index].y));
            ExcuteCount++;
            
        }

        private Vector2Int GetChunkCoordWithPositionWS(float positionX, float positionY)
        {
            float mapLocalPositionX = math.max(positionX - m_OrignalX, 0);
            float mapLocalPositionY = math.max(positionY - m_OrignalY, 0);
            int chunX = (int)(mapLocalPositionX * m_ChunkSizeRcp);
            int chunY = (int)(mapLocalPositionY * m_ChunkSizeRcp);
            return new Vector2Int(chunX, chunY);
        }

        private int GetChunkIndexWithCoord(Vector2Int chunkCoord) 
        {
            return chunkCoord.y * m_ChunkMaxCoord + chunkCoord.x;            
        }
    }


    private float m_OrignalX = -100;
    private float m_OrignalY = -100;
    private float m_ChunkSize = 10;
    private float m_ChunkSizeRcp = 0;
    private int m_ChunkMaxCoord = 10;
        
    private NativeArray<Vector3> m_PositionArray;
    private NativeArray<int> m_ChunkIndexArray;
    private NativeList<int> m_ViewIndexArray;


    public void SetObjectsPosition(Vector3[] ObjectsPosition, List<int> viewIndex)
    {
        m_PositionArray = new NativeArray<Vector3>(ObjectsPosition, Allocator.TempJob);
        m_ViewIndexArray = new NativeList<int>(viewIndex.Count, Allocator.TempJob);
        m_ChunkIndexArray = new NativeArray<int>(ObjectsPosition.Length, Allocator.TempJob);
        


        ComputeIndexJob computeIndexJob = new ComputeIndexJob();
        computeIndexJob.InitChunkData(m_OrignalX, m_OrignalY, math.rcp(m_ChunkSize), m_ChunkMaxCoord);
        computeIndexJob.position = m_PositionArray;
        computeIndexJob.chunkIndex = m_ChunkIndexArray;
        computeIndexJob.viewChunkIndex = m_ViewIndexArray;
        //Schedule the job with one Execute per index in the resule array and only 1 item processing bath
        JobHandle handle = computeIndexJob.Schedule(m_ChunkIndexArray.Length, 100);
        handle.Complete();

        Debug.Log("ExcuteCount:" + computeIndexJob.ExcuteCount);
        for (int i = 0; i < m_ChunkIndexArray.Length; i++) 
        {
            Debug.Log(m_ChunkIndexArray[i]);
        }
        
        m_PositionArray.Dispose();
        m_ChunkIndexArray.Dispose();
    }

    private void DisposeAll() 
    {        
        
    }


    private void OnDestroy()
    {        
        
    }

}
