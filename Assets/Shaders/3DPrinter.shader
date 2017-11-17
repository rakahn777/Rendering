Shader "Custom/3DPrinter" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ConstructY ("Construct Y", Range(0,1)) = 0.5
		_ConstructGap ("Construct Gap", Range(0,1)) = 0.5
		_ConstructColor ("Construct Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		
		CGPROGRAM
		#pragma surface surf Custom fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "UnityPBSLighting.cginc"

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _ConstructY;
		float _ConstructGap;
		fixed4 _ConstructColor;
		int building;
		float3 viewDir;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		inline half4 LightingCustom(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
		{
			if (building)
				return _ConstructColor;

			if (dot(s.Normal, viewDir) < 0)
				return _ConstructColor;
				
			return LightingStandard(s, lightDir, gi);
		}

		inline void LightingCustom_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			viewDir = IN.viewDir;

			float s = +sin((IN.worldPos.x * IN.worldPos.z) * 10 + _Time[3] + o.Normal) / 100;

			// Albedo comes from a texture tinted by color
			if (IN.worldPos.y > _ConstructY + s + _ConstructGap)
			{
				discard;
			}
			else if (IN.worldPos.y < _ConstructY)
			{
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;

				building = 0;
			}
			else
			{
				o.Albedo = _ConstructColor.rgb;
				o.Alpha = _ConstructColor.a;

				building = 1;
			}
			
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
