// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/MotionBlur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount ("Blur Amount", Float) = 1.0
	}
	SubShader {
		ZTest Always Cull Off ZWrite Off
		
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
		
			sampler2D _MainTex;
			fixed _BlurAmount;
		
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			#pragma vertex vert  
			#pragma fragment frag
			
			v2f vert(appdata_img v) {
				v2f o;
			
				o.pos = UnityObjectToClipPos(v.vertex);
			
				o.uv = v.texcoord;
					 
				return o;
			}
		
			fixed4 frag (v2f i) : SV_Target {
				return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
			}

			ENDCG
		}
		

	}
 	FallBack Off
}
