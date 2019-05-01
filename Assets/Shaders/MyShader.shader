// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader"
{
	Properties{
		_Color ("Color", Color) = (1, 0, 0, 1)
	}

    SubShader
    {
		
		Pass{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			float4 vert(float4 v : POSITION) : SV_POSITION{
				return UnityObjectToClipPos(v);
			}

			float4 frag() : SV_TARGET{
				return fixed4(1.0, 1.0, 1.0, 1.0);
			}

			ENDCG
		}
		
		
    }
    FallBack "Diffuse"
}
