using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OrthoGraphicCameraView : MonoBehaviour
{

    public const int s_ChunkMaxCoord = 10;
    public int chunkSize = 10;

    public Vector2 orignalPosition = new Vector2(-100, -100);
   
    private Transform m_MainCameraTrans;
    // Start is called before the first frame update
    private void Start()
    {
        m_MainCameraTrans = Camera.main.transform;    
    }

    

    // Update is called once per frame
    private void Update()
    {
        
    }
}
