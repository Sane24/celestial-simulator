Shader "Unlit/AuroraShaderAdvanced"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.2, 1, 0.5, 1)
        _SecondaryColor ("Secondary Color", Color) = (0.0, 0.6, 1, 1)
        _Speed ("Scroll Speed", Float) = 0.5
        _Scale ("Noise Scale", Float) = 5.0
        _Intensity ("Glow Intensity", Float) = 1.5
        _WaveStrength ("Wave Distortion", Float) = 0.02
        _ArcHeight ("Arc Distortion", Float) = 0.1
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
            float _WaveStrength;
            float _ArcHeight;

            // pseudo-random noise
            float rand(float2 co) {
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv * _Scale;

                // animate vertically
                uv.y += _Time.y * _Speed;

                // arc curvature (bend vertically based on horizontal pos)
                float curve = sin(i.uv.x * 3.1415) * _ArcHeight;
                uv.y += curve;

                // horizontal wave distortion
                float wave = sin(i.uv.y * 12.0 + _Time.y * _Speed) * _WaveStrength;
                uv.x += wave;

                // base noise for structure
                float n = noise(uv);

                // shimmer with a second noise sample
                float shimmer = lerp(0.9, 1.1, noise(uv + float2(1.0, _Time.y * 0.3)));

                // fading
                float verticalFade = smoothstep(0.2, 0.8, i.uv.y);
                float horizontalFade = smoothstep(0.0, 0.4, abs(i.uv.x - 0.5) * 2.0);

                float brightness = smoothstep(0.3, 1.0, n) * verticalFade * horizontalFade * shimmer;

                float4 col = lerp(_MainColor, _SecondaryColor, n);
                col.rgb *= _Intensity * brightness;
                col.a = brightness;

                return col;
            }
            ENDCG
        }
    }
}
