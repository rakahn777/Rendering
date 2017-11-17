// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Textured With Detail	"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_DetailTex ("Detail Texture", 2D) = "gray" {}
	}

	SubShader
	{
		Pass {
			CGPROGRAM

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
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
				itp.uvDetail = TRANSFORM_TEX(vData.uv, _DetailTex);
				itp.position = UnityObjectToClipPos(vData.position);
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				float4 color = tex2D(_MainTex, itp.uv) * _Tint;
				color *= tex2D(_DetailTex, itp.uvDetail) * unity_ColorSpaceDouble;
				return color;
			}

			ENDCG
		}
	}
}
