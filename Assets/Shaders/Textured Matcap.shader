﻿Shader "Custom/Textured Matcap"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Matcap ("Matcap", 2D) = "white" {}
	}

	SubShader
	{
		Pass {
			CGPROGRAM

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Matcap;

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexData
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators VertexProgram(VertexData vData)
			{
				Interpolators itp;
				itp.uv = TRANSFORM_TEX(vData.uv, _MainTex);
				itp.position = mul(UNITY_MATRIX_MVP, vData.position);
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				return tex2D(_MainTex, itp.uv) * tex2D(_Matcap, itp.uv);
			}

			ENDCG
		}
	}
}
