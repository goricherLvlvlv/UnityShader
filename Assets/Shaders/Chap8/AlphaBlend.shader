Shader "Custom/Chap8/AlphaBlend"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white"{}
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
		// Queue控制渲染顺序, Transparent => 3000, 若在外部填写为1000时, 会覆盖后面非透明的地面
		// IgnoreProjector为Ture, 让物体不会收到投影器的影响
		// RenderType对着色器进行分类
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Cull Off
		// 该Pass只用于输出深度值, 不会把颜色写入Color Buffer中
		// 实现效果: 模型自身不同部位会被遮挡, 即不会自己与自己混合
		Pass{
			ZWrite On
			ColorMask 0
		}

		Pass{
			Tags { "LightMode" = "ForwardBase" }	
			ZWrite Off
			// 格式: Blend SrcFactor DstFactor
			// DstColor = SrcAlpha * SrcColor + (1 - SrcAlpha) * DstColor
			// 原颜色是该片元产生的颜色, 目标颜色是原本储存在缓冲区的颜色
			Blend SrcAlpha OneMinusSrcAlpha

			// 柔和相加
			//Blend OneMinusDstColor One

			// 正片叠底
			//Blend DstColor Zero
			// 两倍正片叠底
			//Blend DstColor SrcColor
			

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormalDir = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldNormalDir, worldLightDir));

				// 贴图的透明度 与 属性中的_AlphaScale 相乘
				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}

			ENDCG
		}

    }
	FallBack "Transparent/Cutout/VertexLit"
}
