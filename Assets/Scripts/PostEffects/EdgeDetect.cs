using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetect : PostEffects
{
    [Range(0.0f, 1.0f)] public float edgeOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

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
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(src, dst, material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
