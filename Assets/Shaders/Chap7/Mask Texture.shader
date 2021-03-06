﻿// 在切线空间下计算光照, 法线贴图
Shader "Custom/Chap7/Mask Texture"
{
	Properties{
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularMask ("Specular Mask", 2D) = "white"{}	// 高光反射遮罩贴图
		_SpecularScale ("Specular Scale", Float) = 1.0
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
			float4 _MainTex_ST;			// _BumpMap, _SpecularMask来共用该变量
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			fixed _Gloss;
			sampler2D _BumpMap;
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

				// uv ==> xy存储贴图, zw存储法线贴图(法线贴图的z轴由xy来计算)
				// 此处为了节省寄存器, 放弃了_BumpMap_ST, 全部使用_MainTex_ST
				// 所以uv没必要再存zw节点了(因为和xy相等), 所以改成float2类型
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v){
				v2f f;
                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

				// _MainTex_ST.xy 来进行缩放, _MainTex_ST.zw计算偏移量
				// TRANSFORM_TEX(v.texcoord, _MainTex); => 与下方相同功能, 为UnityCG.cginc的宏定义
				f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				// 计算binormal, tangent.w用于决定副法线的方向
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				// 建立坐标系转换矩阵
				// x轴为切线, z轴为模型空间法线
				// y轴为x,z的叉乘结果
				
				//float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				//f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				//f.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				// 上述坐标转换会出现问题, 因为使用了模型空间下的v.normal
				// 采用获取世界坐标系中的光线和视野Direction
				// 将其转换为切线空间下来使用, 而不是从Object Space => Tangent Space
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				float3x3 matrixWorldToTangent = float3x3(
					worldTangent, worldBinormal, worldNormal
				);

				f.lightDir = mul(matrixWorldToTangent, WorldSpaceLightDir(v.vertex));
				f.viewDir = mul(matrixWorldToTangent, WorldSpaceViewDir(v.vertex));
                
				return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				// 与原shader的区别在于, 现在的光照计算在切线空间
				// 光照模型还是blinn-phong

				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 获取法线贴图的texel
				// uv的zw分量存储的normal texture的pixel
				fixed4 packedNormal = tex2D(_BumpMap, i.uv);										
				fixed3 tangentNormal;

				// 即tangentNormal = (packedNormal * 2 - 1) * _BumpScale || normal = pixel * 2 - 1
				tangentNormal = UnpackNormal(packedNormal);									
				tangentNormal.xy *= _BumpScale;

				// w分量指的法线的深度? ==> 这是由于不同的法线贴图的压缩算法导致的
				// 最好的方式是将贴图类型选为Normal map, 让Unity自行压缩
				// 而后使用如上的内置函数UnpackNormal, 让Unity来判断压缩后的采样算法

				//packedNormal.x *= packedNormal.w;
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));	

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 specular = specularMask * _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);

				// TODO: 重新看vertex中rotation的转换矩阵的方法(空间变换)
			}

			ENDCG
		}
	
	}
	// 注意: 没有FallBack将可能没有阴影
	// 在Unity中阴影计算是一个单独的系统
	// 因为没有去写ShadowCaster/ShadowCollector的Pass
	// 所以需要使用FallBack来为我实现阴影的细节

	FallBack "Specular"
	// 不过还是不能接受阴影
	// TODO: unity shader第九章阴影部分
}
