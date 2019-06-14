Shader "Custom/PostEffects/Sharpness"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SharpSize ("Sharp Size", Float) = 1.0
    }
    SubShader
    {
		Pass{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			float _SharpSize;

			struct v2f{
				float4 pos : SV_POSITION;
				half2 uv[9] : TEXCOORD0;
			};

			v2f vert(appdata_img v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				half2 uv = v.texcoord;
				o.uv[0] = uv +_MainTex_TexelSize.xy * half2(-1, 1) * _SharpSize;
				o.uv[1] = uv +_MainTex_TexelSize.xy * half2(0, 1) * _SharpSize;
				o.uv[2] = uv +_MainTex_TexelSize.xy * half2(1, 1) * _SharpSize;
				o.uv[3] = uv +_MainTex_TexelSize.xy * half2(-1, 0) * _SharpSize;
				o.uv[4] = uv +_MainTex_TexelSize.xy * half2(0, 0) * _SharpSize;
				o.uv[5] = uv +_MainTex_TexelSize.xy * half2(1, 0) * _SharpSize;
				o.uv[6] = uv +_MainTex_TexelSize.xy * half2(-1, -1) * _SharpSize;
				o.uv[7] = uv +_MainTex_TexelSize.xy * half2(0, -1) * _SharpSize;
				o.uv[8] = uv +_MainTex_TexelSize.xy * half2(1, -1) * _SharpSize;

				return o;
			}

			float4 frag(v2f i) : SV_TARGET{

				const half sharp[9] = {	-1, -1, -1,
										-1, 9, -1,
										-1, -1, -1 };

				
				float3 color = 0;
				color += tex2D(_MainTex, i.uv[0]) * sharp[0];
				color += tex2D(_MainTex, i.uv[1]) * sharp[1];
				color += tex2D(_MainTex, i.uv[2]) * sharp[2];
				color += tex2D(_MainTex, i.uv[3]) * sharp[3];
				color += tex2D(_MainTex, i.uv[4]) * sharp[4];
				color += tex2D(_MainTex, i.uv[5]) * sharp[5];
				color += tex2D(_MainTex, i.uv[6]) * sharp[6];
				color += tex2D(_MainTex, i.uv[7]) * sharp[7];
				color += tex2D(_MainTex, i.uv[8]) * sharp[8];

				return fixed4(color, 1);
			}

			ENDCG
		}
    }
    FallBack Off
}
