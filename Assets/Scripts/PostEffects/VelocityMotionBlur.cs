using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VelocityMotionBlur : PostEffects
{
    [Range(0.0f, 1.0f)] public float blurAmount = 0.5f;
    private RenderTexture accumulationTexture;

    public Shader shader;

    private Material mat;

    public Material material {
        get {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }
    }

    private Camera mCamera;

    public Camera Camera
    {
        get{
            if (mCamera == null) mCamera = GetComponent<Camera>();
            return mCamera;
        }
    }

    private Matrix4x4 previousViewProjectionMatrix4X4;

    void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_BlurAmount", blurAmount);

            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix4X4);
            Matrix4x4 curViewProjectionMatrix4X4 = Camera.projectionMatrix * Camera.worldToCameraMatrix;
            Matrix4x4 curViewProjectionInverseMatrix4X4 = curViewProjectionMatrix4X4.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", curViewProjectionInverseMatrix4X4);
            previousViewProjectionMatrix4X4 = curViewProjectionMatrix4X4;

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
