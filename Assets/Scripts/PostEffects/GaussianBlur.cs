using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffects
{
    [Range(0, 4)] public int iterations = 3;              // 迭代次数
    [Range(0.2f, 3.0f)] public float blurSpread = 0.6f;     // 每次迭代扩散度
    [Range(1, 8)] public int downSample = 2;              // 降低采样的分辨率

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
            int width = src.width / downSample;
            int height = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations; ++i)
            {
                mat.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // Pass 0
                Graphics.Blit(buffer0, buffer1, mat, 0);

                // Pass 1
                Graphics.Blit(buffer1, buffer0, mat, 1);

                RenderTexture.ReleaseTemporary(buffer1);

            }
            Graphics.Blit(buffer0, dst);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
