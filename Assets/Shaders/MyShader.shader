// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader"
{
	Properties{
		_Color ("Color", Color) = (1, 0, 0, 1)
	}

    SubShader
    {
		
		Pass{
			Material{
				Diffuse [_Color]
				Ambient [_Color]
				Specular [_Color]
			}
			Lighting On
		}
		
		
    }
    FallBack "Diffuse"
}
