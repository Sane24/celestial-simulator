Shader "Unlit/water"
{
    Properties
    {
       //_Cubemap("Reflection Cubemap", CUBE) = "" {}
       _Transparency("Transparency", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                float3 worldPos : TEXCOORD0;   
                float3 worldNormal : TEXCOORD1;
              
            };

            //samplerCUBE _Cubemap;
            float _Transparency;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
   

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
       
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectDir = reflect(-viewDir, normal);

                fixed4 reflectionColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectDir);
                reflectionColor.a = _Transparency;
                return reflectionColor;
   
            }
            ENDCG
        }
    }
}
