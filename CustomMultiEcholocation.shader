// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,)' with 'UnityObjectToClipPos()'

Shader "Custom/MultiEcholocation" {
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
            float GlobalVolumes[50];
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
                float a = 25.0f; // 線同士の間隔. 大きいほど狭く, ０に近いほど広い. a > 0.
                float k = 8.0f; // 線の幅. 大きいほど線幅が細くなる. k >= 1の整数.　おそらく10くらいまでが適当。
                float b = 0.3f; //線の明るさ。0~1の範囲が適当。
                float o = pi/(2*a)*(1-1/k);
                for(int num=0; num<GlobalCircleNum; num++) {
                    float dist = distance(GlobalCenters[num], i.worldPos);
                    float val = step(GlobalRadiuses[num] - 20, dist) * step(dist, GlobalRadiuses[num]) * step(sin(a*o), sin(dist*a)) * b * sin(k*a*(dist-o)) ;
                    shaderCol += fixed4(val * 3 / dist * _Color.r, val * 3 / dist * _Color.g,val * 3 / dist * _Color.b, 1.0);
                }
                return shaderCol;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}