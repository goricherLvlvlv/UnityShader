## **前向渲染**
---------------------------------------------------------------------------
#### **设置**
- Tag{ "LightMode" = "ForwardBase" }

```
该Pass为渲染一整个物体所需要的操作
逐像素光照
Pass
{
    for (each primitive in this model)
    {
        for (each fragment in primitive)
        {
            if (failed in depth test)
                discard;
            else
            {
                float4 color = Shading(materialInfo, pos, normal, lightDir, viewDir);
                writeFrameBuffer(fragment, color);
            }
        }
    }

}
```
- 光照的面板可以调节光的模式, Important代表这个光使用逐像素的光照, Not Important则使用的逐顶点的光照节省计算.