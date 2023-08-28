using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.Core 
{
    public class Layers
    {
        public static readonly int k_TerrainLayer = LayerMask.NameToLayer("Terrain");
        public static readonly int k_DefaultLayer = LayerMask.NameToLayer("Default");
        public static readonly int k_UILayer = LayerMask.NameToLayer("UI");
        public static readonly int k_UI3DLayer = LayerMask.NameToLayer("UI3D");
        public static readonly int k_UI2Layer = LayerMask.NameToLayer("UI2");
        public static readonly int k_HeroLayer = LayerMask.NameToLayer("Hero");
        public static readonly int k_PlayerLayer = LayerMask.NameToLayer("Player");
        public static readonly int k_MonsterLayer = LayerMask.NameToLayer("Monster");
        public static readonly int k_WaterLayer = LayerMask.NameToLayer("Water");
        public static readonly int k_Environment = LayerMask.NameToLayer("Environment");
        public static readonly int k_Fogliage = LayerMask.NameToLayer("Foliage");
        public static readonly int k_PointLight = LayerMask.NameToLayer("PointLight");
        public static readonly int k_HexMap = LayerMask.NameToLayer("HexMap");
        public static readonly int k_Trigger = LayerMask.NameToLayer("Trigger");
        public static readonly int k_OverDrawLastCamera = LayerMask.NameToLayer("OverDrawLastCamera");

        public static readonly int k_TerrainMask = 1 << k_TerrainLayer;
        public static readonly int k_DefaultMask = 1 << k_DefaultLayer;
        public static readonly int k_UIMask = 1 << k_UILayer;
        public static readonly int k_UI3DMask = 1 << k_UI3DLayer;
        public static readonly int k_UI2Mask = 1 << k_UI2Layer;
        public static readonly int k_HeroMask = 1 << k_HeroLayer;
        public static readonly int k_PlayerMask = 1 << k_PlayerLayer;
        public static readonly int k_MonsterMask = 1 << k_MonsterLayer;
        public static readonly int k_WaterMask = 1 << k_WaterLayer;
        public static readonly int k_EnvironmentMask = 1 << k_Environment;
        public static readonly int k_FogliageMask = 1 << k_Fogliage;
        public static readonly int k_HexMapMask = 1 << k_HexMap;
        public static readonly int k_TriggerMask = 1 << k_Trigger;

        public static readonly int k_GroundMask = k_TerrainMask | k_DefaultMask | k_EnvironmentMask | k_FogliageMask;
        public static readonly int k_SpriteMask = k_PlayerMask | k_MonsterMask | k_HeroMask;
    }
}
