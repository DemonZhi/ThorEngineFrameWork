using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ThorEngine.Core;

public class UISafeAreaManager : MonoBehaviour
{
    public enum BGScaleMode 
    {
        None = 0,
        Scale = 1,
    }

    private const float c_MaxLimitWidth = 1560f;
    private const float c_MinLimitWidth = 1280f;
    private const float c_LimitHeight = 720f;

    public BGScaleMode scaleMode = BGScaleMode.None;
    public float matchWidthOrHeight = 1;
    public float matchRatio = 5;
    public float edgeScreenRatio = c_MinLimitWidth / c_LimitHeight;

    public Vector2 baseResolution = new Vector2(c_MaxLimitWidth, c_LimitHeight);

    public static UISafeAreaManager Instance { get; private set; }
    private Dictionary<int, UISafeArea> safeDic;
    private Vector2 uiRootSize;
    private Vector2 curScreenSize = new Vector2(Screen.width, Screen.height);
    private float ratio;

    private bool bInit = false;
    private bool bIOS = false;

    #region °²È«ÇøÓò
    public bool bEditor = false;
    public float safeOffsetLeft;
    public float safeOffsetRight;
    public float safeOffsetTop;
    public float safeOffsetButton;

    private DeviceOrientation curOrientationType;
    #endregion


    private bool bDirtyRootSize = true;
    private bool bScreenSizeChanged = false;
    private int screenChangeFrame = 0;

    private float maxSafeHorizon = 0;
    private float maxSafeVertical = 0;

    private void Awake()
    {
        Screen.orientation = ScreenOrientation.AutoRotation;
        if (!Application.isEditor) 
        {
            bEditor = false;
        }
        if (Application.platform == RuntimePlatform.IPhonePlayer) 
        {
            bIOS = true;
        }
        Instance = this;
        safeDic = new Dictionary<int, UISafeArea>();
        uiRootSize = baseResolution;
        curScreenSize = new Vector2(Screen.width, Screen.height);
        curOrientationType = DeviceOrientation.LandscapeLeft;
        CaculateSafeArea();
    }

    private void Start()
    {
        CaculateHeightOrWidth();
    }

    private void Update()
    {
        if (bScreenSizeChanged || !bInit) 
        {
            if (screenChangeFrame == 1)
            {
                CaculateHeightOrWidth();
            }
            else if (screenChangeFrame >= 2) 
            {
                bInit = true;
                bDirtyRootSize = true;
                //updateUIRootSize();
            }
        }
    }

    private void CaculateSafeArea() 
    {

    }

    private void CaculateHeightOrWidth() 
    {
        matchWidthOrHeight = 1;
        if (ratio < edgeScreenRatio) 
        {
            matchWidthOrHeight = Mathf.Pow( (c_MaxLimitWidth - c_MinLimitWidth) / (c_MaxLimitWidth - ratio * c_LimitHeight), 1.1305321753f) - 0.12f;
        }
    }

    private void SetUIRootSize(Vector2 rect) 
    {
        uiRootSize = rect;
        bDirtyRootSize = false;
        if (Main.GameConfig == null) 
        {
            return;
        }
        maxSafeHorizon = Main.GameConfig.bSafeAreaHorizontalOffset ? ((uiRootSize.x - baseResolution.x) / 2) : 0;
        maxSafeVertical = Main.GameConfig.bSafeAreaVerticalOffset ? ((uiRootSize.y - baseResolution.y) / 2) : 0;
    }

    public void UpdateUIRootSize() 
    {
        if (!bDirtyRootSize) 
        {
            return;
        }
        GameObject objCanv = GameObject.Find("CanvasLoading");
        Canvas canvas = null;
        if (objCanv)
        {
            canvas = objCanv.GetComponent<Canvas>();
        }
        else 
        {
            //canvas = UIMana
        }
    }

}
