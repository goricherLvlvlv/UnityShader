## **数学基础**
---------------------------------------------------------------------------
#### **笛卡尔坐标系**
- 三维笛卡尔坐标分成两种坐标系, 左手坐标系以及右手坐标系. 而在unity中则使用左手坐标系来进行计算.
---------------------------------------------------------------------------
#### **矢量计算**
- 点积(dot): 又被称为内积, $\vec{\alpha} \cdot \vec{\beta}$的数学意义是a在b上的投影乘上b的模长(反之亦然). 值为$|\alpha||\beta|\cos\theta$.
- 叉积(cross): 又被称为外积, $\vec{\alpha} \times \vec{\beta}$的数学意义则是获取一个同时垂直于a,b的向量, 而叉积的方向则是通过将四指(根据坐标系决定手的左右)指向向量a, 朝着b方向握拳, 大拇指所指向的方向则是向量的方向. 叉积的值则是$|\alpha||\beta|\sin\theta$.
---------------------------------------------------------------------------
#### **矩阵**
- 矩阵的乘法性质:
  - 不满足交换律, AB != BA(通常情况)
  - 满足结合律, A(BC) == (AB)C
- 特殊矩阵:
  - 方块矩阵: 即方阵, 行列数相等
  - 单位矩阵: 常用I来表示, 任何矩阵和单位矩阵相乘都是原来的值.
  - 转置矩阵: 即原矩阵进行翻转
  - 逆矩阵: 
    - $M*M^{-1} == M_1*M == I$
    - $(M^{-1})^{-1} == M$
    - $I^{-1} = I$
    - $(M^{-1})^T == (M^T)^{-1}$, 转置矩阵的逆矩阵 就是 逆矩阵的转置
    - $(AB)^{-1} == B^{-1}*A^{-1}$
  - 正交矩阵: 如果转置矩阵就是它的逆矩阵, 推到坐标空间上, 如果坐标的三个基矢量互相垂直, 则称这是一组正交基.
---------------------------------------------------------------------------
#### **变换**
- 线性变换: 保留矢量加和标量乘的变换, 即$f(x+y)=f(x)+f(y)与kf(x)=f(kx)$
  - 缩放, 旋转都是属于线性变换
  - 平移不属于线性变换, 但也是十分常用的变换方式
- 齐次坐标: n维空间使用n+1维表示, 称为齐次坐标空间. 将一个向量添加上w值则成为齐次坐标.
  - 平移: 平移矩阵作用于一个向量的w值, 所以当w为0时可以用来表示方向向量, 因为方向向量是不受平移影响的.
- 矩阵变换: $(x, y, z, 1)$
  - 平移矩阵: $(x+tx, y+ty, z+tz, 1)$
  $$
  \left[
  \begin{matrix}
    1 & 0 & 0 & tx\\
    0 & 1 & 0 & ty\\
    0 & 0 & 1 & tz\\
    0 & 0 & 0 & 1
    \end{matrix} 
  \right]
  $$
  - 缩放矩阵: $(kx*x, ky*y, kz*z, 1)$
  $$
  \left[
  \begin{matrix}
    kx & 0 & 0 & 0\\
    0 & ky & 0 & 0\\
    0 & 0 & kz & 0\\
    0 & 0 & 0 & 1
    \end{matrix} 
  \right]
  $$
  - 旋转矩阵(绕z轴):
  $$
  a为目标角度, b为源角度.\\
  \cos{a} = \cos{(\theta+b)} = \cos{\theta}\cos{b} - \sin{\theta}\sin{b}\\
  \sin{a} = \sin{(\theta+b)} = \sin{\theta}\cos{b} + \cos{\theta}\sin{b}\\
  x^\shortmid=x\cos{\theta}-y\sin{\theta}\\
  y^\shortmid=x\sin{\theta}+y\cos{\theta}\\
  $$
  $$
  \left[
  \begin{matrix}
    \cos{\theta} & -\sin{\theta} & 0 & 0\\
    \sin{\theta} & \cos{\theta} & 0 & 0\\
    0 & 0 & 1 & 0\\
    0 & 0 & 0 & 1\\
    \end{matrix} 
  \right]\\
  想要把z轴中心轴更换十分简单, 如y轴, 首先将线性变换3x3部分的每行上移一行, 如下所示\\
  \left[
  \begin{matrix}
    \sin{\theta} & \cos{\theta} & 0 & 0\\
    0 & 0 & 1 & 0\\
    \cos{\theta} & -\sin{\theta} & 0 & 0\\
    0 & 0 & 0 & 1
    \end{matrix} 
  \right]\\
  根据有数字1的行数, 每一列按照相同方式移动, 如下则是关于y轴旋转的矩阵了\\
  \left[
  \begin{matrix}
    \cos{\theta} & 0 & \sin{\theta} & 0\\
    0 & 1 & 0 & 0\\
    -\sin{\theta} & 0 & \cos{\theta} & 0\\
    0 & 0 & 0 & 1
    \end{matrix} 
  \right]\\
  $$
  - 复合变换: 将平移、旋转和缩放组合起来. 由于变换的结果是会受变换顺序所影响, 约定俗成的顺序如下所示
    - 缩放
    - 旋转
    - 平移
  - 旋转顺序: 如同复合变换, 不同的旋转顺序也会造成不同的结果. 在unity中使用zxy的旋转顺序, 但需要注意的是这个旋转顺序是直接作用于惯性坐标系的而非物体坐标系.
    - 惯性坐标系: 在不断的旋转过程中不会去调整旋转时所使用的坐标, 即此时多次旋转用的是同一个坐标系.
      ``` csharp
        // Space.World和Space.Self在此处取了个巧, 让Self的初始坐标系与World相同
        // Self坐标就能表示不断变化的物体坐标系, 而World就能表示不会变化的惯性坐标系
        cube.transform.Rotate(new Vector3(0, 0, z), Space.World);
        cube.transform.Rotate(new Vector3(x, 0, 0), Space.World);
        cube.transform.Rotate(new Vector3(0, y, 0), Space.World);
        // 或者如下
        cube.transform.Rotate(new Vector3(x, y, z));
      ```
    - 物体坐标系: 与惯性坐标系相反, 这个坐标系的物体每旋转一个方向后调整一下坐标系, 即直接使用物体自己的坐标系来进行旋转, 旋转顺序与惯性坐标系刚好相反时能获取相同的结果, 即为yxz的旋转顺序.
      ``` csharp
        cube.transform.Rotate(new Vector3(0, y, 0), Space.Self);
        cube.transform.Rotate(new Vector3(x, 0, 0), Space.Self);
        cube.transform.Rotate(new Vector3(0, 0, z), Space.Self);
      ```
