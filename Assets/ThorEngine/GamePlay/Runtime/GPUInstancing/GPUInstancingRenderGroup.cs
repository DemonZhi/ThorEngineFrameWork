using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class GPUInstancingRenderGroup 
{
    public const int k_DefaultMaxDrawMeshInstancedCount = 500;

    private class GPUInstancingDrawInfo 
    {
        public List<Mesh> meshList = new List<Mesh>();
        public List<List<Material>> materialList = new List<List<Material>>();
        public ShadowCastingMode ShadowCastingMode;
        public int layer;
        public LightProbeUsage lightProbeUsage;

        public DynamicArray<DynamicArray<Matrix4x4>> matrixList;
        public DynamicArray<DynamicArray<SphericalHarmonicsL2>> lightProbesList = new DynamicArray<DynamicArray<SphericalHarmonicsL2>>();        
    }
}
