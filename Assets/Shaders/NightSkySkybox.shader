Shader "Unlit/NightSkySkybox"
{
    Properties
    {
      // Expose these parameters in Inspector view in Unity
        _MainTex ("Texture", 2D) = "white" {}
        _TopColor ("Top Color", Color) = (0.05, 0.05, 0.2, 1)
        _BottomColor ("Bottom Color", Color) = (0.0, 0.0, 0.05, 1)
        _StarDensity ("Star Density", Float) = 100.0
        _StarThreshold ("Star Threshold", Range(0, 1)) = 0.98
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
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.dir);

                float t = saturate(i.dir.y * 0.5 + 0.5); // gradient factor
                fixed4 col = lerp(_BottomColor, _TopColor, t);

                float3 starDir = floor(i.dir * _StarDensity); // tile this
                
                // compute noise
                // then step() for binary where vertex is bright if above threshold
                float starNoise = hash(starDir);
                float star = step(_StarThreshold, starNoise);

                col.rgb += star * _StarBrightness;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