---------------------------------------------------------------------------
#### **坐标空间**
$A_p = M_{c->p}A_c$

$B_c = M_{p->c}B_p$

如何确定一个$M_{c->p}$的变换矩阵. 首先可以观察一个点的坐标$(a,b,c)$是如何获得的, 这分为几步
>1. 从坐标原点开始
>2. 向x轴移动a, 向y轴移动b, 向z轴移动c

由上述规则可推出$A_c$的坐标的公式为$O_c+a*\vec{x}+b*\vec{y}+c*\vec{z}$, 此处$O_c,\vec{x},\vec{y},\vec{z}$都是坐标系C在坐标系P下的位置和向量, 而a,b,c则是点A在坐标系C下的坐标.
$$
A_p = O_c+a*\vec{x}+b*\vec{y}+c*\vec{z}\\
A_p = O_c+a*(x_{xc},y_{xc},z_{xc})+b*(x_{yc},y_{yc},z_{yc})+c*(x_{zc},y_{zc},z_{zc})\\
$$
$$
(x_{Oc},y_{Oc},z_{Oc})+
\left[
\begin{matrix}
  |&|&|\\
  \vec{x}&\vec{y}&\vec{z}\\
  |&|&|\\
\end{matrix}
\right]
*
\left[
\begin{matrix}
  a\\
  b\\
  c\\
\end{matrix}
\right]
$$
为了完成一个平移的变换, 我们将矩阵转为齐次坐标空间中:
$$
\left[
\begin{matrix}
  |&|&|&x_{Oc}\\
  \vec{x}&\vec{y}&\vec{z}&y_{Oc}\\
  |&|&|&z_{Oc}\\
  0&0&0&1\\
\end{matrix}
\right]
*
\left[
\begin{matrix}
  a\\
  b\\
  c\\
  1\\
\end{matrix}
\right]
$$
向量是不受平移所影响的, 所以针对向量使用的矩阵不需要转为齐次坐标系:
$$
\left[
\begin{matrix}
  |&|&|\\
  \vec{x_c}&\vec{y_c}&\vec{z_c}\\
  |&|&|\\
\end{matrix}
\right]
*
\left[
\begin{matrix}
  a\\
  b\\
  c\\
\end{matrix}
\right]
$$
以上就是$M_{c->p}$矩阵的计算流程了. 由于该矩阵是一个正交矩阵, 所以$M_{p->c}$矩阵则是该矩阵的转置矩阵, 可以通过乘上$\begin{matrix}[-&\vec{x_c}&-]^T\end{matrix}$来验证矩阵是否正确:
$$
\left[
\begin{matrix}
  -&\vec{x_c}&-\\
  -&\vec{y_c}&-\\
  -&\vec{z_c}&-\\
\end{matrix}
\right]
$$