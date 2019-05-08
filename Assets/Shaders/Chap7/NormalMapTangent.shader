// 在切线空间下计算光照, 法线贴图
Shader "Custom/Chap7/NormalMapTangent"
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

				// uv ==> xy存储贴图, zw存储法线贴图(法线贴图的z轴由xy来计算)
				float4 uv : TEXCOORD0;
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
				f.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				// 计算binormal, tangent.w用于决定副法线的方向
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				// 建立坐标系转换矩阵
				// x轴为切线, z轴为模型空间法线
				// y轴为x,z的叉乘结果
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				f.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				// 与原shader的区别在于, 现在的光照计算在切线空间
				// 光照模型还是blinn-phong

				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 获取法线贴图的texel
				// uv的zw分量存储的normal texture的pixel
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);										
				fixed3 tangentNormal;

				// 即tangentNormal = (packedNormal * 2 - 1) * _BumpScale || normal = pixel * 2 - 1
				tangentNormal = UnpackNormal(packedNormal);									
				tangentNormal.xy *= _BumpScale;

				// w分量指的法线的深度? ==> 这是由于不同的法线贴图的压缩算法导致的
				// 最好的方式是将贴图类型选为Normal map, 而后使用如上的内置函数UnpackNormal, 让Unity来判断压缩算法
				//packedNormal.x *= packedNormal.w;
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));	// sqrt(1-|xy|), 即法线在Z轴上的长度分量(表示为深度)

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);

				// TODO: 重新看vertex中rotation的转换矩阵的方法(空间变换)
			}

			ENDCG
		}
	
	}
	FallBack "Specular"
}
