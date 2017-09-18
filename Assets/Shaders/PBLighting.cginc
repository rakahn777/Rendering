#if !defined(FIRST_LIGHTING_INCLUDED)
#define FIRST_LIGHTING_INCLUDED

#include "AutoLight.cginc"
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

UnityLight CreateLight(Interpolators i)
{
	UnityLight light;

	#if defined(POINT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);

	return light;
}

float4 FragmentProgram(Interpolators itp) : SV_TARGET
{
	float3 viewDir = normalize(_WorldSpaceCameraPos - itp.worldPos);

	float3 albedo = tex2D(_MainTex, itp.uv).rgb * _Tint.rgb;
	
	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	return UNITY_BRDF_PBS(albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		itp.normal, viewDir,
		CreateLight(itp), indirectLight);
}

#endif
