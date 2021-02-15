Shader "RitoURP/VertexFragmentStartPoint"
{
    Properties
    {
        _MainTex ("Main Map", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags 
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            // Receiving Shadow Options
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            // Transformations : CG -> HLSL Compatability
            #define UnityObjectToClipPos(x)     TransformObjectToHClip(x)
            #define UnityObjectToWorldDir(x)    TransformObjectToWorldDir(x)
            #define UnityObjectToWorldNormal(x) TransformObjectToWorldNormal(x)
            
            #define UnityWorldToViewPos(x)      TransformWorldToView(x)
            #define UnityWorldToObjectDir(x)    TransformWorldToObjectDir(x)
            #define UnityWorldSpaceViewDir(x)   _WorldSpaceCameraPos.xyz - x

            struct appdata
            {
                float4 vertex : POSITION; // Object Position
                float3 normal : NORMAL;   // Object Normal
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // Clip Position
                float2 uv : TEXCOORD0;
                float3 wPos : TEXCOORD1;
                float3 wNormal : TEXCOORD2;

                // Tangent -> World 회전 변환을 위한 3x3 매트릭스
                float3 tspace0 : TEXCOORD3; // tangent.x, bitangent.x, normal.x
                float3 tspace1 : TEXCOORD4; // tangent.y, bitangent.y, normal.y
                float3 tspace2 : TEXCOORD5; // tangent.z, bitangent.z, normal.z

                float4 shadowCoord : TEXCOORD6;
                float fogCoord : TEXCOORD7;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            /*****************************************************************
            *                             VARIABLES
            ******************************************************************/
            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            CBUFFER_END

            /*****************************************************************
            *                             VERTEX
            ******************************************************************/
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);

                // Calculate Bitangent
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 wBitangent = cross(wNormal, wTangent) * tangentSign;

                // Tangent To World 행렬
                o.tspace0 = float3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = float3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = float3(wTangent.z, wBitangent.z, wNormal.z);
                
                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.wPos = TransformObjectToWorld(v.vertex.xyz);
                //o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wNormal = wNormal;

                // Shadow
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.shadowCoord = GetShadowCoord(vertexInput);

                // Fog
                o.fogCoord = ComputeFogFactor(o.vertex.z);

                return o;
            }
            
            /*****************************************************************
            *                             FRAGMENT
            ******************************************************************/
            // fixed4 대신 half4
            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float3 col = 1.;
                float alpha = 1.;

                Light mainLight = GetMainLight(i.shadowCoord);

                // World Vectors
                float3 wPos    = i.wPos;
                float3 wNormal = normalize(i.wNormal);
                float3 wView   = normalize(UnityWorldSpaceViewDir(wPos));
                float3 wLight  = normalize(_MainLightPosition.xyz);
                float3 wHalf   = normalize(wLight + wView);
                float3 wLReflect = reflect(-wLight, wNormal);

                // Calculate World Normal From Normal Map
                float4 normalMapCol = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv);
                float3 tNormal0 = UnpackNormal(normalMapCol);
                float3 wNormal0;
                wNormal0.x = dot(i.tspace0, tNormal0);
                wNormal0.y = dot(i.tspace1, tNormal0);
                wNormal0.z = dot(i.tspace2, tNormal0);
                
                wNormal = wNormal0;

                // Lighting Term
                float ndl = dot(wNormal, wLight);
                float ndv = dot(wNormal, wView);
                float ndh = dot(wNormal, wHalf);
                float rdv = dot(wLReflect, wView);

                float diffuse = saturate(ndl);
                float specPhong = pow(saturate(rdv), 30.) * .4;
                float specBlinnPhong = pow(saturate(ndh), 80.) * .8;
                float fresnel = pow(1. - saturate(ndv), 3.) * .5;

                half3 ambient = SampleSH(wNormal);

                // Final Color

                //col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                float light = saturate(diffuse + specBlinnPhong);
                col *= light * _MainLightColor.rgb * mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                col += fresnel;
                col += ambient;

                col = MixFog(col.rgb, i.fogCoord);

                return half4(col, alpha);
            }
            ENDHLSL
        }
    }
}

