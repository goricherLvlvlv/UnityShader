## **坐标系**
---------------------------------------------------------------------------
#### **坐标空间转换流程**
1. 模型空间(model space):
   - 使用**左手坐标系**.
   - 又被称为**对象空间**(object space)或**局部空间**(local space).
   - 当物体发生平移旋转时, 它的坐标系也会发生平移和旋转.
2. 世界空间(world space):
   - 使用**左手坐标系**.
   - 转换流程的第一步就是从**模型空间**转换到**世界空间**, 通过Chap4_Math中的转换矩阵即可实现这个转换.
3. 观察空间(view space):
   - 使用**右手坐标系**. 与其他的坐标系z轴相反, 摄像机的正前方则是-z的方向.
   - 又被称为**摄像机空间**(camera space). 它是模型空间的一个特例, 这个模型则是摄像机.
   - 从**世界空间**转换到**观察空间**同样使用上述的矩阵. 但要注意最后对z方向进行取反, 因为两者使用的坐标系方向不同.
4. 裁剪空间(clip space):
   - 使用**左手坐标系**.
   - 使用**裁剪矩阵**(又被称为**投影矩阵**(projection matrix))进行变换. 常用的两个矩阵为正交投影和透视投影. 透视投影有着近大远小的视觉效果, 正交投影则会完全一致适合2D游戏以及UI界面.
   - 投影矩阵并不会进行真正的投影计算, 即不会在这个时候把3d视图变为2d的, 但是会将视椎体内的变换成齐次坐标系(4D空间), 也就是裁剪空间.
   ![](frustum.png)
   ![](topFrustum.png)

   - 投影矩阵推导如下:

    ![](https://latex.codecogs.com/png.latex?&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;x_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;y_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;z_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;w_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;&space;&space;&space;&space;&space;&space;&space;&space;=&space;&space;&space;&space;&space;&space;&space;&space;&space;M_{projection}&space;*&space;&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;x_{eye}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;y_{eye}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;z_{eye}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;w_{eye}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;)


    ![](https://latex.codecogs.com/png.latex?&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;x_{ndc}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;y_{ndc}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;z_{ndc}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;&space;&space;&space;&space;&space;&space;&space;&space;=&space;&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;x_{clip}/w_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;y_{clip}/w_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;z_{clip}/w_{clip}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;)

     - 在空间中有一点, 坐标为![](https://latex.codecogs.com/png.latex?(x_e,&space;y_e,&space;z_e)). 与近平面相交于一点, 坐标为![](https://latex.codecogs.com/png.latex?(x_p,&space;y_p,&space;z_p)).

     - ![](https://latex.codecogs.com/png.latex?\cfrac{-n}{z_e}&space;=&space;\cfrac{x_p}{x_e})与![](https://latex.codecogs.com/png.latex?\cfrac{-n}{z_e}&space;=&space;\cfrac{y_p}{y_e}).

     - 关于y轴同理可得, 从而推出交点坐标![](https://latex.codecogs.com/png.latex?(\cfrac{-n}{z_e}x_e,&space;\cfrac{-n}{z_e}y_e,&space;-n)). 在xy的平面上只要分别除以l和r就能获得(-1,1)的区间, 为了让z轴也处于(-1,1)的区间, 所以使用![](https://latex.codecogs.com/png.latex?-z_e)来作w值. ![](https://latex.codecogs.com/png.latex?z_{ndc}&space;=&space;(k*z_e+b)/-z_e), ![](https://latex.codecogs.com/png.latex?z_{ndc})在-1,1的位置则可产生两条公式:

       - ![](https://latex.codecogs.com/png.latex?-1&space;=&space;-k&space;+&space;b/n)

       - ![](https://latex.codecogs.com/png.latex?1&space;=&space;-k&space;+&space;b/f)

       - ![](https://latex.codecogs.com/png.latex?b&space;=&space;\cfrac{2fn}{n-f},&space;k&space;=&space;\cfrac{n+f}{n-f})

       - ![](https://latex.codecogs.com/png.latex?z_{clip}&space;=&space;\cfrac{n+f}{n-f}z_e&space;+&space;\cfrac{2fn}{n-f})

     - 关于xy平面的计算:
       - ![](https://latex.codecogs.com/png.latex?x_{ndc}&space;=&space;\cfrac{1--1}{r-l}x_p+b).

       - ![](https://latex.codecogs.com/png.latex?1&space;=&space;\cfrac{2r}{r-l}&space;+&space;b) => ![](https://latex.codecogs.com/png.latex?b&space;=&space;\cfrac{l+r}{l-r})

       - ![](https://latex.codecogs.com/png.latex?x_{ndc}&space;=&space;\cfrac{2}{r-l}*\cfrac{nx_e}{-z_e}&space;+&space;\cfrac{l+r}{l-r})

       - ![](https://latex.codecogs.com/png.latex?x_{clip}&space;=&space;\cfrac{2nx_e}{r-l}&space;+&space;\cfrac{(r+l)z_e}{r-l})

       - ![](https://latex.codecogs.com/png.latex?y_{clip}&space;=&space;\cfrac{2ny_e}{t-b}&space;+&space;\cfrac{(t+b)z_e}{t-b})

     - 推出矩阵如下:

    ![](https://latex.codecogs.com/png.latex?&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\cfrac{2n}{r-l}&0&\\cfrac{r+l}{r-l}&0\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&\\cfrac{2n}{t-b}&\\cfrac{t+b}{t-b}&0\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&0&\\cfrac{n+f}{n-f}&\\cfrac{2fn}{n-f}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&0&-1&0\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;)

    ![](orthographic.png)
    - 正交投影矩阵:
      - ![](https://latex.codecogs.com/png.latex?x_{ndc}&space;=&space;\cfrac{2}{r-l}x_e&space;+&space;\beta), 代入![](https://latex.codecogs.com/png.latex?x_{ndc})为-1, ![](https://latex.codecogs.com/png.latex?x_e)为l.

      - ![](https://latex.codecogs.com/png.latex?\beta&space;=&space;-\cfrac{r+l}{r-l})

      - 同理可得, ![](https://latex.codecogs.com/png.latex?y_{ndc}&space;=&space;\cfrac{2}{t-b}y_e&space;-&space;\cfrac{t+b}{t-b})

      - ![](https://latex.codecogs.com/png.latex?z_{ndc}=\cfrac{2}{-f+n}z_e+\beta), 代入![](https://latex.codecogs.com/png.latex?z_{ndc})为-1, ![](https://latex.codecogs.com/png.latex?z_e)为-n. ![](https://latex.codecogs.com/png.latex?\beta=-1+\cfrac{2n}{n-f})

      - ![](https://latex.codecogs.com/png.latex?z_{ndc}=-\cfrac{2}{f-n}z_e-\cfrac{f+n}{f-n})

      - 推出矩阵如下:

    ![](https://latex.codecogs.com/png.latex?&space;&space;&space;&space;&space;&space;&space;&space;&space;\\left[&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\begin{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\cfrac{2}{r-l}&0&0&-\\cfrac{r+l}{r-l}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&\\cfrac{2}{t-b}&0&-\\cfrac{t+b}{t-b}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&0&-\\cfrac{2}{f-n}&-\\cfrac{f+n}{f-n}\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;0&0&0&1\\\\&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\end{matrix}&space;&space;&space;&space;&space;&space;&space;&space;&space;&space;\\right]&space;)


5. 屏幕空间(screen space):
   - 由于上述的齐次坐标的w值为![](https://latex.codecogs.com/png.latex?-z_e), 且![](https://latex.codecogs.com/png.latex?x_{clip}/w_{clip}\in{[-1,1]}), 所以可以得知clip空间的形状和大小应该如下图所示:

   ![](perspective_clip2ndc.png)
   - 获得Normalized Device Coordination后, 将这个正方体的面映射到屏幕上, 这个映射较为简单, 只是一个缩放的过程.
---------------------------------------------------------------------------
#### **Unity Shader**
- 矩阵: 
  - 在Unity Shader中的矩阵采用右乘的方式. 有时候也可以使用左乘来减少转置矩阵的计算.
  - 在Shaderlab中构建矩阵, 采用的是行优先的顺序, 即先填充每一行的参数, 之后再填充下一行. 而在unity的脚本中也有一个Matrix类, 这时采用的则是列优先的顺序.
- 法线变换: 法线在空间变换时, 直接使用空间变换矩阵会得到错误的结果. 此时则需要更换一个矩阵G来作为法线变换的转换矩阵.
  - ![](https://latex.codecogs.com/png.latex?T_A\cdot&space;N_A&space;=&space;0,&space;T_B\cdot&space;N_B&space;=&space;0)

  - ![](https://latex.codecogs.com/png.latex?T_B&space;=&space;M_{A\to{B}}T_A,&space;M_{A\to{B}}T_A&space;\cdot&space;GN_A&space;=&space;0)

  - ![](https://latex.codecogs.com/png.latex?T_B&space;\cdot&space;N_B&space;=&space;(T_B)^T&space;N_B&space;=&space;0)

  - ![](https://latex.codecogs.com/png.latex?(M_{A\to{B}}T_A)^T&space;GN_A&space;=&space;T_A^T&space;M_{A\to{B}}^T&space;G&space;N_A&space;=&space;0)

  - 当![](https://latex.codecogs.com/png.latex?M_{A\to{B}}^T&space;G&space;=&space;I)时, 上述式子成立. 则![](https://latex.codecogs.com/png.latex?G&space;=&space;(M_{A\to{B}}^T)^{-1})

  - 在shaderlab中使用UNITY_MATRIX_IT_MV来表示这个矩阵(从model空间到view空间).