// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/VelocityMotionBlur"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount ("Blur Amount", Float) = 1.0
	}
    SubShader
    {
        CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurAmount;

		struct v2f{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};

		v2f vert(appdata_img v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0){
				o.uv_depth.y = 1 - o.uv_depth.y;
			}
			#endif

			return o;
		}

		fixed4 frag(v2f i) : SV_TARGET{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			float4 NDCPos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			float4 D = mul(_CurrentViewProjectionInverseMatrix, NDCPos);
			float4 worldPos = D / D.w;

			float4 curPos = NDCPos;
			float4 prePos = mul(_PreviousViewProjectionMatrix, worldPos);
			prePos /= prePos.w;

			float vecColRate[3] = { 0.7,0.2,0.1 };
			float2 velocity = (curPos.xy - prePos.xy) / 2.0f;

			float4 color = tex2D(_MainTex, i.uv) * vecColRate[0];
			i.uv += velocity * _BlurAmount;
		
			// loop
			color += tex2D(_MainTex, i.uv + velocity * _BlurAmount) * vecColRate[1];
			color += tex2D(_MainTex, i.uv + 2 * velocity * _BlurAmount) * vecColRate[2];

			//color /= 3;

			return fixed4(color.rgb, 1.0);
		}

		ENDCG

		Pass{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		
		}
    }
    FallBack Off
}
