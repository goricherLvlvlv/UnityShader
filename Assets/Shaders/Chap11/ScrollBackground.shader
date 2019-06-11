// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap11/ScrollBackground"
{
    Properties
    {
        _FarTex ("Far Layer (RGB)", 2D) = "white" {}
		_NearTex ("Near Layer (RGB)", 2D) = "white" {}
		_ScrollFar ("Far layer Scroll Speed", Float) = 1.0
		_ScrollNear ("Near layer Scroll Speed", Float) = 1.0
		_Multiplier ("Layer Multiplier", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        
		Pass{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _FarTex;
			sampler2D _NearTex;
			float4 _FarTex_ST;
			float4 _NearTex_ST;
			float _ScrollFar;
			float _ScrollNear;
			float _Multiplier;

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _FarTex_ST.xy + _FarTex_ST.zw + frac(float2(_ScrollFar, 0.0f) * _Time.y);
				o.uv.zw = v.texcoord.xy * _NearTex_ST.xy + _NearTex_ST.zw + frac(float2(_ScrollNear, 0.0f) * _Time.y);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 farLayer = tex2D(_FarTex, i.uv.xy);
				fixed4 nearLayer = tex2D(_NearTex, i.uv.zw);
				
				fixed4 c = lerp(farLayer, nearLayer, nearLayer.a);
				c.rgb *= _Multiplier;
				
				return c;
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
