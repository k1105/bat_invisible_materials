// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,)' with 'UnityObjectToClipPos()'

Shader "Custom/Glow" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        //_Center ("Center", vector) = (0, 0, 0)
        //_Radius ("Radius", float) = 0
    }
    SubShader {
        Pass {
            Tags { "RenderType"="Opaque" }

            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _Color;
            float3 GlobalCenters[50];
            float GlobalRadiuses[50];
            int GlobalCircleNum;

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : COLOR {
                float pi = 3.1415926535;
                fixed4 shaderCol;
                float offset = 30.0 ; //持続時間

                for(int num=0;num < GlobalCircleNum; num+=2) {
                    float a = 0.05; //消えていく速さ
                    float b = 1 - a * GlobalRadiuses[num]; //明るさ
                    float dist = distance(GlobalCenters[num], i.worldPos);
                    float val = step(GlobalRadiuses[num] - offset, dist) * step(dist, GlobalRadiuses[num]) * sin(GlobalRadiuses[num]*pi/offset);
                    shaderCol += fixed4( val / dist * _Color.r, val / dist * _Color.g, val / dist * _Color.b, 1.0);
}  
                return shaderCol;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}