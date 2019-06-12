Shader "Custom/Chap8/AlphaTest"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
		// Queue控制渲染顺序, AlphaTest说明需要透明测试
		// IgnoreProjector为Ture, 让物体不会收到投影器的影响
		// RenderType对着色器进行分类
		Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		Cull Off

		Pass{
			Tags { "LightMode" = "ForwardBase" }	

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				// Shadow Coordinates
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormalDir = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				// Alpha Test
				clip(texColor.a - _Cutoff);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldNormalDir, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4(ambient + diffuse * atten, 1.0);
			}

			ENDCG
		}


		Pass{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On 
			ZTest LEqual

			CGPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			#define UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
			#define UNITY_STANDARD_USE_DITHER_MASK
			#define UNITY_STANDARD_USE_SHADOW_UVS

			#include "UnityStandardShadow.cginc"

			fixed _AlphaScale;

			struct VertexOutput{
				V2F_SHADOW_CASTER_NOPOS
				float2 tex : TEXCOORD1;
			};

			void vert(VertexInput v, out VertexOutput o, out float4 opos : SV_POSITION){
				TRANSFER_SHADOW_CASTER_NOPOS(o, opos)
				o.tex = v.uv0;
			}

			half4 frag(VertexOutput i, UNITY_VPOS_TYPE vpos : VPOS) : SV_TARGET{
				half alpha = tex2D(_MainTex, i.tex).a * _AlphaScale;

				half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy * 0.25, alpha * 0.9375)).a;

				// 打孔的阴影表示透明
				clip(alphaRef - 0.01);
				
				
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}
    }
	FallBack "Transparent/Cutout/VertexLit"
}
