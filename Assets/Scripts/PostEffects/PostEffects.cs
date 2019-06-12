using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffects : MonoBehaviour
{
    // 禁用后处理脚本
    protected void NotSupported()
    {
        this.enabled = false;
    }

    // 判断是否支持后处理
    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            Debug.LogWarning("This platform doesn't support image effects");
            return false;
        }

        return true;
    }

    protected void CheckResources()
    {
        if(CheckSupport() == false)
            NotSupported();
    }

    protected void Start()
    {
        CheckResources();
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        // 当shader不存在或不受平台支持时, 返回一个空的material
        if (shader == null || !shader.isSupported)
            return null;


        // material已经创建, 且shader已经是对应的shader
        // 则无需对该material再进行处理
        if (shader.isSupported && material && material.shader == shader)
            return material;

        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        if (material)
            return material;
        else
            return null;
    }
}
