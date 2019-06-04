// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap10/Fresnel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
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
            fixed _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v{
                float4 vertex : POSITION;
                float4 normal : NORMAL;

            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldReflectDir : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                // view + reflect = 2 * normal * dot(normal, view)
                // 使用dot的原因: normal为单位向量, 而view的长度是未确定的.
                // 但是view + reflect的向量相加的方面与normal相同, 长度为2倍view在normal方向上的投影
                o.worldReflectDir = reflect(-o.worldViewDir, o.worldNormal);
                //o.worldReflectDir = 2 * dot(o.worldNormal, o.worldViewDir) * o.worldNormal - o.worldViewDir;
                TRANSFER_SHADOW(o);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));
                fixed3 reflection = texCUBE(_Cubemap, i.worldReflectDir).rgb;
				// Schlick菲涅尔近似等式
				// F(v, n) = F0 + (1 - F0) * (1 - dot(v, n))^5;
				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                return fixed4(ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten, 1.0);
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}
