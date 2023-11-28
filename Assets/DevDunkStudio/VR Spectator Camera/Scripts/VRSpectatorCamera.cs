using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace DevDunk.VRSpectatorCamera
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(Camera))]
    public class VRSpectatorCamera : MonoBehaviour
    {
        #region EditorVariables
        [Tooltip("Select VR Camera")]
        public Camera VRCamera;

        [Tooltip("Choose when to run the VR Spectator Camera")]
        public bool RunInUpdate = false, RunInLateUpdate = true;

        [Tooltip("Copy over settings from VR camera to Spectator Camera, such as \nClear Flags, Background, Culling Mask, Clipping planes, and occlusion culling." +
                    "\nDisable if this camera has visual settings than the VR Camera")]
        public bool MatchVRCameraSettings = false;

        [Tooltip("Variables to controll the amount of smoothing being done to the positional and rotational changes")]
        [Range(0.001f, 1f)]
        public float PositonSmoothing = .5f, RotationSmoothing = .5f;

        [Tooltip("Override FoV set on Spectator Camera")]
        public bool OverrideFov = true;
        [Range(10f, 180f)]
        [Tooltip("Override for FoV of Spectator Camera")]
        public float FieldOfView = 70f;

        [Tooltip("Disable Spectator Camera on Android, since it has not benefit on this platform.")]
        [FormerlySerializedAs("DisableOnAndroid")]
        public bool DisableOnStandalone = true;

        [Tooltip("Automatically tries to set camera settings, such as stereo eye target")]
        public bool TrySetSettings = true;
        #endregion

        #region Properties
        public Vector3 PositionVelocity { get { return _positionVelocity; } }
        private Vector3 _positionVelocity;
        public Quaternion RotationVelocity { get { return _rotationVelocity; } }
        private Quaternion _rotationVelocity;
        #endregion

        #region RequiredAndNotSerialized
        //Required component, always available
        public Camera SpectatorCamera;
        #endregion

        #region UnityCallbacks
        private void Awake()
        {
            SpectatorCamera = GetComponent<Camera>();

            CheckReferences();
            CheckCameraSettings();
            CheckStandalone();

            if (OverrideFov) SpectatorCamera.fieldOfView = FieldOfView;
            if (MatchVRCameraSettings) MatchCameraSettings();

            _positionVelocity = Vector3.zero;
            _rotationVelocity = Quaternion.identity;

            SpectatorCamera.transform.SetPositionAndRotation(VRCamera.transform.position, VRCamera.transform.rotation);
        }

        private void Update()
        {
            if (!RunInUpdate) return;

            UpdateSpectatorCamera();
        }

        private void LateUpdate()
        {
            if (!RunInLateUpdate) return;

            UpdateSpectatorCamera();
        }
        #endregion

        #region PrivateMethods
        private void UpdateSpectatorCamera()
        {
#if NEW_TRANSFORM_API
            SpectatorCamera.transform.GetPositionAndRotation(out Vector3 spectatorPosition, out Quaternion spectatorRotation);
            VRCamera.transform.GetPositionAndRotation(out Vector3 VRPosition, out Quaternion VRRotation);
#else
            Vector3 spectatorPosition = SpectatorCamera.transform.position;
            Quaternion spectatorRotation = SpectatorCamera.transform.rotation;
            Vector3 VRPosition = VRCamera.transform.position;
            Quaternion VRRotation = VRCamera.transform.rotation;
#endif

            Vector3 newPos = Vector3.SmoothDamp(spectatorPosition, VRPosition, ref _positionVelocity, PositonSmoothing);
            Quaternion newRot = QuaternionUtil.SmoothDamp(spectatorRotation, VRRotation, ref _rotationVelocity, RotationSmoothing);

            SpectatorCamera.transform.SetPositionAndRotation(newPos, newRot);
        }

        private void CheckReferences()
        {
            if (!VRCamera)
            {
                VRCamera = Camera.main;
                if (!VRCamera)
                {
                    Debug.LogError("VR Camera on " + gameObject.name + " is not found, using Camera.Main instead.\nSpectator Camera will be disabled", gameObject);
                    DisableSpectatorCamera();
                }
                else
                {
                    Debug.LogWarning("VR Camera on " + gameObject.name + " is not found, using Camera.Main instead", gameObject);
                }
            }

            if (!SpectatorCamera)
            {
                Debug.LogError("No camera Component found on " + gameObject.name + ".\nSpectator Camera disabled", gameObject);
                DisableSpectatorCamera();
            }

            if(PositonSmoothing <= 0)
            {
                Debug.LogError("PositonSmoothing is 0 or lower, which is not allowed. Set it to a positive value in order to use Spactator Camera.\nSpectator Camera will be disabled.", gameObject);
                DisableSpectatorCamera();
            }
            if (RotationSmoothing <= 0)
            {
                Debug.LogError("RotationSmoothing is 0 or lower, which is not allowed. Set it to a positive value in order to use Spactator Camera.\nSpectator Camera will be disabled.", gameObject);
                DisableSpectatorCamera();
            }
        }

        private void CheckStandalone()
        {
            if (DisableOnStandalone && (Application.isMobilePlatform || Application.platform == RuntimePlatform.Android))
            {
                DisableSpectatorCamera();
            }
        }

        private void DisableSpectatorCamera()
        {
            SpectatorCamera.enabled = false;
            enabled = false;

            var canvasSetter = FindObjectOfType<CanvasDistanceSetter>();
            if (canvasSetter) canvasSetter.enabled = false;
        }

        private void CheckCameraSettings()
        {
            if (SpectatorCamera.stereoTargetEye != 0)
            {
                Debug.LogWarning("Spectator camera has stereo eye target set to " +
                    SpectatorCamera.stereoTargetEye +
                    (TrySetSettings ? ", Setting it to none" : ""), gameObject);

                if (TrySetSettings)
                {
                    SpectatorCamera.stereoTargetEye = 0;
                }
            }
        }
        #endregion

        #region PublicMethods
        public void MatchCameraSettings()
        {
            SpectatorCamera.clearFlags = VRCamera.clearFlags;
            SpectatorCamera.cullingMask = VRCamera.cullingMask;
            SpectatorCamera.farClipPlane = VRCamera.farClipPlane;
            SpectatorCamera.nearClipPlane = VRCamera.nearClipPlane;
            SpectatorCamera.backgroundColor = VRCamera.backgroundColor;
            SpectatorCamera.useOcclusionCulling = VRCamera.useOcclusionCulling;
        }
        #endregion
    }
}