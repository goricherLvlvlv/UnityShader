// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/GaussianBlur"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
		CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;
	
		struct v2f{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};
		
		v2f verticalVert(appdata_img v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;

			o.uv[0] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
			o.uv[1] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[2] = uv;
			o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[4] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

			return o;
		}

		v2f horizontalVert(appdata_img v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;

			o.uv[0] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			o.uv[1] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[4] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

			return o;
		}

		float4 frag(v2f i) : SV_TARGET{
			float weight[3] = {0.0545, 0.2442, 0.4026};
			fixed3 sum = fixed3(0, 0, 0);

			sum += tex2D(_MainTex, i.uv[0]).rgb * weight[0];
			sum += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[2]).rgb * weight[2];
			sum += tex2D(_MainTex, i.uv[3]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[4]).rgb * weight[0];

			return fixed4(sum, 1.0);
		}

		ENDCG

		ZTest Always Cull Off ZWrite Off

		Pass{
			Name "VERTICAL GAUSSIAN BLUR"

			CGPROGRAM

			#pragma vertex verticalVert
			#pragma fragment frag

			ENDCG
		}

		Pass{
			Name "HORIZONTAL GAUSSIAN BLUR"

			CGPROGRAM

			#pragma vertex horizontalVert
			#pragma fragment frag

			ENDCG
		}
	
	}
    FallBack Off
}
