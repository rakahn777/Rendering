Shader "Custom/Transparent/Textured Colored"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Tags 
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		Pass 
		{
			// Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
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
				itp.position = UnityObjectToClipPos(vData.position);
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				return tex2D(_MainTex, itp.uv) * _Tint;
			}

			ENDCG
		}
	}
}
