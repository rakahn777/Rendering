Shader "Custom/PBLShader"
{
	Properties
	{
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0		
		// _SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Pass {
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma target 3.0

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityPBSLighting.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			// float4 _SpecularTint;
			float _Metallic;
			float _Smoothness;

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				itp.position = UnityObjectToClipPos(vData.position);
				itp.worldPos = mul(unity_ObjectToWorld, vData.position);
				itp.uv = TRANSFORM_TEX(vData.uv, _MainTex);
				itp.normal = UnityObjectToWorldNormal(vData.normal);
				itp.normal = normalize(itp.normal);				
				return itp;
			}

			float4 FragmentProgram(Interpolators itp) : SV_TARGET
			{
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - itp.worldPos);
				float3 halfVector = normalize(lightDir + viewDir);

				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex, itp.uv).rgb * _Tint.rgb;
				
				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);

				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(itp.normal, lightDir);

				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					itp.normal, viewDir,
					light, indirectLight);
			}

			ENDCG
		}
	}
}
