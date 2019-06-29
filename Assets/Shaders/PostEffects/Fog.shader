// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/Fog"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_FogDensity ("Fog Density", Float) = 1.0
		_FogColor ("Fog Color", Color) = (1, 1, 1, 1)
		_FogStart ("Fog Start", Float) = 0.0
		_FogEnd ("Fog End", Float) = 1.0
    }
    SubShader
    {
		CGINCLUDE
		#include "UnityCG.cginc"

		float4x4 _FrustumCornersRay;
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		half4 _MainTex_ST;
		sampler2D _CameraDepthTexture;
		float _FogDensity;
		fixed4 _FogColor;
		float _FogStart;
		float _FogEnd;

		struct v2f{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
			float4 interpolatedRay : TEXCOORD2;
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

			int index = 0;
			if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
				index = 0;
			else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
				index = 1;
			else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
				index = 2;
			else if(v.texcoord.x < 0.5 && v.texcoord.y > 0.5)
				index = 3;


			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0){
				index = 3 - index;
			}
			#endif

			o.interpolatedRay = _FrustumCornersRay[index];
			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			/*
			LinearEyeDepth负责将深度图的采样转为view space上
			
							   Far + Near   2 * Near * Far
			z_clip = -z_view * ---------- - --------------
			                   Far - Near     Far - Near
			
			w_clip = -z_view

			                          Far + Near      2 * Near * Far
			z_ndc = z_clip / w_clip = ---------- + ---------------------
			                          Far - Near   (Far - Near) * z_view

			深度图中 d = 0.5 * z_ndc + 0.5, z_ndc = 2d - 1

			[d - far / (far-near)] * z_view = near*far/(far-near)
			[d*(far-near) - far] * z_view = near*far
			z_view = (near*far)/[d*(far-near) - far]

							   1
			z_view = ---------------------
			         Far - Near        1
					 ---------- * d - ----
					 Far * Near	      Near

			z_view小于零(在相机的正方向范围内)

			LinearEyeDepth中_ZBufferParams中的数值
			x is (1-far/near), y is (far/near), z is (x/far) and w is (y/far).
			z is (near - far)/(far * near) and w is (1/near)
			
			inline float LinearEyeDepth( float z )
			{
				return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
			}

			可以发现该值为z_view的相反值, 即在相机正方向的Z轴值取反, 深度值的正值

			*/
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

			float fogDensity = (_FogEnd - worldPos.z) / (_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity * _FogDensity);

			fixed4 finalColor = tex2D(_MainTex, i.uv);
			finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

			return finalColor;
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
