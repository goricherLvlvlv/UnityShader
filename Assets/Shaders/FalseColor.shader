Shader "Custom/Chap6/FalseColor"
{
    SubShader
    {
        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f{
                float4 pos      :   SV_POSITION;
                fixed4 color    :   COLOR0;
            };

            v2f vert(appdata_full v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 可视化法线
                // o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化切线
                // o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 可视化副切线
                // fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                // o.color = fixed4(v.binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // 光照方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.color = fixed4(lightDir * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                // fixed3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));   // 法线方向
                // fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);              // 光照方向
                // o.color = dot(normalDir, lightDir);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return i.color;
            }

            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
