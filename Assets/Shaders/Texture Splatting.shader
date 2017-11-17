// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Texture Splatting"
{
	Properties
	{
		_MainTex ("Splat Map", 2D) = "white" {}
		[NoScaleOffset] _Texture1 ("Texture 1", 2D) = "white" {}
		[NoScaleOffset] _Texture2 ("Texture 2", 2D) = "white" {}
		[NoScaleOffset] _Texture3 ("Texture 3", 2D) = "white" {}
		[NoScaleOffset] _Texture4 ("Texture 4", 2D) = "white" {}
	}

	SubShader
	{
		Pass {
			CGPROGRAM

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Texture1, _Texture2, _Texture3, _Texture4;

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
			};

			struct VertexData
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators VertexProgram(VertexData vData)
			{
				Interpolators itp;
				itp.position = UnityObjectToClipPos(vData.position);
				itp.uv = TRANSFORM_TEX(vData.uv, _MainTex);
				itp.uvSplat = vData.uv;
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				float4 splat = tex2D(_MainTex, itp.uvSplat);
				float4 color = 
					tex2D(_Texture1, itp.uv) * splat.r + 
					tex2D(_Texture2, itp.uv) * splat.g + 
					tex2D(_Texture3, itp.uv) * splat.b + 
					tex2D(_Texture4, itp.uv) * (1 - splat.r - splat.g - splat.b);
				return color;
			}

			ENDCG
		}
	}
}
