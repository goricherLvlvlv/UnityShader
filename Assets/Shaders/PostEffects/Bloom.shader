// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/Bloom"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bloom ("Bloom", 2D) = "black" {}
		_BlurSize ("Blur Size", Float) = 1.0
		_LuminanceThreshold ("Luminance Threshold", Float) = 0.5
    }
    SubShader
    {
		CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;
		float _LuminanceThreshold;
		sampler2D _Bloom;
		

		///////////////////////////////////////////////////////////////////////
		///////////					采集较亮区域					///////////
		///////////////////////////////////////////////////////////////////////
		struct v2fThreshold{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		v2fThreshold thresholdVert(appdata_img v){
			v2fThreshold o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;

			return o;
		}
		
		fixed Luminance(fixed4 color){
			return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
		}

		float4 thresholdFrag(v2fThreshold i) : SV_TARGET{
			fixed4 c = tex2D(_MainTex, i.uv);
			fixed val = clamp(Luminance(c) - _LuminanceThreshold, 0.0, 1.0);

			return c * val;
		}

		///////////////////////////////////////////////////////////////////////
		///////////						高斯模糊					///////////
		///////////////////////////////////////////////////////////////////////
		//struct v2fGaussianBlur{
		//	float4 pos : SV_POSITION;
		//	half2 uv[5] : TEXCOORD0;
		//};

		//v2fGaussianBlur verticalVert(appdata_img v){
		//	v2fGaussianBlur o;
		//	o.pos = UnityObjectToClipPos(v.vertex);
		//	half2 uv = v.texcoord;

		//	o.uv[0] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
		//	o.uv[1] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
		//	o.uv[2] = uv;
		//	o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
		//	o.uv[4] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

		//	return o;
		//}

		//v2fGaussianBlur horizontalVert(appdata_img v){
		//	v2fGaussianBlur o;
		//	o.pos = UnityObjectToClipPos(v.vertex);
		//	half2 uv = v.texcoord;

		//	o.uv[0] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
		//	o.uv[1] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
		//	o.uv[2] = uv;
		//	o.uv[3] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
		//	o.uv[4] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

		//	return o;
		//}

		//float4 gaussianBlurFrag(v2fGaussianBlur i) : SV_TARGET{
		//	float weight[3] = {0.0545, 0.2442, 0.4026};
		//	fixed3 sum = fixed3(0, 0, 0);

		//	sum += tex2D(_MainTex, i.uv[0]).rgb * weight[0];
		//	sum += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
		//	sum += tex2D(_MainTex, i.uv[2]).rgb * weight[2];
		//	sum += tex2D(_MainTex, i.uv[3]).rgb * weight[1];
		//	sum += tex2D(_MainTex, i.uv[4]).rgb * weight[0];

		//	return fixed4(sum, 1.0);
		//}

		///////////////////////////////////////////////////////////////////////
		///////////						混合						///////////
		///////////////////////////////////////////////////////////////////////
		struct v2fBloom{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
		};

		v2fBloom bloomVert(appdata_img v){
			v2fBloom o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = v.texcoord;
			o.uv.zw = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0.0)
				o.uv.w = 1.0 - o.uv.w;
			#endif

			return o;
		}

		float4 bloomFrag(v2fBloom i) : SV_TARGET{
			return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
		}

		ENDCG


		ZTest Always Cull Off ZWrite Off

		Pass{
			Name "Threshold Judgement"

			CGPROGRAM

			#pragma vertex thresholdVert
			#pragma fragment thresholdFrag

			ENDCG
		}

		//Pass{
		//	Name "Vertical Gaussian Blur"

		//	CGPROGRAM

		//	#pragma vertex verticalVert
		//	#pragma fragment gaussianBlurFrag

		//	ENDCG
		//}

		//Pass{
		//	Name "Horizontal Gaussian Blur"

		//	CGPROGRAM

		//	#pragma vertex horizontalVert
		//	#pragma fragment gaussianBlurFrag

		//	ENDCG
		//}

		UsePass "Custom/PostEffects/GaussianBlur/VERTICAL GAUSSIAN BLUR"
		UsePass "Custom/PostEffects/GaussianBlur/HORIZONTAL GAUSSIAN BLUR"

		Pass{
			Name "Bloom"

			CGPROGRAM

			#pragma vertex bloomVert
			#pragma fragment bloomFrag

			ENDCG
		}
	
	}
    FallBack Off
}
