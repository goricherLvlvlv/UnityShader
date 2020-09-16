Shader "Custom/Common/Normal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Speed("Speed", Float) = 5
        _BumpMap("Normal Map", 2D) = "bump"{}			
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Cull off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = float2(o.uv.x + _Time.y * 1.2, o.uv.y);
                o.uv = float2(o.uv.x + _Time.y / 2, o.uv.y);
                //o.vertex.y = o.vertex.y + saturate(fmod(floor(o.uv.x * 10), 2));
                o.vertex.y = o.vertex.y + sin(o.uv.x * _Speed);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv2));
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                fixed n = dot(tangentNormal, _Color);
                return col * fixed4(_Color.r + n/3, _Color.gba);
            }
            ENDCG
        }
    }
}
