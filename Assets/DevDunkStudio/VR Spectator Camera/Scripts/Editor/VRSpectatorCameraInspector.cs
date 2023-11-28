using UnityEditor;
using UnityEngine;

namespace DevDunk.VRSpectatorCamera.CustomInspector
{
    [CustomEditor(typeof(VRSpectatorCamera))]

    public class VRSpectatorCameraInspector : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            if (GUILayout.Button("Copy VR Camera settings to spectator Camera component"))
            {
                VRSpectatorCamera spectatorCamera = (VRSpectatorCamera)target;

                if (TrySetValues(spectatorCamera))
                {
                    spectatorCamera.MatchCameraSettings();
                }
            }
        }

        private bool TrySetValues(VRSpectatorCamera spectatorCamera)
        {
            if (!spectatorCamera.VRCamera)
            {
                spectatorCamera.VRCamera = Camera.main;
                Debug.LogWarning("No camera found on VR Spectator Camera, used Camera.main instead", spectatorCamera.gameObject);
            }
            if (!spectatorCamera.VRCamera)
            {
                Debug.LogError("No camera found on VR Spectator Camera and no Camera.main was found, stopped action", spectatorCamera.gameObject);
                return false;
            }
            if (!spectatorCamera.SpectatorCamera)
            {
                spectatorCamera.SpectatorCamera = spectatorCamera.GetComponent<Camera>();
                Debug.LogWarning("No camera found on VR Spectator Camera, used camera on this component instead", spectatorCamera.gameObject);
            }
            if (!spectatorCamera.SpectatorCamera)
            {
                Debug.LogError("No camera found on VR Spectator Camera and no Camera component was active, stopped action", spectatorCamera.gameObject);
                return false;
            }
            return true;
        }
    }
}