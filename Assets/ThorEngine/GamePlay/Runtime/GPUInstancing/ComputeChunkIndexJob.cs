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
        public NativeList<int> chunkIndexInViewList;
                
        public NativeArray<int> chunkIndexArray;
        public NativeArray<bool> isChunkIndexInViewArray;

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
            int chunkIndex = GetChunkIndexWithCoord(GetChunkCoordWithPositionWS(position[index].x, position[index].y));
            chunkIndexArray[index] = chunkIndex;            
            if (chunkIndexInViewList.Contains(chunkIndex)) 
            {
                isChunkIndexInViewArray[index] = true;
            }
            else
            {
                isChunkIndexInViewArray[index] = false;
            }
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
    private NativeList<int> m_ChunkIndexInViewList;    

    private NativeArray<bool> m_IsChunkIndexInViewArray;

    public void SetObjectsPosition(Vector3[] ObjectsPosition, List<int> viewIndex)
    {
        m_PositionArray = new NativeArray<Vector3>(ObjectsPosition, Allocator.TempJob);
        m_ChunkIndexArray = new NativeArray<int>(ObjectsPosition.Length, Allocator.TempJob);
        m_IsChunkIndexInViewArray = new NativeArray<bool>(ObjectsPosition.Length, Allocator.TempJob);

        m_ChunkIndexInViewList = new NativeList<int>(viewIndex.Count, Allocator.TempJob);
        for (int i = 0; i < viewIndex.Count; i++)
        {
            m_ChunkIndexInViewList.Add(viewIndex[i]);
        }

        ComputeIndexJob computeIndexJob = new ComputeIndexJob();
        computeIndexJob.InitChunkData(m_OrignalX, m_OrignalY, math.rcp(m_ChunkSize), m_ChunkMaxCoord);
        computeIndexJob.position = m_PositionArray;
        computeIndexJob.chunkIndexArray = m_ChunkIndexArray;
        computeIndexJob.chunkIndexInViewList = m_ChunkIndexInViewList;
        
        computeIndexJob.isChunkIndexInViewArray = m_IsChunkIndexInViewArray;
                
        
        JobHandle handle = computeIndexJob.Schedule(m_ChunkIndexArray.Length, 100);
        handle.Complete();
                
        for (int i = 0; i < m_IsChunkIndexInViewArray.Length; i++) 
        {
            Debug.Log("isChunkIndexInViewArray: " + m_IsChunkIndexInViewArray[i] + " i:"+ i);
        }
        
        m_PositionArray.Dispose();
        m_ChunkIndexArray.Dispose();
        m_ChunkIndexInViewList.Dispose();
        m_IsChunkIndexInViewArray.Dispose();


    }

    private void DisposeAll() 
    {        
        
    }


    private void OnDestroy()
    {        
        
    }

}
