using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UISafeArea : MonoBehaviour
{
    #region ��ȫ����
    public RectTransform safeRect;
    public RectTransform[] extraSafeRect;
    #endregion

    #region �ֱ��ʱ���ͼ�Ǳ�
    public RectTransform bgNode;
    public float bgScale = 1;

    public GameObject[] extraBgs;
    public bool bIgnoreVerticalScale;
    private bool bHorizonScale = false;
    private Vector2 uiRootSize = Vector2.one;

    #endregion

    private int key;

    private void Start() 
    {
        if (safeRect == null) 
        {

        }
        key = this.gameObject.GetInstanceID();
        
    }
    
    // Update is called once per frame
    void Update()
    {
        
    }
}
