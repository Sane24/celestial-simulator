Shader "Unlit/AuroraAdvanced"
{
    Properties
    {
        _Color1("Inner Color", Color) = (0.2, 1.0, 0.6, 1)
        _Color2("Mid Color", Color) = (0.0, 0.6, 1.0, 1)
        _Color3("Outer Color", Color) = (0.9, 0.3, 1.0, 1)
        _Speed("Scroll Speed", Float) = 0.2
        _ScaleX("Noise Scale X", Float) = 3.0
        _ScaleY("Noise Scale Y", Float) = 5.0
        _Intensity("Glow Intensity", Float) = 2.5
        _VerticalFade("Vertical Fade Sharpness", Float) = 2.0
        _HorizontalFade("Horizontal Fade Width", Float) = 0.35
        _ShimmerStrength("Shimmer Strength", Float) = 0.2
        _RippleFreq("Ripple Frequency", Float) = 8.0
        _RippleAmp("Ripple Amplitude", Float) = 0.05
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        LOD 300

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Inputs
            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float _Speed;
            float _ScaleX;
            float _ScaleY;
            float _Intensity;
            float _VerticalFade;
            float _HorizontalFade;
            float _ShimmerStrength;
            float _RippleFreq;
            float _RippleAmp;

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

            float rand(float2 co)
            {
                return frac(sin(dot(co, float2(12.9898,78.233))) * 43758.5453);
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
                float t = _Time.y * _Speed;
                float2 uv = i.uv;

                // Ripple on vertical axis
                uv.y += sin(uv.x * _RippleFreq + t * 2.0) * _RippleAmp;

                // Horizontal flow
                uv.x += t;

                // Sample noise with scrolling
                float2 nUV = float2(uv.x * _ScaleX, uv.y * _ScaleY);
                float n = noise(nUV);

                // Add shimmer
                n *= lerp(1.0 - _ShimmerStrength, 1.0 + _ShimmerStrength, noise(nUV + float2(1.7, t * 0.5)));

                // Blend colors based on noise band
                float4 col;
                if (n < 0.3)
                    col = lerp(_Color1, _Color2, n / 0.3);
                else if (n < 0.7)
                    col = lerp(_Color2, _Color3, (n - 0.3) / 0.4);
                else
                    col = lerp(_Color3, _Color1, (n - 0.7) / 0.3);

                // Vertical fade near bottom
                float verticalFade = pow(saturate(i.uv.y), _VerticalFade);

                // Horizontal edge fade (center glow)
                float distFromCenter = abs(i.uv.x - 0.5);
                float horizontalFade = smoothstep(0.5, _HorizontalFade, 0.5 - distFromCenter);

                float fade = verticalFade * horizontalFade;

                col.rgb *= _Intensity * fade;
                col.a = fade * n;

                return col;
            }
            ENDCG
        }
    }
}
