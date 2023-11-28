using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlacementManager : MonoBehaviour
{
    public GameObject GameObject, trackedHandPose;
    public Transform[] placables;
    MeshRenderer currentRenderer;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float minDist = float.MaxValue;

        foreach (var placable in placables)
        {
            float dist = Vector3.Distance(trackedHandPose.transform.position, placable.position);

            if(dist < minDist)
            {
                if(currentRenderer) currentRenderer.enabled = false;
                minDist = dist;
                currentRenderer = placable.GetComponent<MeshRenderer>();
                currentRenderer.enabled = true;
            }
        }
    }

    public void SpawnObject()
    {
        if(!currentRenderer || !gameObject) return;

        var dropzone = currentRenderer.GetComponent<DropZone>();

        if(dropzone)
        {
            Destroy(dropzone.ContainedObject);
        }
        else
        {
            var newObj = Instantiate(gameObject);
            newObj.transform.SetPositionAndRotation(currentRenderer.transform.position, currentRenderer.transform.rotation);
        }
    }
}
