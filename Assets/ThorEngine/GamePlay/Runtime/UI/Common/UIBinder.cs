using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.UI
{
    [System.Serializable]
    public enum UIType 
    {
        UIScrollList = 0,
        Canvas = 1,
        UIToggle = 2,
        ToggleGroup = 3,
        UIButton = 4,
        UIText = 5,
        UIImage = 6,
        RectTransform = 7,
        UIRawImage = 8,
        InputField = 9,
        Dropdown = 10,
        Slider = 11,
        Transform = 12,
        CanvasGroup = 13,
        UITouchButton = 14,
        ScrollRect = 15,
        LoopGridView = 16,
        LoopListView2 = 17,
        Empty4Raycast = 18,
        UIScrollItem = 19,
        TextMeshProUGUI = 20,
        TMP_Text = 21,
        TMP_InputField = 22,
        TMP_DropDown = 23,
        UIEffectPlayer = 24,
        UIAnimPlayer = 25,
        UIAnimPlayerList = 26,
        UISlider = 27,
        SpriteRenderer = 28,
        ColliderClickListener = 29,
        UIClick = 30,
        EffectUI = 31,
        LongPressOrClickEventTrigger = 32,
        SlideShow = 33,
        VerticalLayoutGroup = 34,
        HorizontalLayoutGroup = 35,
        UIBinder = 36,
        UITouchPass = 37,
    }

    [System.Serializable]
    public class BinderData 
    {
        public GameObject go;
        public Component component;
        public string name;
        public UIType type = UIType.RectTransform;
    }


    public class UIBinder : MonoBehaviour
    {

        public static string[] s_ComponentName =
        {
            "UIScrollList",
            "Canvas",
            "UIToggle",
            "ToggleGroup",
            "UIButton",
            "UIText",
            "UIImage",
            "RectTransform",
            "UIRawImage",
            "InputField",
            "Dropdown",
            "Slider",
            "Transform",
            "CanvasGroup",
            "UITouchButton",
            "ScrollRect",
            "LoopGridView",
            "LoopListView2",
            "Empty4Raycast",
            "UIScrollItem",
            "TextMeshProUGUI",
            "TMP_Text",
            "TMP_InputField",
            "TMP_DropDown",
            "UIEffectPlayer",
            "UIAnimPlayer",
            "UIAnimPlayerList",
            "UISlider",
            "SpriteRenderer",
            "ColliderClickListener",
            "UIClick",
            "EffectUI",
            "LongPressOrClickEventTrigger",
            "SlideShow",
            "VerticalLayoutGroup",
            "HorizontalLayoutGroup",
            "UIBinder",
            "UITouchPass",
        };

        public List<BinderData> uiList = new List<BinderData>();
        
        public int uiListCount 
        {
            get { return uiList.Count;  }
        }
        private Dictionary<string, BinderData> uiDic;

        public Component GetItem(string key) 
        {
            if (uiDic == null) 
            {
                uiDic = new Dictionary<string, BinderData>();
                foreach (BinderData binderData in uiList)
                {
                    uiDic[binderData.name] = binderData;
                }
            }
            uiDic.TryGetValue(key, out BinderData retData);
            return retData?.component;
        }

        public Component GetComponentByIndex(out string name, int index)
        {
            if (index > uiList.Count)
            {
                name = string.Empty;
                return null;
            }
            BinderData binderData = uiList[index];
            if (binderData == null)
            {
                name = string.Empty;
                return null;
            }
            name = binderData.name;
            return binderData.component;
        }
    }
}

