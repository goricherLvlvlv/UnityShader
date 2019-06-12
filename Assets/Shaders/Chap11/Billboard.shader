// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chap11/Billboard"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _VerticalBillboarding ("Vertical Billboarding", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True" }

        Pass{
			Tags { "LightMode" = "ForwardBase" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VerticalBillboarding;

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				// 在模型空间下计算广告牌
				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

				float3 normalDir = viewer - center;
				// _VerticalBillboarding:1 => normalDir固定为viewDir;
				// _VerticalBillboarding:0 => upDir固定, 就是为(0, 1, 0);
				normalDir.y = normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);

				// 防止法线和upDir平行, 导致cross结果错误, 特加了个判断
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				// 确定了向右的方向
				float3 rightDir = normalize(cross(upDir, normalDir));
				// 确定了向上的方向, 之前的upDir只是为了求出rightDir的方向
				upDir = normalize(cross(normalDir, rightDir));

				// 根据原来的vertex的xyz的位置, 直接放在新的坐标系中
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				// 直接转到新的空间, 不能得到正确的结果
				// 因为转到新的空间, 点的实际位置没有改变, 只是获取这个点在这个空间下的坐标
				// 而该shader是要改变点的位置的, 所以采用上述的方式!!!!!
				//float3x3 objM = float3x3(rightDir, upDir, normalDir);
				//float3 localPos = mul(objM, v.vertex.xyz);

				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			}

			ENDCG
		}
    }
    FallBack "Transparent/VertexLit"
}
