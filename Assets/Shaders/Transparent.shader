Shader "Custom/ShowBehind"
{
	SubShader
	{
		Pass
		{
			Material
			{
				Diffuse(1, 1, 1, 1)
			}

			Lighting On
			Cull Front
		}
	}
}
