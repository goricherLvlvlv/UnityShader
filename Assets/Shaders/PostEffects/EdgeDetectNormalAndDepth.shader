// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/EdgeDetectNormalAndDepth"
{

	Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
		_SampleDistance ("Sample Distance", Float) = 1.0
		_Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)
    }
    SubShader
    {
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;  
		uniform half4 _MainTex_TexelSize;
		fixed _EdgeOnly;
		fixed4 _EdgeColor;
		fixed4 _BackgroundColor;
		float _SampleDistance;
		fixed4 _Sensitivity;
		sampler2D _CameraDepthNormalsTexture;

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vert(appdata_img v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;

			o.uv[0] = uv;
			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
			#endif

			/*
				1	2
				  0
				3	4
			*/

			o.uv[1] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance;
			o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDistance;
			o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDistance;
			o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDistance;

			return o;
		}

		half checkSame(fixed4 center, fixed4 sample){
			fixed2 centerNormal = center.xy;
			fixed centerDepth = DecodeFloatRG(center.zw);
			fixed2 sampleNormal = sample.xy;
			fixed sampleDepth = DecodeFloatRG(sample.zw);

			half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
			half diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;

			return ((diffNormal.x + diffNormal.y) < 0.1) * (diffDepth < 0.1 * centerDepth) ? 1.0 : 0.0;
		}

		fixed4 frag(v2f i) : SV_TARGET{
			
			// Roberts算子
			/*
				Gx			Gy
				[-1  0		[0  -1
				  0  1]		 1   0]
			
			*/
			
			fixed4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
			fixed4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
			fixed4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
			fixed4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

			half edge = 1.0;
			edge *= checkSame(sample1, sample4);
			edge *= checkSame(sample2, sample3);

			fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
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
