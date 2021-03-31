using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CommonPostEffects : PostEffects
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
