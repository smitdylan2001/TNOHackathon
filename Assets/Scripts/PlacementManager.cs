using Manus.Skeletons;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlacementManager : MonoBehaviour
{
    public float MaxDistance = 0.5f;
    public GameObject spawnableObject, trackedHandPose, indexSpawn, MiddleSpawn, RingSpawn, leftHand;
    public Transform HandBase, ThumbTip, IndexTip, MiddleTip, RingTip;
    public Transform[] placables;
    MeshRenderer currentRenderer;

    bool IsEditing;
    float minDist = float.MaxValue;
    bool canSpawn;
    Vector3 leftPos;
    bool indexActive, middleActive, ringACtive;
    DropZone currentDropZone;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        float indexDist = Vector3.Distance(IndexTip.position, ThumbTip.position);
        float middleDist = Vector3.Distance(MiddleTip.position, ThumbTip.position);
        float ringDist = Vector3.Distance(RingTip.position, ThumbTip.position);

        if (!IsEditing)
        {
            minDist = float.MaxValue;

            foreach (var placable in placables)
            {
                float dist = Vector3.Distance(trackedHandPose.transform.position, placable.position);

                if (dist < minDist)
                {
                    if (currentRenderer) currentRenderer.enabled = false;
                    minDist = dist;
                    currentRenderer = placable.GetComponent<MeshRenderer>();
                    currentRenderer.enabled = true;
                    canSpawn = true;
                    if (minDist > MaxDistance)
                    {
                        currentRenderer.enabled = false;
                        canSpawn = false;
                    }
                }
            }

            if(indexDist < 0.05f)
            {
                SpawnObject(indexSpawn);
                indexActive = true;
            }else if (middleDist < 0.07f)
            {
                SpawnObject(MiddleSpawn);
                middleActive = true;
            }
            else if (ringDist < 0.07f)
            {
                SpawnObject(RingSpawn);
                ringACtive = true;
            }
        }
        else
        {
            if (!currentDropZone) return;

            var obj =  currentDropZone.ContainedObject.GetComponent<PlacableObject>();
            if (obj)
            {
                float dist =  leftHand.transform.position.y - leftPos.y;
                obj.SetAudio(dist + 0.5f);

                //obj.SetAudio(thumbDist, indexDist, middleDist);
            Debug.Log($"distance is {dist} and index pos is {indexDist}");
            }
            
            if (indexActive && indexDist > 0.07f)
            {
                IsEditing = false;
                indexActive = false;
            }
            else if (middleActive && middleDist > 0.11f)
            {
                IsEditing = false;
                middleActive = false;
            }
            else if (ringACtive && ringDist > 0.11f)
            {
                IsEditing = false;
                ringACtive = false;
            }
        }
    }

    public void SpawnObject(GameObject spawn)
    {
        Debug.Log("Grabbin it");

        if(!currentRenderer || !gameObject || IsEditing || !canSpawn) return;

        currentDropZone = currentRenderer.GetComponent<DropZone>();

        if(currentDropZone.ContainedObject)
        {
            Destroy(currentDropZone.ContainedObject);
            currentDropZone.ContainedObject = null;
        }
        else
        {
            var newObj = Instantiate(spawn);
            newObj.transform.SetPositionAndRotation(currentRenderer.transform.position, currentRenderer.transform.rotation);
            currentDropZone.ContainedObject = newObj;

            newObj.GetComponent<MeshRenderer>().enabled = true;

            var obj = newObj.GetComponent<PlacableObject>();

            obj.source.clip = obj.newClips[currentDropZone.pitch];
            obj.SetAudio(0.5f);
            //obj.Drum.clip = obj.Drums[currentDropZone.pitch];
            //obj.Lead.clip = obj.Leads[currentDropZone.pitch];
            //obj.Chord.clip = obj.Chords[currentDropZone.pitch];

            IsEditing = true;

            leftPos = leftHand.transform.position;
        }
    }
}
