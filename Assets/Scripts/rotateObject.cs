using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotateObject : MonoBehaviour
{
    public Vector3 rotateAmount;
    public Vector3 resetPos;
    Quaternion targetAngle = Quaternion.Euler(-90, 0, 180);
    float precision = 0.9999f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(rotateAmount * Time.deltaTime);
        Debug.Log(transform.eulerAngles);

        if (gameObject.transform.eulerAngles.y > 179)
        {
            
            this.gameObject.SetActive(false);
            
            gameObject.transform.Rotate(resetPos);
            this.gameObject.SetActive(true);
        }
        
    }
}
