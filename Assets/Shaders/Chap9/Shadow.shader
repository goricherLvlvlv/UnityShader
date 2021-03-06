﻿Shader "Custom/Chap9/Shadow"
{
    Properties{
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}

    SubShader
    {
        Tags { "RenderType"="Opaque" }

		Pass{
            Tags{ "LightMode" = "ForwardBase" }
			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			fixed4 _Diffuse;
			fixed4 _Specular;
			fixed _Gloss;
			
			// application to view
			struct a2v{
				// 读取POSITION语义的数据
				float4 vertex : POSITION;
				// 读取法线数据
				float3 normal : NORMAL;
			};

			struct v2f{
				// 告知Unity, pos为裁剪空间的坐标
				float4 pos : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float3 worldPos : TEXCOORD1;

				// 让物体接受阴影, 如下所示:
				// unityShadowCoord4 _ShadowCoord : TEXCOORD2;
				// 这是Screen Space下的shadow, 通过宏定义来区分类型
				// 还有Spot Light, Point Light, Shadow off的版本
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v){
				v2f f;

                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

                // 提供法线信息
				f.normalDir = UnityObjectToWorldNormal(v.normal);

				// 提供物体坐标
				f.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				// 发送shadow坐标系给fragment shader
				
				// Screen Space Shadow
				// 本地坐标转为世界坐标再转为阴影坐标
				// f._ShadowCoord = mul(unity_WorldToShaow[0], mul(unity_ObjectToWorld, v.vertex));
				
				// UNITY_NO_SCREENSPACE_SHADOWS
				// f._ShadowCoord = ComputeScreenPos(f.pos); 
				TRANSFER_SHADOW(f);

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 worldNormal = normalize(i.normalDir);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				
                // 高光反射(镜面反射) C_light * M_specular * max(0, normal•half)^Gloss
				fixed3 halfDir = normalize(lightDir + viewDir);
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed atten = 1;

				// unitySampleShadow(i._ShadowCoord)
				// 情况比较复杂, 暂时不考虑实现原理(也记不住)
				fixed shadow = SHADOW_ATTENUATION(i);

				return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
			}

			ENDCG
		}

        Pass{
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM
            #include "UnityCG.cginc"
			#include "Lighting.cginc"
            #include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
            #pragma multi_compile_fwdadd

            // 需要获取与Properties中同名变量
            fixed4 _Diffuse;
			fixed4 _Specular;
			fixed _Gloss;

			// application to view
			struct a2v{
				// 读取POSITION语义的数据
				float4 vertex : POSITION;
				// 读取法线数据
				float3 normal : NORMAL;
			};

			struct v2f{
				// 告知Unity, pos为裁剪空间的坐标
				float4 pos : SV_POSITION;

				float3 normalDir : TEXCOORD0;

				float3 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v){
				v2f f;

                // 将裁剪控件的坐标赋予SV_POSITION
                f.pos = UnityObjectToClipPos(v.vertex);

                // 提供法线信息
				f.normalDir = UnityObjectToWorldNormal(v.normal);

				// 提供物体坐标
				f.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return f;
			}

			fixed4 frag(v2f i) : SV_TARGET{

                #ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #else
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #endif

                // 点光源和聚光灯的强度是会随着距离衰减的
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    #if defined (POINT) 
                        // 把点坐标转换到点光源的坐标空间中，_LightMatrix0由引擎代码计算后传递到shader中，这里包含了对点光源范围的计算，具体可参考Unity引擎源码。经过_LightMatrix0变换后，在点光源中心处lightCoord为(0, 0, 0)，在点光源的范围边缘处lightCoord模为1
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                        
                        // 使用点到光源中心距离的平方dot(lightCoord, lightCoord)构成二维采样坐标，对衰减纹理_LightTexture0采样。_LightTexture0纹理具体长什么样可以看后面的内容
                        // UNITY_ATTEN_CHANNEL是衰减值所在的纹理通道，可以在内置的HLSLSupport.cginc文件中查看。一般PC和主机平台的话UNITY_ATTEN_CHANNEL是r通道，移动平台的话是a通道
                        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined (SPOT)
                        // 把点坐标转换到聚光灯的坐标空间中，_LightMatrix0由引擎代码计算后传递到shader中，这里面包含了对聚光灯的范围、角度的计算，具体可参考Unity引擎源码。经过_LightMatrix0变换后，在聚光灯光源中心处或聚光灯范围外的lightCoord为(0, 0, 0)，在点光源的范围边缘处lightCoord模为1
						float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));

                        // 与点光源不同，由于聚光灯有更多的角度等要求，因此为了得到衰减值，除了需要对衰减纹理采样外，还需要对聚光灯的范围、张角和方向进行判断
                        // 此时衰减纹理存储到了_LightTextureB0中，这张纹理和点光源中的_LightTexture0是等价的
                        // 聚光灯的_LightTexture0存储的不再是基于距离的衰减纹理，而是一张基于张角范围的衰减纹理
                        
						// UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord)
						fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #else
                        fixed atten = 1.0;
                    #endif
                #endif

                fixed3 worldNormal = normalize(i.normalDir);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				
                // 高光反射(镜面反射) C_light * M_specular * max(0, normal•half)^Gloss
				fixed3 halfDir = normalize(lightDir + viewDir);
				
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				return fixed4((diffuse + specular) * atten, 1.0);
			}

            ENDCG

        }

		// 投射阴影的Pass
		Pass{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			struct v2f{
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v){
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_TARGET{
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}

    }

	FallBack "Specular"

}
