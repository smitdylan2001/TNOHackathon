using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class PlacableObject : MonoBehaviour
{
    Renderer closestRenderer;
    public LayerMask allowedDropBoxLayer;

    public bool doChecks = false;

    public int blockNotes = 1;
    float pitch= 1;
    AudioSource source;
    Rigidbody rb;
    // Start is called before the first frame update
    void Start()
    {
        source = GetComponent<AudioSource>();
        source.loop = true;
    }

    

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 6)
        {
            other.GetComponent<MeshRenderer>().enabled = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 6)
        {
            other.GetComponent<MeshRenderer>().enabled = false;
        }
    }

    [ContextMenu("Release")]
    public void OnDrop()
    {
        var overlaps = Physics.OverlapBox(transform.position, transform.localScale, transform.rotation, allowedDropBoxLayer, QueryTriggerInteraction.Collide); //Add layer

        if (overlaps.Length == 0) return;

        Collider closestCol = overlaps[0];
        float dist = float.PositiveInfinity;
        foreach (var col in overlaps)
        {
            col.GetComponent<MeshRenderer>().enabled = false;

            var newDist = Vector3.Distance(transform.position, col.transform.position);

            if (newDist < dist)
            {
                dist = newDist;
                closestCol = col;
            }
        }

        transform.SetPositionAndRotation(closestCol.transform.position, closestCol.transform.rotation);
    }

    public void OnGrab()
    {
        doChecks = true;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.CompareTag("MusicInteractor"))
        {
            //Play sound for blockNotes long at tune height
            PlayDuration(blockNotes / 10);
        }
    }

    public async void PlayDuration(float seconds)
    {
        source.Play();

        await Task.Delay((int)(seconds + 1000));

        source.Stop();
    }
}
//https://www.effenaar.nl/nl/discover-possibilities-performance-technology-during-chagalls-workshop-lovelace-effenaar