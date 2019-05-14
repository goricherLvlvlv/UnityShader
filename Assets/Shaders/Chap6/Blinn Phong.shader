// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chap6/Blinn Phong"
{
	Properties{
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}

	SubShader
	{
	
		Pass{
            Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			// 需要获取与Properties中同名变量
            fixed4 _Diffuse;
			fixed4 _Specular;
			fixed _Gloss;

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
                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));   // 法线方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);              // 光照方向

                // 漫反射光 C_light * M_diffuse * max(0, normal•light)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normalDir, lightDir));

				// 高光反射(镜面反射) C_light * M_specular * max(0, normal•half)^Gloss
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				fixed3 halfDir = normalize(lightDir + viewDir);
				
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(normalDir, halfDir)), _Gloss);

                // 计算颜色
                f.color = diffuse + ambient + specular;

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	
	}
}
