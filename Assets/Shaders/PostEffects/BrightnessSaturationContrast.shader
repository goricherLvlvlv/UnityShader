// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffects/BrightnessSaturationContrast"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1
		_Saturation ("Saturation", Float) = 1
		_Contrast ("Contrast", Float) = 1
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
			half _Brightness;
			half _Saturation;
			half _Contrast;

			struct v2f{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata_img v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				return o;
			}

			float4 frag(v2f i) : SV_TARGET{
				fixed4 renderTex = tex2D(_MainTex, i.uv);

				// Brightness
				fixed3 color = renderTex.rgb * _Brightness;

				// Saturation
				// 我们常见的图片, 降低其饱和度时, 不同的颜色的灰度会不相同
				// 让r, g, b占用不同的权重, 制造一个饱和度为0时的颜色luminanceColor
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				color = lerp(luminanceColor, color, _Saturation);

				// Contrast
				// 增强明暗关系对比
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				color = lerp(avgColor, color, _Contrast);

				return fixed4(color, renderTex.a);
			}

			ENDCG
		}
    }
    FallBack Off
}
