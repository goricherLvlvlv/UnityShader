// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap10/Glass"
{
    Properties
    {
		_MainTex ("Main Tex", 2D) = "white"{}
		_BumpMap ("Normal Map", 2D) = "bump"{}
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox"{}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractionAmount ("Refraction Amount", Range(0, 1)) = 1
    }
    SubShader
    {
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }
		GrabPass { "_RefractionTex" }

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

            sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;					// 控制扭曲程度
			fixed _RefractionAmount;
			sampler2D _RefractionTex;			// 对应GrabPass中的字符串
			float4 _RefractionTex_TexelSize;

            struct a2v{
                float4 vertex : POSITION;
                float4 normal : NORMAL;
				float4 tangent : TANGENT; 
				float2 texcoord: TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				// 将clip space下的坐标转到viewport pos
				// NDC坐标是 clip(x,y,z)/clip(w)
				// viewport坐标是 0.5 * (clip(x,y)/clip(w) + 1)
				// 这里并未除以w分量, 为了避免破坏插值的结果
				o.scrPos = ComputeGrabScreenPos(o.pos);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            float4 frag(v2f i) : SV_TARGET{
				// 获取在tangent space下的normal map值
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				// 对该normal map值进行偏移, _RefractionTex_TexelSize描述纹素的大小
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset + i.scrPos.xy;
				fixed3 refractionColor = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
			
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				// 反射部分计算
				fixed3 reflectionDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflectionColor = texCUBE(_Cubemap, reflectionDir).rgb * texColor.rgb;
				
				fixed3 finalColor = reflectionColor * (1 - _RefractionAmount) + refractionColor * _RefractionAmount;

				return fixed4(finalColor, 1.0);
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}
