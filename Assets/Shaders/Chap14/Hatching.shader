// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap14/Hatching"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_Outline ("Outline", Range(0, 1)) = 0.1
        _Hatch0 ("Hatch Tex 0", 2D) = "white" {}
        _Hatch1 ("Hatch Tex 1", 2D) = "white" {}
        _Hatch2 ("Hatch Tex 2", 2D) = "white" {}
        _Hatch3 ("Hatch Tex 3", 2D) = "white" {}
        _Hatch4 ("Hatch Tex 4", 2D) = "white" {}
        _Hatch5 ("Hatch Tex 5", 2D) = "white" {}
        _TileFactor ("Tile Factor", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        UsePass "Custom/Chap14/Cartoon/OUTLINE"
        
        Pass{
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;
            float _TileFactor;
            float4 _Color;

            struct a2v{
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 hatchWeight0 : TEXCOORD1;
                fixed3 hatchWeight1 : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _TileFactor;

                fixed3 lightDir = normalize(WorldSpaceLightDir(v.vertex));
                fixed3 normalDir = UnityObjectToWorldNormal(v.normal);
                fixed diff = saturate(dot(lightDir, normalDir));

                o.hatchWeight0 = fixed3(0, 0, 0);
                o.hatchWeight1 = fixed3(0, 0, 0);
                // 将反射的强度分为七档, 分别使用不同的hatch tex
                float hatchFactor = diff * 7.0;

                /*
                    [6.0, 7.0]  纯白
                    [5.0, 6.0]  纯白 0.x
                    [4.0, 5.0]  0.x 0.y
                    [3.0, 4.0]  0.y 0.z
                    [2.0, 3.0]  0.z 1.x
                    [1.0, 2.0]  1.x 1.y
                    [0.0, 1.0]  1.y 1.z
                */
                if(hatchFactor > 6.0){}
                else if(hatchFactor > 5.0){ o.hatchWeight0.x = 6.0 - hatchFactor; }
                else if(hatchFactor > 4.0){ o.hatchWeight0.x = hatchFactor - 4.0; o.hatchWeight0.y = 1.0 - o.hatchWeight0.x; }
                else if(hatchFactor > 3.0){ o.hatchWeight0.y = hatchFactor - 3.0; o.hatchWeight0.z = 1.0 - o.hatchWeight0.y; }
                else if(hatchFactor > 2.0){ o.hatchWeight0.z = hatchFactor - 2.0; o.hatchWeight1.x = 1.0 - o.hatchWeight0.z; }
                else if(hatchFactor > 1.0){ o.hatchWeight1.x = hatchFactor - 1.0; o.hatchWeight1.y = 1.0 - o.hatchWeight1.x; }
                else{ o.hatchWeight1.y = hatchFactor; o.hatchWeight1.z = 1.0 - o.hatchWeight1.y; }

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                fixed4 t0 = tex2D(_Hatch0, i.uv) * i.hatchWeight0.x;
                fixed4 t1 = tex2D(_Hatch1, i.uv) * i.hatchWeight0.y;
                fixed4 t2 = tex2D(_Hatch2, i.uv) * i.hatchWeight0.z;
                fixed4 t3 = tex2D(_Hatch3, i.uv) * i.hatchWeight1.x;
                fixed4 t4 = tex2D(_Hatch4, i.uv) * i.hatchWeight1.y;
                fixed4 t5 = tex2D(_Hatch5, i.uv) * i.hatchWeight1.z;
                fixed4 white = fixed4(1,1,1,1) * (1 - i.hatchWeight0.x - i.hatchWeight0.y - i.hatchWeight0.z - i.hatchWeight1.x - i.hatchWeight1.y - i.hatchWeight1.z);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 hatchColor = (t0 + t1 + t2 + t3 + t4 + t5 + white).rgb * atten * _Color.rgb;
                return fixed4(hatchColor, 1.0);
            }

            ENDCG

        }
    }
    FallBack "Diffuse"
}
