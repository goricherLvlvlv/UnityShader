Shader "Custom/Chap14/Cartoon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader
    {
		Pass{
			Name "OUTLINE"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float _Outline;
			float4 _OutlineColor;

			struct a2v{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v){
				v2f o;

				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				normal.z = -0.5;	// view space下, 当normal.z小于0时, 方向指向屏幕里
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				return o;
			}

			float4 frag(v2f i) : SV_TARGET{
				return float4(_OutlineColor.rgb, 1);
			}
			ENDCG
		}

		//Pass{
		//	Tags {"LightMode" = "ForwardBase"}
		//	Cull Back
		//	CGPROGRAM

		//	#pragma vertex vert
		//	#pragma fragment frag
		//	#pragma multi_compile_fwdbase


		//	ENDCG
		//}
    }
    FallBack "Diffuse"
}
