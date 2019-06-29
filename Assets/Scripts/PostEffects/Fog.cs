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
            float fov = Camera.fieldOfView;     // field of view, 视野角度
            float near = Camera.nearClipPlane;  // 近裁剪平面距离
            float aspect = Camera.aspect;       // 宽高比

            float halfHeight = near * Mathf.Tan(fov * Mathf.Deg2Rad * 0.5f);
            Vector3 toTop = CameraTransform.up * halfHeight;
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;

            // TL TR BL BR
            // 上左 上右 下左 下右
            Vector3 TL = CameraTransform.forward * near + toTop - toRight;
            Vector3 TR = CameraTransform.forward * near + toTop + toRight;
            Vector3 BL = CameraTransform.forward * near - toTop - toRight;
            Vector3 BR = CameraTransform.forward * near - toTop + toRight;

            /*
             *
             * 相似三角形
             * depth / dist = Near / |TL|
             * dist = depth * (|TL| / Near)
             * dist = depth * scale, 到任意一点的距离
             *
             * scale在shader中被调用, linearDepth * scale * normal_vector
             * distance * normal_vector, 这就获得了相机指向目标的法线
             *
             */
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
