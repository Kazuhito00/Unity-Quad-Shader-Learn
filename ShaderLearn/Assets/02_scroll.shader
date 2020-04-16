Shader "Unlit/02_scroll"
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// _Timeでステージのロードからの経過時間を取得可能
				// _Time[0]は1 / 20、_Time[1]は1、_Time[2]は2、_Time[3]は3倍
				// float4型のため0はx、1はy、2はz、3はwに対応し、_Time.x、_Time.y、_Time.z、_Time.wでも指定可能
				float2 uv = i.uv;
				uv.x += frac(_Time[0]);
				// uv.x += frac(_SinTime[3]);

                fixed4 col = tex2D(_MainTex, uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
