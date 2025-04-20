Shader "Unlit/AuroraShaderCurtainLike"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.2, 1, 0.5, 1)
        _SecondaryColor ("Secondary Color", Color) = (0.0, 0.6, 1, 1)
        _Speed ("Scroll Speed", Float) = 0.5
        _Scale ("Noise Scale", Float) = 5.0
        _Intensity ("Glow Intensity", Float) = 2.0
        _WaveStrength ("Wave Distortion", Float) = 0.05
        _ArcHeight ("Arc Distortion", Float) = 0.15
        _BendStrength ("Vertex Bend Strength", Float) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
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
            float _BendStrength;

            float rand(float2 co) {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
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
                float4 pos = v.vertex;
                float2 uv = v.uv;

                // Bend vertex backward in Z for fake depth
                pos.z += sin(uv.x * 3.1415) * _BendStrength;

                o.vertex = UnityObjectToClipPos(pos);
                o.uv = uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;

                float2 uv = i.uv * _Scale;

                // swirling vertical curve
                uv.y += sin(i.uv.x * 6.0 + t) * 0.1;

                // scrolling down + sideways offset
                uv += float2(t * 0.3, t * 0.5);

                // layered sine wave distortion to make it curtain-like
                float curtainWaves = sin(i.uv.y * 15.0 + t * 2.0) * 0.05;
                uv.x += curtainWaves;

                float n = noise(uv);

                // shimmer noise overlay
                float shimmer = lerp(0.85, 1.15, noise(uv + float2(3.0, t * 0.6)));

                // Band-shaped glow
                float band = sin(uv.y * 10.0 + t) * 0.5 + 0.5;
                float glow = smoothstep(0.4, 1.0, n * band) * shimmer;

                // Vignette-style fade
                float verticalFade = smoothstep(0.15, 0.95, i.uv.y);
                float horizontalFade = smoothstep(0.0, 0.3, abs(i.uv.x - 0.5));
                float fade = verticalFade * horizontalFade;

                float brightness = glow * fade;

                // Swirled color blending
                float blendFactor = sin(uv.x * 3.0 + uv.y * 6.0 + t);
                float4 col = lerp(_MainColor, _SecondaryColor, blendFactor * 0.5 + 0.5);

                col.rgb *= _Intensity * brightness;
                col.a = brightness;

                return col;
            }
            ENDCG
        }
    }
}
