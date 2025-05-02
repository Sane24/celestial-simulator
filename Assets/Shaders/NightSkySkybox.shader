Shader "Unlit/NightSkySkybox"
{
    Properties
    {
      // Expose these parameters in Inspector view in Unity
        _MainTex ("Texture", 2D) = "white" {}
        // https://rgbcolorpicker.com/0-1
        // RGB but from 0 to 1
        _TopColor ("Top Color", Color) = (0.05, 0.05, 0.2, 1) // dark blue
        _BottomColor ("Bottom Color", Color) = (0.0, 0.0, 0.05, 1) // basically black
        _StarDensity ("Density to Tile Star Pattern", Float) = 100.0
        _StarThreshold ("Threshold for Number of Stars to Show", Range(0, 1)) = 0.5
        _StarBrightness ("Star Brightness", Float) = 1.0
    }
    SubShader // Define a rendering strategy
    {
        Tags { "RenderType"="Opaque" "Queue" = "Background" }
        Cull Off ZWrite Off
        Lighting Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
              // pull relevant information from scene mesh
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
              // information to send from ver to frag shader
                float3 dir : TEXCOORD0; // world direction of vertex
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION; // screen space
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _TopColor;
            fixed4 _BottomColor;
            float _StarDensity;
            float _StarThreshold;
            float _StarBrightness;

            float hash(float3 p)
            {
              // simplified rand noise function
              // simulates stars without textures
                return frac(sin(dot(p, float3(12.9898, 78.233, 37.719))) * 43758.5453);
            }

            // vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // convert vertex position to clip space
                o.dir = normalize(mul(unity_ObjectToWorld, v.vertex).xyz); // calculate world-space direction from camera to this vertex
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            // fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                //// GRADIENT SKY
                float t = saturate(i.dir.y * 0.5 + 0.5); // gradient factor
                fixed4 col = lerp(_BottomColor, _TopColor, t);

                //// STARS
                // Compute base star direction
                float3 dir = normalize(i.dir);
                float3 gridPos = dir * _StarDensity;

                // Smooth falloff based on distance from center of star, appearance of soft glow)
                float3 cell = floor(gridPos);
                float3 local = frac(gridPos);
                float starNoise = hash(cell);

                float dist = distance(local, float3(0.5, 0.5, 0.5));
                float intensity = smoothstep(0.6, 0.0, dist);

                // only shows star if noise above threshold
                float star = smoothstep(_StarThreshold, 1.0, starNoise) * intensity;

                // vary brightness of star over time using sin wave
                float twinkle = 0.5 + 0.5 * sin(dot(cell, float3(1.3, 2.1, 3.7)) + _Time.y * 2.0);
                star *= twinkle;

                col.rgb += star * _StarBrightness;

                //// FOG
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
