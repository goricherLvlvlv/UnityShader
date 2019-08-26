## ***Unity Shader基础***
---------------------------------------------------------------------------
#### Shader模板
Unity包含4种Shader模板.
1. Standard Surface Shader
    >表面着色器
2. Unlit Shader
    >顶点着色器, 片元着色器
3. Image Effect Shader
    >屏幕后处理
4. Compute Shader
    >计算着色器, 用于各种渲染加速, GPGPU, CUDA...
---------------------------------------------------------------------------
#### Subshader与Pass
Unity可以使用多个Subshader和多个Pass. unity在加载shader文件时会扫描一遍所有的Subshader, 寻找到第一个可以在当前平台运行的Subshader(如果没有则使用Fallback中的shader)来执行. 而多个Pass则是都会被执行, 每一个Pass都有完整的渲染流程, 所以Pass过多会对性能有这较大的影响.

---------------------------------------------------------------------------
#### ShaderLab
ShaderLab本质上并不是真正的Shader, 而是给Unity识别的文本文件, Unity会将这种文本文件编译成Vertex Shader和Fragment Shader. 实际上的Unity不存在那么多Shader类型, 最后都会被编译成顶点着色器与片段着色器.