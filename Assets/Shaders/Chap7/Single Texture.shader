// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chap7/Single Texture"
{
	Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white"{}
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
            fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			fixed _Gloss;

			// application to view
			struct a2v{
				// 读取POSITION语义的数据
				float4 vertex : POSITION;
				// 读取法线数据
				float3 normal : NORMAL;
				// 读取纹理信息, 模型的第一组纹理坐标
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				// 告知Unity, pos为裁剪空间的坐标
				float4 pos : SV_POSITION;

				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v){
				v2f f;
                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				// _MainTex_ST.xy 来进行缩放, _MainTex_ST.zw计算偏移量
				// TRANSFORM_TEX(v.texcoord, _MainTex); => 与下方相同功能, 为UnityCG.cginc的宏定义
				f.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				// 加载贴图, 并与选择的色调相结合
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
				// 使用的Blinn-Phong的光照模型
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	
	}
}
