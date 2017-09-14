Shader "Custom/LightingShader"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
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

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			struct VertexData
			{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			Interpolators VertexProgram(VertexData vData)
			{
				Interpolators itp;
				itp.position = mul(UNITY_MATRIX_MVP, vData.position);
				itp.uv = TRANSFORM_TEX(vData.uv, _MainTex);
				itp.normal = UnityObjectToWorldNormal(vData.normal);
				itp.normal = normalize(itp.normal);
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				itp.normal = normalize(itp.normal);
				return float4(itp.normal * 0.5 + 0.5, 1);
			}

			ENDCG
		}
	}
}
