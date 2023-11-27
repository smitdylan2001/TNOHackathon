using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PitchController : MonoBehaviour
{
    public Transform hand;
    public AudioSource source;

    // Start is called before the first frame update
    void Start()
    {
        source.Play();
    }

    // Update is called once per frame
    void Update()
    {
        source.pitch = hand.position.y;
    }
}
