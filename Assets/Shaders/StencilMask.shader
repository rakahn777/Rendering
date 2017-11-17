﻿Shader "Custom/StencilMask"
{
	Properties
	{
		_StencilMask ("Stencil Mask", Int) = 0
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
			"Queue" = "Geometry-100"
		}

		ColorMask 0
		ZWrite Off
		Stencil
		{
			Ref[_StencilMask]
			Comp always
			Pass replace
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(1, 1, 0, 1);
				return col;
			}
			ENDCG
		}
	}
}
