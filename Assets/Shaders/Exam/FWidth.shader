Shader "Exam/FWidth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform half4 _MainTex_ST;
            sampler2D _CameraDepthTexture;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

#if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_ST.y < 0) {
                    o.uv.y = 1 - o.uv.y;
                }
#endif

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
                fixed4 col = saturate( abs(ddx(depth))+ abs(ddy(depth)) );
                return col;
            }
            ENDCG
        }
    }
}
