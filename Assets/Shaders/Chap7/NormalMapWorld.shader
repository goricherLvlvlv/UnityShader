// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chap7/NormalMapWorld"
{
	Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
		_BumpMap ("Normal Map", 2D) = "bump"{}			// 默认为模型自带的法线信息
		_BumpScale ("Bump Scale", Float) = 1.0
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
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			// application to view
			struct a2v{
				// 读取POSITION语义的数据
				float4 vertex : POSITION;
				// 读取法线数据
				float3 normal : NORMAL;
				// 读取切线信息
				float4 tangent : TANGENT;
				// 读取纹理信息, 模型的第一组纹理坐标
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				// 告知Unity, pos为裁剪空间的坐标
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};
			
			v2f vert(a2v v){
				v2f f;
                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

				// 填充贴图和法线贴图的UV值
				f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				f.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				// 一系列世界坐标
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;						// 世界坐标系下的物体坐标
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));	// 转置矩阵的逆矩阵
				fixed3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				// 按列存储在变量中
				// 同时包含从tangent space => world space的矩阵
				f.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				f.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				f.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				// 获取切线空间的数据
				fixed3 bump;
				bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				// TODO: 矩阵相乘的原因还是不对
				// 将其转换成世界空间下的数据
				/*
					下面的式子与该矩阵相乘的方式相同, 依旧是最熟悉的矩阵坐标转换
					下面的矩阵是切线坐标系在世界空间下的坐标, 即WorldToTangent矩阵的逆矩阵
					---------------------------------		---------
					|		|		|		|		|		|	|	|
					|	 tangent binormal normal	|	*	|  bump	|
					|		|		|		|		|		|	|	|
					---------------------------------		---------
				*/
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));
				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	
	}
	FallBack "Specular"
}
