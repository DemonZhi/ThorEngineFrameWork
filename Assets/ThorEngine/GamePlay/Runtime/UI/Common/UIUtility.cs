using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.UI
{
    public class UIUtility
    {
        public static void ResetUITrans(RectTransform uiTrans) 
        {
            if(uiTrans == null) 
            {
                return;
            }
            uiTrans.localScale = Vector3.one;
            uiTrans.localPosition = Vector3.zero;
            uiTrans.anchoredPosition = Vector2.zero;
        }
    }
}

