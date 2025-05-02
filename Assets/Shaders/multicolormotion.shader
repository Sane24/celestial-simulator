Shader "Unlit/AuroraShaderCurtain_Multicolor"
{
    Properties
    {
        _Color1 ("Base Color", Color) = (0.2, 1, 0.5, 1)
        _Color2 ("Mid Color", Color) = (0.0, 0.6, 1, 1)
        _Color3 ("Edge Color", Color) = (0.8, 0.3, 1, 1)
        _Speed ("Scroll Speed", Float) = 0.2
        _ScaleX ("Noise Scale X", Float) = 4.0
        _ScaleY ("Noise Scale Y", Float) = 3.0
        _Intensity ("Glow Intensity", Float) = 1.8
        _WaveStrength ("Horizontal Wave", Float) = 0.03
        _RippleStrength ("Vertical Ripple", Float) = 0.05
        _RippleFrequency ("Ripple Frequency", Float) = 8.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300
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
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float _Speed;
            float _ScaleX;
            float _ScaleY;
            float _Intensity;
            float _WaveStrength;
            float _RippleStrength;
            float _RippleFrequency;

            float rand(float2 co) {
                return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
            }

            float noise(float2 p) {
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
                float t = _Time.y * _Speed;

                float2 uv = i.uv;
                uv.x += t;

                // Ripple motion
                float ripple = sin(uv.x * _RippleFrequency + t * 1.5) * _RippleStrength;
                uv.y += ripple;

                // Horizontal wave motion
                uv.x += sin(uv.y * 10.0 + t * 2.0) * _WaveStrength;

                float2 nUV = float2(uv.x * _ScaleX, uv.y * _ScaleY);
                float n = noise(nUV);

                float shimmer = lerp(0.85, 1.15, noise(nUV + float2(1.5, t * 0.4)));
                n *= shimmer;

                // Color banding
                float4 col;
                if (n < 0.3)
                    col = lerp(_Color1, _Color2, n / 0.3);
                else if (n < 0.7)
                    col = lerp(_Color2, _Color3, (n - 0.3) / 0.4);
                else
                    col = lerp(_Color3, _Color1, (n - 0.7) / 0.3);

                // Fading
                float verticalFade = smoothstep(0.15, 0.95, i.uv.y);

                //Center glow, fade at edges
                float horizontalFade = smoothstep(0.9, 0.0, abs(i.uv.x - 0.5));
                float brightness = shimmer * verticalFade * horizontalFade;

                col.rgb *= _Intensity * brightness;
                col.a = brightness;

                return col;
            }
            ENDCG
        }
    }
}
