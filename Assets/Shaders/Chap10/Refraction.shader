// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap10/Refraction"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RefractionColor ("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractionAmount ("Refraction Amount", Range(0, 1)) = 1
		_RefractionRatio ("Refraction Ratio", Range(0.1, 5)) = 0.5
        _Cubemap ("Refraction Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Pass{

            Tags { "LightMode" = "ForwardBase" }
			Cull Off
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            fixed4 _Color;
            fixed4 _RefractionColor;
            float _RefractionAmount;
            float _RefractionRatio;
            samplerCUBE _Cubemap;

            struct a2v{
                float4 vertex : POSITION;
                float4 normal : NORMAL;

            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldRefractDir : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				float3 worldNormalDir = normalize(o.worldNormal);

				// 入射角为i, 折射角为t
				// ni * sin(i) = nt * sin(t) => sin(t) = ni/nt * sin(i) => sin(t) = _RefractionRatio * sin(i)
				// cos(t) = sqrt(1 - sin(t)^2) 
				// refractDir 由 line1与line2相加获得, line1为-viewDir方向, line2为-normalDir方向
				/*
						*************  ==> topLine
						 **----------------------------------------------
						  *	*		*									|
						   *  *		*									|  => 这段长度为line1
						    *	*	*  ==> 角i, 入射角					|
							 *	  *--------------------------------------
							  *		*------------------------------------
							   *	*									|
							    *	*									|
								 *	*									|  => 这段长度为line2
								  *	*  ==> 角t, 折射角					|
								   **									|
								    *  ==> -viewDir, 长度为1-------------
						
						topLine.length = sin(t) * 1;
						line1.length = topLine.length / sin(i) => sin(t)/sin(i) => _RefractionRatio

						line2.length = cos(t) - topLine.length / tan(i)
									 = cos(t) - sin(t) / sin(i) * cos(i)
									 = cos(t) - _RefractionRatio * cos(i)
				*/
				float CosI = dot(worldViewDir, worldNormalDir);
				float SinI_2 = 1.0f - CosI * CosI;
				float CosT_2 = 1.0f - _RefractionRatio * _RefractionRatio * SinI_2;
				float3 line1 = _RefractionRatio * -worldViewDir;
				float3 line2 = (sqrt(abs(CosT_2)) - _RefractionRatio * CosI) * -worldNormalDir;
				
				o.worldRefractDir = (line1 + line2) * (float3)(CosT_2 > 0);


				//o.worldRefractDir = refract(-worldViewDir, normalize(o.worldNormal), _RefractionRatio);
                TRANSFER_SHADOW(o);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
                fixed3 refraction = texCUBE(_Cubemap, i.worldRefractDir).rgb * _RefractionColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                return fixed4(ambient + lerp(diffuse, refraction, _RefractionAmount) * atten, 1.0);
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}
