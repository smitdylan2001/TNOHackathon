using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class PlacableObject : MonoBehaviour
{
    Renderer closestRenderer;
    public LayerMask allowedDropBoxLayer;

    bool doChecks = false;

    public int blockNotes = 1;
    float pitch= 1;
    AudioSource source;
    // Start is called before the first frame update
    void Start()
    {
        source = GetComponent<AudioSource>();
        source.loop = true;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (!doChecks) return;

        var overlaps = Physics.OverlapBox(transform.position, transform.localScale / 3, transform.rotation, allowedDropBoxLayer); //Add layer
        Collider closestCol;
        float dist = float.PositiveInfinity;
        foreach (var col in overlaps)
        {
            var newDist = Vector3.Distance(transform.position, col.transform.position);

            if (newDist < dist)
            {
                dist = newDist;
                closestCol = col;
                closestRenderer.enabled = false;
                closestRenderer = closestCol.GetComponent<Renderer>();
                closestRenderer.enabled = true;
            }
        }
    }

    public void OnDrop()
    {
        if (!closestRenderer) return;

        closestRenderer.enabled = false;
        transform.SetPositionAndRotation(closestRenderer.transform.position, closestRenderer.transform.rotation); //TODO set to the right when block is wide!
        doChecks = false;
        source.pitch = pitch;
        //Check collision blockNotes notes to the right
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