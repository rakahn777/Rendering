﻿Shader "Custom/MultiLight"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		// [NoScaleOffset] _HeightMap ("Height", 2D) = "gray" {}
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0		
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Pass 
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma target 3.0

			// #pragma multi_compile _ VERTEXLIGHT_ON

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "PBLighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			// #pragma multi_compile DIRECTION DIRECTIONAL_COOKIE POINT SPOT
			#pragma multi_compile_fwdadd

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "PBLighting.cginc"

			ENDCG
		}
	}
}
