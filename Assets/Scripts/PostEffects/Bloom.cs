using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffects
{
    [Range(0, 4)] public int iterations = 3;                // 迭代次数
    [Range(0.2f, 3.0f)] public float blurSpread = 0.6f;     // 每次迭代扩散度
    [Range(1, 8)] public int downSample = 2;                // 降低采样的分辨率
    [Range(0.0f, 1.0f)] public float luminanceThreshold = 0.6f;     // Bloom区域的阈值

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
            // 筛选区域
            int width = src.width / downSample;
            int height = src.height / downSample;

            mat.SetFloat("_LuminanceThreshold", luminanceThreshold);

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0, mat, 0);

            for (int i = 0; i < iterations; ++i)
            {
                mat.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);

                // Pass 1 Vertical
                Graphics.Blit(buffer0, buffer1, mat, 1);

                // Pass 2 Horizontal
                Graphics.Blit(buffer1, buffer0, mat, 2);

                RenderTexture.ReleaseTemporary(buffer1);

            }

            // _Bloom保存被处理过后的较亮区域
            mat.SetTexture("_Bloom", buffer0);
            // 混合bloom与原始图像
            Graphics.Blit(src, dst, mat, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src, dst);
        }
    }
}
