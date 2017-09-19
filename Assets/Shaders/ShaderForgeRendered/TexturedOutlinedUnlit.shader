Shader "Custom/TexturedOutlinedUnlit" {
    Properties {
        _Light ("Light", Color) = (0,0,0,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Outline ("Outline", Float ) = 0
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
        _OutlineTex ("Outline Texture", 2D) = "black" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
            }
            Cull Front
            ZWrite Off
            ZTest Always
            ColorMask RGB
            
            CGPROGRAM

            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _Outline;
            float4 _OutlineColor;
            sampler2D _OutlineTex;
            float4 _OutlineTex_ST;
            
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;                
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;                
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                // float3 normal = UnityObjectToWorldNormal(v.normal);
                // normal = normalize(normal);
                o.pos = mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz + v.normal*_Outline,1) );
                o.uv0 = v.texcoord0;                
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                // return tex2D(_OutlineTex,TRANSFORM_TEX(i.uv0, _OutlineTex));
                return fixed4(_OutlineColor.rgb,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM

            #pragma target 3.0            

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Light;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = _MainTex_var.rgb;
                float3 finalColor = emissive + _Light.rgb;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
