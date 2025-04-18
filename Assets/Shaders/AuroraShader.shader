Shader "Unlit/AuroraShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.2, 1, 0.5, 1)
        _SecondaryColor ("Secondary Color", Color) = (0.0, 0.6, 1, 1)
        _Speed ("Scroll Speed", Float) = 0.5
        _Scale ("Noise Scale", Float) = 5.0
        _Intensity ("Glow Intensity", Float) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;
            float4 _SecondaryColor;
            float _Speed;
            float _Scale;
            float _Intensity;

            // simple pseudo-random noise function
            float rand(float2 co) {
                return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

            // 2D value noise
            float noise(float2 p) {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = rand(i);
                float b = rand(i + float2(1.0, 0.0));
                float c = rand(i + float2(0.0, 1.0));
                float d = rand(i + float2(1.0, 1.0));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // scroll noise vertically
                float2 uv = i.uv * _Scale;
                uv.y += _Time.y * _Speed;

                float n = noise(uv);

                // fade in and out vertically
                float verticalFade = smoothstep(0.2, 0.8, i.uv.y);

                float brightness = smoothstep(0.3, 1.0, n) * verticalFade;

                float4 col = lerp(_MainColor, _SecondaryColor, n);
                col.a = brightness * _Intensity;

                return col;
            }
            ENDCG
        }
    }
}
