Shader "Unlit/AuroraSpectralEmission"
{
    Properties
    {
        _Intensity ("Glow Intensity", Float) = 2.5
        _Speed ("Scroll Speed", Float) = 0.4
        _ScaleX ("Noise Scale X", Float) = 3.0
        _ScaleY ("Noise Scale Y", Float) = 8.0
        _VerticalFade ("Vertical Fade Sharpness", Float) = 2.5
        _ShimmerSpeed ("Shimmer Speed", Float) = 0.4

        [NoScaleOffset] _SpectralLUT ("Spectral LUT (optional)", 2D) = "white" {}
        _UseLUT ("Use Spectral LUT", Float) = 0 // 0 = off, 1 = on
        _WavelengthMin ("Min Wavelength", Float) = 450
        _WavelengthMax ("Max Wavelength", Float) = 650
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

            sampler2D _SpectralLUT;
            float _UseLUT;
            float _WavelengthMin;
            float _WavelengthMax;
            float _Intensity;
            float _Speed;
            float _ScaleX;
            float _ScaleY;
            float _VerticalFade;
            float _ShimmerSpeed;

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

            float3 wavelengthToRGB(float wavelength)
            {
                float r = 0.0, g = 0.0, b = 0.0;

                if (wavelength >= 380.0 && wavelength <= 440.0) {
                    r = -(wavelength - 440.0) / (440.0 - 380.0);
                    b = 1.0;
                }
                else if (wavelength > 440.0 && wavelength <= 490.0) {
                    g = (wavelength - 440.0) / (490.0 - 440.0);
                    b = 1.0;
                }
                else if (wavelength > 490.0 && wavelength <= 510.0) {
                    g = 1.0;
                    b = -(wavelength - 510.0) / (510.0 - 490.0);
                }
                else if (wavelength > 510.0 && wavelength <= 580.0) {
                    r = (wavelength - 510.0) / (580.0 - 510.0);
                    g = 1.0;
                }
                else if (wavelength > 580.0 && wavelength <= 645.0) {
                    r = 1.0;
                    g = -(wavelength - 645.0) / (645.0 - 580.0);
                }
                else if (wavelength > 645.0 && wavelength <= 750.0) {
                    r = 1.0;
                }

                // Perceived brightness falloff
                float intensity = 1.0;
                if (wavelength < 420.0)
                    intensity = 0.3 + 0.7 * (wavelength - 380.0) / (40.0);
                else if (wavelength > 700.0)
                    intensity = 0.3 + 0.7 * (750.0 - wavelength) / (50.0);

                return float3(r, g, b) * intensity;
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
                float2 uv = i.uv;
                uv.x += _Time.y * _Speed;

                float2 nUV = float2(uv.x * _ScaleX, uv.y * _ScaleY);
                float n = saturate(noise(nUV));

                // Add shimmer
                float shimmer = lerp(0.9, 1.1, noise(nUV + float2(2.1, _Time.y * _ShimmerSpeed)));
                n *= shimmer;

                float3 auroraColor;

                if (_UseLUT > 0.5)
                {
                    float wavelength = lerp(_WavelengthMin, _WavelengthMax, n);
                    float lutUV = (wavelength - _WavelengthMin) / (_WavelengthMax - _WavelengthMin);
                    auroraColor = tex2D(_SpectralLUT, float2(lutUV, 0.5)).rgb;
                }
                else
                {
                    float wavelength = lerp(_WavelengthMin, _WavelengthMax, n);
                    auroraColor = wavelengthToRGB(wavelength);
                }

                // Vertical fade (glow near top)
                float fade = pow(saturate(i.uv.y), _VerticalFade);
                float alpha = fade * n;

                // Final HDR emission
                float3 emission = auroraColor * _Intensity * fade;

                return float4(emission, alpha);
            }
            ENDCG
        }
    }
}
