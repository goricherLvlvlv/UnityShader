using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalAndDepth : PostEffects
{
    [Range(0.0f, 1.0f)] public float edgeOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;
    public float sensitivityDepth = 1.0f;
    public float sensitivityNormal = 1.0f;

    public Shader shader;
    private Material mat;


    private void OnEnable()
    {
        this.GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

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

            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormal, sensitivityDepth, 0.0f, 0.0f));
            Graphics.Blit(src, dst, material);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
