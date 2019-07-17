// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap14/Cartoon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader
    {
		Pass{
			Name "OUTLINE"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float _Outline;
			float4 _OutlineColor;

			struct a2v{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v){
				v2f o;

				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				normal.z = -0.5;	// view space下, 当normal.z小于0时, 方向指向屏幕里
				pos = pos + float4(normalize(normal), 0) * _Outline;	// 往normal方向扩张, 扩张的宽度由_Outline来确定
				o.pos = mul(UNITY_MATRIX_P, pos);

				return o;
			}

			float4 frag(v2f i) : SV_TARGET{
				return float4(_OutlineColor.rgb, 1);
			}
			ENDCG
		}

		Pass{
			Tags {"LightMode" = "ForwardBase"}
			Cull Back
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			sampler2D _Ramp;
			float4 _Ramp_ST;
			float4 _Specular;
			float _SpecularScale;

			struct a2v{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normal : NORMAL;

			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)

			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				TRANSFER_SHADOW(o);


				return o;
			}
			
			float4 frag(v2f i) : SV_TARGET{
				float3 normalDir = normalize(i.worldNormal);
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 halfDir = normalize(lightDir + viewDir);

				// 计算half lambert的blinn phong光照模型
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed3 albedo = c.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed diff = dot(normalDir, lightDir);
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				diff = (diff * 0.5 + 0.5) * atten;

				fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

				fixed spec = dot(normalDir, lightDir);
				fixed w = fwidth(spec) * 2.0;
				fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
