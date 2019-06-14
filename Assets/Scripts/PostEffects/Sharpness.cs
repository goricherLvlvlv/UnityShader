using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sharpness : PostEffects
{
    [Range(0.2f, 3.0f)] public float sharpSpread = 0.6f; 

    public Shader shader;
    private Material mat;

    public Material material {
        get {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (material != null)
        {
            material.SetFloat("_SharpSize", sharpSpread);

            Graphics.Blit(src, dst, material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
