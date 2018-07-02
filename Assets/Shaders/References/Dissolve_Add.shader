// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shader/Dissolve_Add" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	_DissolveColor("Dissolve Color", Color) = (0,0,0,1)
		_DissolveSrc("DissolveSrc", 2D) = "white" {}
	_Amount("Amount", Range(0, 1)) = 0.5

	}
		SubShader{
		Tags{
		"IgnoreProjector" = "True"
		"Queue" = "Transparent"
		"RenderType" = "Transparent"
	}
		Pass{
		Name "FORWARD"
		Tags{
		"LightMode" = "ForwardBase"
	}
		Blend One One
		Cull Off
		ZWrite Off

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#pragma multi_compile_fwdbase
#pragma exclude_renderers gles3 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
#pragma target 3.0
		sampler2D _MainTex;
	sampler2D _DissolveSrc;

	float  _Amount;
	float  _EdgeFactor;
	float4 _Color;
	fixed4 _DissolveColor;

	uniform float4 _MainTex_ST;

	struct v2f {
		half4 pos : SV_POSITION;
		half2 uv0 : TEXCOORD0;
		half4 color : TEXCOORD1;
	};

	struct VertexInput {
		float4 vertex : POSITION;
		float2 texcoord0 : TEXCOORD0;
		float4 vertexColor : COLOR;
	};
	v2f vert(VertexInput v) {
		v2f o = (v2f)0;
		o.uv0 = v.texcoord0;
		o.color = v.vertexColor;
		o.pos = UnityObjectToClipPos(v.vertex);
		return o;
	}


	fixed4 frag(v2f i) : COLOR
	{
		float4 _main_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
		float4 srcColor = _main_var * _Color * i.color;
		float factor = tex2D(_DissolveSrc, i.uv0).r - _Amount;
		
		float c = 0;
		if(factor>0)
			c=1;
		else
			c=0;
		float a = clamp(srcColor.a, 0, c);
		
		float b = a* srcColor.a;

		//clip(a);

		return fixed4(lerp(srcColor, _DissolveColor, 1 - b).rgb*10, b * 1);
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
		CustomEditor "ShaderForgeMaterialInspector"
}
