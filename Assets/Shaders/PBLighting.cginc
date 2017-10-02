#if !defined(FIRST_LIGHTING_INCLUDED)
#define FIRST_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;
// sampler2D _HeightMap;
// float4 _HeightMap_TexelSize;
sampler2D _NormalMap;
float _Metallic;
float _Smoothness;

struct Interpolators
{
	float4 position : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
	
	#if defined(VERTEXLIGHT_ON)
	float3 vertexLightColor: TEXCOORD3;
	#endif
};

struct VertexData
{
	float4 position : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

void ComputeVertexLightColor(inout Interpolators i)
{
	#if defined(VERTEXLIGHT_ON)
	
	i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	// float3 lightPos = float3(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x);
	// float3 lightVec = lightPos - i.worldPos;
	// float3 lightDir = normalize(lightVec);
	// float ndotl = DotClamped(i.normal, lightDir);
	// float attenuation = 1 / (1 + dot(lightDir, lightDir) * unity_4LightAtten0.x);

	// i.vertexLightColor = unity_LightColor[0].rgb * ndotl * attenuation;
	#endif
}

Interpolators VertexProgram(VertexData vData)
{
	Interpolators i;
	i.position = UnityObjectToClipPos(vData.position);
	i.worldPos = mul(unity_ObjectToWorld, vData.position);
	i.uv = TRANSFORM_TEX(vData.uv, _MainTex);
	i.normal = UnityObjectToWorldNormal(vData.normal);
	// i.normal = normalize(i.normal);	

	ComputeVertexLightColor(i);

	return i;
}

void InitializeFragmentNormal(inout Interpolators i)
{
	/*
	float2 du = float2(_HeightMap_TexelSize.x * 0.5, 0);
	float u1 = tex2D(_HeightMap, i.uv - du);
	float u2 = tex2D(_HeightMap, i.uv + du);
	// float3 tu = float3(1, u2 - u1, 0);

	float2 dv = float2(0, _HeightMap_TexelSize.y * 0.5);
	float v1 = tex2D(_HeightMap, i.uv - du);
	float v2 = tex2D(_HeightMap, i.uv + du);
	// float3 tv = float3(0, v2 - v1, 1);

	// i.normal = cross(tv, tu);
	i.normal = float3(u1 - u2, 1, v1 - v2);
	*/
	i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
	i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
	i.normal = i.normal.xzy;

	i.normal = normalize(i.normal);
}

UnityLight CreateLight(Interpolators i)
{
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);

	return light;
}

UnityIndirect CreateIndirectLight(Interpolators i)
{
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
	indirectLight.diffuse = i.vertexLightColor;
	#endif

	return indirectLight;
}

float4 FragmentProgram(Interpolators i) : SV_TARGET
{
	InitializeFragmentNormal(i);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
	
	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	return UNITY_BRDF_PBS(albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), CreateIndirectLight(i));
}

#endif
