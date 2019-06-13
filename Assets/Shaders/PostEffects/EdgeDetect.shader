Shader "Custom/PostEffects/EdgeDetect"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
		Pass{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM

			#include "UnityCG.cginc"
			
			#pragma vertex vert  
			#pragma fragment frag

			sampler2D _MainTex;  
			uniform half4 _MainTex_TexelSize;
			fixed _EdgeOnly;
			fixed4 _EdgeColor;
			fixed4 _BackgroundColor;
			
			


			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv[9] : TEXCOORD0;
			};

			v2f vert(appdata_img v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				half2 uv = v.texcoord;

				/*
					[0]	-1, 1	[1] 0, 1	[2] 1, 1
					[3]	-1, 0	[4]	0, 0	[5] 1, 0
					[6]	-1, -1	[7]	0, -1	[8] 1, -1
				*/

				o.uv[0] = uv +_MainTex_TexelSize.xy * half2(-1, 1);
				o.uv[1] = uv +_MainTex_TexelSize.xy * half2(0, 1);
				o.uv[2] = uv +_MainTex_TexelSize.xy * half2(1, 1);
				o.uv[3] = uv +_MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[4] = uv +_MainTex_TexelSize.xy * half2(0, 0);
				o.uv[5] = uv +_MainTex_TexelSize.xy * half2(1, 0);
				o.uv[6] = uv +_MainTex_TexelSize.xy * half2(-1, -1);
				o.uv[7] = uv +_MainTex_TexelSize.xy * half2(0, -1);
				o.uv[8] = uv +_MainTex_TexelSize.xy * half2(1, -1);

				return o;
			}

			fixed luminance(fixed4 color) {
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
			}

			half sobel(v2f i){

				const half Gx[9] = {1, 0, -1,
									2, 0, -2,
									1, 0, -1 };

				const half Gy[9] = {1, 2, 1,
									0, 0, 0,
									-1, -2, -1 };

				half texColor;
				half edgeX = 0;
				half edgeY = 0;

				//for(int it = 0; it < 9; ++it){
				//	texColor = luminance(tex2D(_MainTex, i.uv[it]));
				//	edgeX += texColor * Gx[it];		// 颜色和对应卷积核相乘
				//	edgeY += texColor * Gy[it];
				//}

				texColor = luminance(tex2D(_MainTex, i.uv[0]));
				edgeX += texColor * Gx[0];
				edgeY += texColor * Gy[0];

				texColor = luminance(tex2D(_MainTex, i.uv[1]));
				edgeX += texColor * Gx[1];
				edgeY += texColor * Gy[1];

				texColor = luminance(tex2D(_MainTex, i.uv[2]));
				edgeX += texColor * Gx[2];
				edgeY += texColor * Gy[2];

				texColor = luminance(tex2D(_MainTex, i.uv[3]));
				edgeX += texColor * Gx[3];
				edgeY += texColor * Gy[3];

				texColor = luminance(tex2D(_MainTex, i.uv[4]));
				edgeX += texColor * Gx[4];
				edgeY += texColor * Gy[4];

				texColor = luminance(tex2D(_MainTex, i.uv[5]));
				edgeX += texColor * Gx[5];
				edgeY += texColor * Gy[5];

				texColor = luminance(tex2D(_MainTex, i.uv[6]));
				edgeX += texColor * Gx[6];
				edgeY += texColor * Gy[6];

				texColor = luminance(tex2D(_MainTex, i.uv[7]));
				edgeX += texColor * Gx[7];
				edgeY += texColor * Gy[7];

				texColor = luminance(tex2D(_MainTex, i.uv[8]));
				edgeX += texColor * Gx[8];
				edgeY += texColor * Gy[8];

				// 边缘处|X| + |Y|接近于1
				//return 1 - abs(edgeX) - abs(edgeY);

				// 水平方向
				//return abs(edgeX);
				
				// 垂直方向
				//return abs(edgeY);

				// 水平+垂直方向, 只保留边缘
				return abs(edgeX) + abs(edgeY);
			}

			float4 frag(v2f i) : SV_TARGET{
				half edge = sobel(i);
				// 在边缘区域edge趋近于0
				// 于是颜色无限接近_EdgeColor
				// 不管是使用withEdgeColor还是onlyEdgeColor, 边缘处的颜色都是_EdgeColor

				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

				// _EdgeOnly的值越大, 非edge的颜色就会靠近onlyEdgeColor
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
			}

			

			ENDCG
		}
        
    }
    FallBack Off
}
