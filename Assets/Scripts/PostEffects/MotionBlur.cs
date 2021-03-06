﻿using UnityEngine;
using System.Collections;

public class MotionBlur : PostEffects
{
    [Range(0.0f, 0.9f)] public float blurAmount = 0.5f;
    private RenderTexture accumulationTexture;

    public Shader shader;
    private Material mat;

    public Material material {
        get {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }
    }
    

    void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if (accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = RenderTexture.GetTemporary(src.width, src.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, accumulationTexture);
            }

            // 仅做声明作用, 并非忘记释放资源
            accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            // 在shader中进行blend操作, 场景和accmulationTexture都不是opaque
            // 猜测是未回收accmulation贴图, 所以在场景中会保留下来, 最后会混合
            Graphics.Blit(src, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
