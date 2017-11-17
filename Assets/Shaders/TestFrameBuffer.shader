// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TestFrameBuffer"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			// #pragma only_renderers framebufferfetch

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : TEXCOORD0;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color.rg = v.texcoord*4.0;
				o.color.ba = 0;
				return o;
			}

			void frag (v2f i, inout fixed4 ocol : SV_Target)
			{
				i.color = frac(i.color);
				ocol.rg = i.color.rg;
				ocol.b *= 1.5;
			}
			ENDCG
		}
	}
}
