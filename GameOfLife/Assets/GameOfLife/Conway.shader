Shader "Conway" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	
	uniform sampler2D _MainTex;
	uniform fixed4    _MainTex_Texelsize;
	
	uniform float2    _Mouse;
	uniform float2    _Resolution;
	
	struct appdata_t {
		float4 vertex   : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 vertex   : SV_POSITION;
		half2  texcoord : TEXCOORD0;
	};
	
	v2f vert (appdata_t v) {
		v2f o = (v2f)0;
		o.vertex   = mul(UNITY_MATRIX_MVP, v.vertex);
		o.texcoord = v.texcoord;
		return o;
	}
	
	fixed4 frag (v2f i) : COLOR
	{
		fixed4 live = fixed4 (0.5, 1.0, 0.7, 1.0);
		fixed4 dead = fixed4 (0.0, 0.0, 0.0, 1.0);
		fixed4 blue = fixed4 (0.0, 0.0, 1.0, 1.0);
		
		float2 position = i.texcoord.xy;
		float2 pixel    = 1.0/_Resolution.xy;
		float2 mouse    = _Mouse;
		float  time     = _Time.y * 1;
		
		fixed4 col      = fixed4 (0.0, 0.0, 0.0, 1.0);
		
		float  dX = 1.0;//(1.0 / (float)_Resolution.x);
		float  dY = 1.0;//(1.0 / (float)_Resolution.y);
		
		if (length (position - mouse) < 0.01) {
			float rnd1 = fmod(frac(sin(dot(position + time * 0.001, fixed2(14.9898,78.233))) * 43758.5453), 1.0);
			if (rnd1 > 0.5) {
				col = live;
			} else {
				col = blue;
			}
		} else {
			float sum = 0.0;
			sum += tex2D(_MainTex, position + pixel * fixed2(-1.0 * dX, -1.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2(-1.0 * dX,  0.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2(-1.0 * dX,  1.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2( 1.0 * dX, -1.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2( 1.0 * dX,  0.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2( 1.0 * dX,  1.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2( 0.0 * dX, -1.0 * dY)).g;
			sum += tex2D(_MainTex, position + pixel * fixed2( 0.0 * dX,  1.0 * dY)).g;
			fixed4 me = tex2D(_MainTex, position);
			
			if (me.g <= 0.1) {
				if ((sum >= 2.9) && (sum <= 3.1)) {
					col = live;
				} else if (me.b > 0.4) {
					col = fixed4(0.0, 0.0, max(me.b - 0.4, 0.25), 1.0);
				} else {
					col = dead;
				}
			} else {
				if ((sum >= 1.9) && (sum <= 3.1)) {
					col = live;
				} else {
					col = blue;
				}
			}
		}
		
		return col;
	}
	ENDCG

	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma target   3.0
			#pragma vertex   vert
			#pragma fragment frag
			
			ENDCG
		}
	
	} 
	FallBack Off
}