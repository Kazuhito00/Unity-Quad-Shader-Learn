Shader "Unlit/10_blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
				half2 coordV : TEXCOORD0;
				half2 coordH : TEXCOORD1;
				float4 vertex : SV_POSITION;
				half2 offsetV: TEXCOORD2;
				half2 offsetH: TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			half4 _MainTex_TexelSize;
			static const float distance = 10.0;
			static const int samplingCount = 7;
			static const half weights[samplingCount] = { 0.036, 0.113, 0.216, 0.269, 0.216, 0.113, 0.036 };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				half2 uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.offsetV = _MainTex_TexelSize.xy * half2(0.0, 1.0) * distance;
				o.offsetH = _MainTex_TexelSize.xy * half2(1.0, 0.0) * distance;

				o.coordV = uv - o.offsetV * ((samplingCount - 1) * 0.5);
				o.coordH = uv - o.offsetH * ((samplingCount - 1) * 0.5);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				half4 col = 0;

				for (int count = 0; count < samplingCount; count++) {
					col += tex2D(_MainTex, i.coordV) * weights[count] * 0.5;
					col += tex2D(_MainTex, i.coordH) * weights[count] * 0.5;

					i.coordV += i.offsetV;
					i.coordH += i.offsetH;
				}

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
