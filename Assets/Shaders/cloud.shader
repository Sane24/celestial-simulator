Shader "Unlit/ProceduralClouds"
{
    Properties
    {
        _CloudColor ("Cloud Color", Color) = (1, 1, 1, 1)
        _BackgroundColor ("Background Color", Color) = (0.1, 0.1, 0.2, 0)
        _NoiseScale ("Noise Scale", Float) = 2.5
        _ScrollSpeed ("Scroll Speed", Float) = 0.05
        _Sharpness ("Edge Sharpness", Float) = 5.0
        _Density ("Cloud Density", Float) = 0.5
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _CloudColor;
            float4 _BackgroundColor;
            float _NoiseScale;
            float _ScrollSpeed;
            float _Sharpness;
            float _Density;

            // 2D pseudo-random value noise
            float rand(float2 co)
            {
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = rand(i);
                float b = rand(i + float2(1, 0));
                float c = rand(i + float2(0, 1));
                float d = rand(i + float2(1, 1));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Scroll UVs over time for motion
                float2 uv = i.uv;
                uv.x += _Time.y * _ScrollSpeed;
                uv.y += _Time.y * (_ScrollSpeed * 0.5); // diagonal scroll

                float n = noise(uv * _NoiseScale);

                // Sharpness + threshold = cloud mask
                float mask = smoothstep(_Density, _Density + 0.1, n);
                mask = pow(mask, _Sharpness); // sharper edges

                float4 col = lerp(_BackgroundColor, _CloudColor, mask);
                col.a = mask;

                return col;
            }
            ENDCG
        }
    }
}
