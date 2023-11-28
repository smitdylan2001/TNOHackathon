using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class PlacableObject : MonoBehaviour
{
    public bool doChecks = false;

    public int blockNotes = 1;
    AudioSource source;


    public AudioSource Chord, Drum, Lead;
    public AudioClip[] Chords, Drums, Leads;

    // Start is called before the first frame update
    void Start()
    {
    }

    

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log(other.tag);
        if (other.CompareTag("MusicInteractor"))
        {
            Chord.Play();
            Drum.Play();
            Lead.Play();
            //Play sound for blockNotes long at tune height
            PlayDuration(blockNotes / 10);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        Debug.Log(other.tag);
        if (other.CompareTag("MusicInteractor"))
        {
            //Play sound for blockNotes long at tune height
            //PlayDuration(blockNotes / 10);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
       
    }

    public async void PlayDuration(float seconds)
    {
        source.Play();

        await Task.Delay((int)(seconds + 1000));

        source.Stop();
    }
}
//https://www.effenaar.nl/nl/discover-possibilities-performance-technology-during-chagalls-workshop-lovelace-effenaar