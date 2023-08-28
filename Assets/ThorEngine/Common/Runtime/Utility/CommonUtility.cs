using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.U2D;

namespace ThorEngine.Core
{
    public class CommonUtility
    {
        #region 私有变量
        private static List<Transform> s_TransformsList = new List<Transform>();
        //[挂点ID - 挂点名]映射表（index：ID）
        private static Dictionary<int, string> s_MountPointIDToNameMap = new Dictionary<int, string>();
        #endregion

        public static void RestGameObject(Transform transform, Transform parent = null)
        {
            if (transform != null)
            {
                if (parent != null)
                {
                    transform.SetParent(parent);
                }
                transform.localPosition = Vector3.zero;
                transform.localRotation = Quaternion.identity;
                transform.localScale = Vector3.one;
            }
        }

        public static bool HasBit(int[] data, int index)
        {
            return (data[index >> 5] & 1 << index) > 0;
        }

        public static void SetBit(ref int[] data, int index)
        {
            data[index >> 5] |= 1 << index;
        }

        public static void RemoveBit(ref int[] data, int index)
        {
            int num = 1 << index;
            data[index >> 5] &= ~num;
        }

        public static void SetLayer(GameObject go, string layerName)
        {
            int layer = LayerMask.NameToLayer(layerName);
            SetLayer(go, layer);
        }

        public static void SetLayer(GameObject go, int layer)
        {
            if (go.layer == layer)
            {
                return;
            }
            go.GetComponentsInChildren<Transform>(true, s_TransformsList);
            foreach (Transform transform in s_TransformsList)
            {
                transform.gameObject.layer = layer;
            }
        }

        public static void AddMountPointIDToNameMapping(int id, string mountPoint)
        {
            if(s_MountPointIDToNameMap.ContainsKey(id))
            {
                Logger.LogDebugFormat("[Utility](AddMountPointIDToNameMapping)Duplicate id:[{0}] mountPoint:[{1}]", id, mountPoint);
                return;
            }
            s_MountPointIDToNameMap.Add(id, mountPoint);
        }

        public static Transform GetChildTransform(Transform parent, string name)
        {
            return GetChildTransformInternal(parent, name);
        }

        public static Transform GetChildTransform(Transform parent, int id)
        {
            if(s_MountPointIDToNameMap.TryGetValue(id, out string name))
            {
                return GetChildTransformInternal(parent, name);
            }

            Logger.LogDebugFormat("[Utility](GetChildTransform)Invalid id:[{0}]", id);
            return null;
        }

        public static float GetClipLength(Animator animator, string clipName)
        {
            float clipLength = 0;
            if (animator != null && !string.IsNullOrEmpty(clipName))
            {
                RuntimeAnimatorController animatorController = animator.runtimeAnimatorController;
                if (animatorController != null)
                {
                    AnimationClip[] animationClips = animatorController.animationClips;
                    if (animationClips != null && animationClips.Length > 0)
                    {
                        for (int i = 0; i < animationClips.Length; i++)
                        {
                            if (animationClips[i].name == clipName)
                            {
                                clipLength = animationClips[i].length;
                                break;
                            }
                        }
                    }
                }
            }
            return clipLength;
        }

        public static int RandomIndexFromThresholds(List<float> thresholds)
        {
            int result = -1;
            if (thresholds == null || thresholds.Count == 0)
            {
                return result;
            }

            float totalNum = 0;

            foreach (var threshold in thresholds)
            {
                totalNum += threshold;
            }

            var random = UnityEngine.Random.Range(0, totalNum);

            for (int i = 0; i < thresholds.Count; i++)
            {
                random -= thresholds[i];
                if (random <= 0)
                {
                    result = i;
                    break;
                }
            }

            return result;
        }

        public static bool RaycastByScreenPoint(Camera camera, Vector3 screenPoint, float maxDistance, int layerMask, out Vector3 hitPoint)
        {
            Ray ray = camera.ScreenPointToRay(screenPoint);
            if (Physics.Raycast(ray, out RaycastHit raycastHit, maxDistance, layerMask))
            {
                hitPoint = raycastHit.point;
                return true;
            }

            hitPoint = Vector3.zero;
            return false;
        }

        public static bool IsTouchGround(out Vector3 hitPoint)
        {
#if UNITY_EDITOR
            if (Input.GetMouseButtonDown(1))
            {
                return RaycastByScreenPoint(Camera.main, Input.mousePosition, float.MaxValue, Layers.k_GroundMask, out hitPoint);
            }
#endif

            hitPoint = Vector3.zero;
            return false;
        }


#region 私有接口
        private static Transform GetChildTransformInternal(Transform parent, string name)
        {
            Transform child = parent.Find(name);
            if (child != null)
            {
                return child;
            }

            int childCount = parent.childCount;
            for (int i = 0; i < childCount; i++)
            {
                child = parent.GetChild(i);
                child = GetChildTransformInternal(child, name);
                if (child != null)
                {
                    return child;
                }
            }

            return null;
        }
#endregion
    }
}
