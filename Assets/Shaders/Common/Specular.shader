// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Common/Specular"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
            float4 _Specular;
            float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 Tangent2World0 : TEXCOORD1;
				float4 Tangent2World1 : TEXCOORD2;
				float4 Tangent2World2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.Tangent2World0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.Tangent2World1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.Tangent2World2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
                // light value
				fixed3 albedo;
				fixed3 ambient;
				fixed3 diffuse;
                fixed3 specular;

                // direction value
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.Tangent2World0.xyz, bump), dot(i.Tangent2World1.xyz, bump), dot(i.Tangent2World2.xyz, bump)));
				float3 worldPos = float3(i.Tangent2World0.w, i.Tangent2World1.w, i.Tangent2World2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                fixed3 halfDir = normalize(viewDir + lightDir);
			
				albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				diffuse = _LightColor0 * albedo * saturate(dot(bump, lightDir));
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                specular = _LightColor0 * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);    

				return fixed4(ambient + (specular + diffuse) * atten, 1.0);
			}

			ENDCG
		}

		Pass{
			Tags { "LightMode" = "ForwardAdd" }

			Blend One One

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdadd

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
            float4 _Specular;
            float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 Tangent2World0 : TEXCOORD1;
				float4 Tangent2World1 : TEXCOORD2;
				float4 Tangent2World2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.Tangent2World0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.Tangent2World1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.Tangent2World2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
                // light value
				fixed3 albedo;
				fixed3 ambient;
				fixed3 diffuse;
                fixed3 specular;

                // direction value
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.Tangent2World0.xyz, bump), dot(i.Tangent2World1.xyz, bump), dot(i.Tangent2World2.xyz, bump)));
				float3 worldPos = float3(i.Tangent2World0.w, i.Tangent2World1.w, i.Tangent2World2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                fixed3 halfDir = normalize(viewDir + lightDir);
			
				albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				diffuse = _LightColor0 * albedo * saturate(dot(bump, lightDir));
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                specular = _LightColor0 * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);    

				return fixed4((specular + diffuse) * atten, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Specular"
}
