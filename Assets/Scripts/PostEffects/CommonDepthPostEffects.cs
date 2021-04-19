using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CommonDepthPostEffects : PostEffects
{
    public Shader shader;
    private Material mat;

    private void OnEnable()
    {
        this.GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    public Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Graphics.Blit(source, destination, mat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
