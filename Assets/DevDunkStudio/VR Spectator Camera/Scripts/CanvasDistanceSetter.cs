using UnityEngine;

namespace DevDunk.VRSpectatorCamera
{
    [DisallowMultipleComponent]
    public class CanvasDistanceSetter : MonoBehaviour
    {
        private void Start()
        {
            Canvas canvas = GetComponent<Canvas>();
            Camera camera = FindObjectOfType<VRSpectatorCamera>().SpectatorCamera;

            if (camera == null)
            {
                Debug.LogWarning("No VR spectator camera found, using main camera instead", gameObject);
                camera = Camera.main;
            }

            canvas.planeDistance = camera.nearClipPlane*1.1f;
        }
    }
}