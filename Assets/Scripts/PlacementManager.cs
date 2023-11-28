using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlacementManager : MonoBehaviour
{
    public GameObject spawnableObject, trackedHandPose;
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

        if(dropzone.ContainedObject)
        {
            Destroy(dropzone.ContainedObject);
            dropzone.ContainedObject = null;
        }
        else
        {
            var newObj = Instantiate(spawnableObject);
            newObj.transform.SetPositionAndRotation(currentRenderer.transform.position, currentRenderer.transform.rotation);
            dropzone.ContainedObject = newObj;

            newObj.GetComponent<MeshRenderer>().enabled = true;

            var obj = newObj.GetComponent<PlacableObject>();

            obj.Drum.clip = obj.Drums[dropzone.pitch];
            obj.Lead.clip = obj.Leads[dropzone.pitch];
            obj.Chord.clip = obj.Chords[dropzone.pitch];
        }
    }
}
