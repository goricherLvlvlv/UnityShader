using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.WSA.Input;

public class Fog : PostEffects
{
    public Shader shader;

    private Material mat;
    public Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }

    }

    private Camera mCamera;
    public Camera Camera {
        get {
            if (mCamera == null) mCamera = GetComponent<Camera>();
            return mCamera;
        }
    }

    private Transform myCameraTransform;
    public Transform CameraTransform {
        get {
            if (myCameraTransform == null)
            {
                myCameraTransform = Camera.transform;
            }

            return myCameraTransform;
        }
    }

    [Range(0.0f, 3.0f)] public float fogDensity = 1.0f;
    public Color fogColor = Color.white;
    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;
            float fov = Camera.fieldOfView;
            float near = Camera.nearClipPlane;
            float aspect = Camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * Mathf.Deg2Rad * 0.5f);
            Vector3 toTop = CameraTransform.up * halfHeight;
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;

            // TL TR BL BR
            Vector3 TL = CameraTransform.forward * near + toTop - toRight;
            Vector3 TR = CameraTransform.forward * near + toTop + toRight;
            Vector3 BL = CameraTransform.forward * near - toTop - toRight;
            Vector3 BR = CameraTransform.forward * near - toTop + toRight;

            float scale = TL.magnitude / near;

            TL.Normalize();
            TL *= scale;
            TR.Normalize();
            TR *= scale;
            BL.Normalize();
            BL *= scale;
            BR.Normalize();
            BR *= scale;

            frustumCorners.SetRow(0, BL);
            frustumCorners.SetRow(1, BR);
            frustumCorners.SetRow(2, TR);
            frustumCorners.SetRow(3, TL);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
                
            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
