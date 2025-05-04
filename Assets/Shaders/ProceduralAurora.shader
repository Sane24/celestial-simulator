Shader "Unlit/ProceduralAurora"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0.2, 1.0, 0.5, 1.0)
        _SecondaryColor ("Secondary Color", Color) = (0.0, 0.5, 1.0, 1.0)
        _Speed ("Scroll Speed", Float) = 0.8
        _ScaleX ("Noise Scale X", Float) = 3.0
        _ScaleY ("Noise Scale Y", Float) = 7.0
        _Intensity ("Glow Intensity", Float) = 2.0
        _VerticalFade ("Vertical Fade Sharpness", Float) = 2.0
        _ShimmerSpeed ("Shimmer Speed", Float) = 0.3
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

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
            float _ScaleX;
            float _ScaleY;
            float _Intensity;
            float _VerticalFade;
            float _ShimmerSpeed;

            // Simple 2D value noise
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
                // Animate scroll horizontally
                float2 uv = i.uv;
                uv.x += _Time.y * _Speed;

                // More detail in vertical noise
                float2 nUV = float2(uv.x * _ScaleX, uv.y * _ScaleY);
                float n = noise(nUV);

                // Extra shimmer layer
                float shimmer = lerp(0.9, 1.1, noise(nUV + float2(1.7, _Time.y * _ShimmerSpeed)));
                n *= shimmer;

                // Smooth vertical fade
                float fade = pow(saturate(i.uv.y), _VerticalFade);

                // Blend main and secondary color using noise
                float4 color = lerp(_MainColor, _SecondaryColor, n);
                color.rgb *= _Intensity * fade;
                color.a = fade * n;

                return color;
            }
            ENDCG
        }
    }
}