// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chap6/Diffuse Per Pixel"
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

				float3 normalDir : TEXCOORD0;

				float3 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v){
				v2f f;

                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

                // 提供法线信息
				f.normalDir = normalize(UnityObjectToWorldNormal(v.normal));

				// 提供物体坐标
				f.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, i.normalDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 reflectDir = normalize(-lightDir + 2 * dot(lightDir, i.normalDir) * i.normalDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(viewDir, reflectDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	
	}
}
