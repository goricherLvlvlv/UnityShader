Shader "Exam/LiquidBottle"
{
    Properties
    {
        _Color ("液体颜色", Color) = (1, 1, 1, 1)
        _FloatColor("浮沫颜色", Color) = (1, 1, 1, 1)
        _TopColor("顶部颜色", Color) = (1, 1, 1, 1)
        _FillAmount("填充度", Range(-1, 2)) = 0
        _FloatEdge("浮沫高度", Float) = 0.05
        _BottleWidth("瓶子厚度", Float) = 0.1

        [HideInInspector]_Height("高度", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        // liquid
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite On
            ZTest LEqual

            //AlphaToMask On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 edge : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float4 _Color;
            float4 _FloatColor;
            float4 _TopColor;
            float _FloatEdge;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float, _FillAmount)
                UNITY_DEFINE_INSTANCED_PROP(float, _Height)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.edge.x = _Time.y;
                o.edge.y = mul(unity_ObjectToWorld, v.vertex).y + UNITY_ACCESS_INSTANCED_PROP(Props, _FillAmount) - UNITY_ACCESS_INSTANCED_PROP(Props, _Height);
                o.edge.y += sin((_Time.y + v.vertex.x) * 4) / 6;
                o.edge.z = _Time.y;
                return o;
            }

            fixed4 frag(v2f i, fixed facing : VFace) : SV_Target
            {
                float edge = step(i.edge.y, 0.5); // 水体部分
                float edge2 = step(i.edge.y, 0.5 + _FloatEdge) * (1 - edge); // 浮沫部分

                float4 liquidCol = float4(edge, edge, edge, edge) * _Color;
                float4 floatCol = float4(edge2, edge2, edge2, edge2) * _FloatColor;
                
                float4 finalCol = facing >= 0 ? (liquidCol + floatCol) : ((edge + edge2) * _TopColor);

                clip(finalCol.a - 0.01);

                return finalCol;
            }
            ENDCG
        }

        // bottle
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            float _BottleWidth;

            v2f vert(appdata v)
            {
                v2f o;
                v.vertex.xyz = v.vertex.xyz + v.normal.xyz * _BottleWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.normalDir = v.normal.xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float col = 1 - dot(i.viewDir, i.normalDir);
                col = step(0.7, col) * col + (1 - step(0.7, col)) * 0.1;
                return float4(1, 1, 1, col);
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
