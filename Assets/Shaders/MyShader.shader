Shader "Custom/Chap5/SimpleShader"
{
	Properties{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
	
		Pass{
			CGPROGRAM

			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag

			// 需要获取与Properties中同名变量
			fixed4 _Color;

			// application to view
			struct a2v{
				// 读取POSITION语义的数据
				float4 vertex : POSITION;
				// 读取法线数据
				float3 normal : NORMAL;
				// 读取纹理信息
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				// 告知Unity, pos为裁剪空间的坐标
				float4 pos : SV_POSITION;
				// COLOR0语义, 可以用于存储颜色信息
				float3 color : COLOR0;
			};
			
			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 c = i.color;
				c *= _Color.rgb;
				
				return fixed4(c, 1.0);
			}

			ENDCG
		}
	
	}
}
