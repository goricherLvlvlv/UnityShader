// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chap5/Diffuse"
{
	Properties{
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
	
		Pass{
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			// 需要获取与Properties中同名变量
            fixed4 _Diffuse;

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
				v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // fixed3 diffuse = _LightColor0 * saturate(dot(normalDir, lightDir)) * _Diffuse;
                fixed3 diffuse = _LightColor0 * saturate(dot(normalDir, lightDir)) * _Diffuse;
                f.color = diffuse + ambient;
                
                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	
	}
}
