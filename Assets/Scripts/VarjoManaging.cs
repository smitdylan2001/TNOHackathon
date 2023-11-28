using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Varjo.XR;

public class VarjoManaging : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        VarjoMixedReality.StartRender();
        Debug.Log(VarjoMixedReality.IsMRAvailable());
        VarjoMixedReality.EnableDepthEstimation();

    }

    private void OnApplicationQuit()
    {
        VarjoMixedReality.DisableDepthEstimation();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
