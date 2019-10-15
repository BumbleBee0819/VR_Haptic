Shader "M_GT_Decal_Metallic"
{
	Properties
	{
		_UVTileOffset("UV Tile / Offset", Vector) = (1,1,0,0)
		[Toggle(_USEMATERIALALPHA_ON)] _UseMaterialAlpha("Use Material Alpha", Float) = 0
		_Cutoff("Mask Clip Value", Float) = 1
		[NoScaleOffset]_BaseColorAlpha("Base Color [Alpha]", 2D) = "white" {}
		_BaseColorTint("Base Color Tint", Color) = (1,1,1,0)
		[NoScaleOffset]_DETMRAO("DET [MRAO]", 2D) = "white" {}
		_RoughnessMultiplier("Roughness Multiplier", Range( 0 , 10)) = 0
		[Toggle(_INVERT_ROUGHNESS_ON)] _Invert_Roughness("Invert_Roughness", Float) = 0
		_AmbientOcclusionMultiplier("Ambient Occlusion Multiplier", Range( 0 , 10)) = 1
		[NoScaleOffset]_Height("Height", 2D) = "white" {}
		[NoScaleOffset][Normal]_Normal("Normal", 2D) = "white" {}
		[Toggle(_INVERT_NORMAL_ON)] _Invert_Normal("Invert_Normal", Float) = 0
		[NoScaleOffset]_Emissive("Emissive", 2D) = "black" {}
		_EmissiveMultiplier("Emissive Multiplier", Range( 0 , 10)) = 1
		[Header(Decal Controls)]
		[Toggle(_USERADIALGRADIENTHEIGHT_ON)] _UseRadialGradientHeight("Use Radial Gradient + Height", Float) = 0
		_OpacityEdgeThreshold("Opacity Edge Threshold", Range( 0 , 1)) = 0
		_GradientRadius("Gradient Radius", Range( 0 , 1)) = 0.5
		_GradientDensity("Gradient Density", Range( 0 , 1)) = 0.5
		_HeightClamp("Height Clamp", Range( 0 , 1)) = 1
		[Header(Parallax Occlusion Mapping)]
		[Toggle(_USE_POM_ON)] _Use_POM("Use_POM", Float) = 0
		_POMHeight("POM Height", Range(0 , 10)) = 0
		_CurvatureV("Curvature V", Range(0 , 30)) = 0
		_CurvatureU("Curvature U", Range(0 , 100)) = 0
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] _CurvFix("Curvature Bias", Range( 0 , 1)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _INVERT_NORMAL_ON
		#pragma shader_feature _USE_POM_ON
		#pragma shader_feature _INVERT_ROUGHNESS_ON
		#pragma shader_feature _USERADIALGRADIENTHEIGHT_ON
		#pragma shader_feature _USEMATERIALALPHA_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldPos;
		};

		uniform sampler2D _Normal;
		uniform float4 _UVTileOffset;
		uniform sampler2D _Height;
		uniform float _POMHeight;
		uniform float _CurvFix;
		uniform float _CurvatureU;
		uniform float _CurvatureV;
		uniform float4 _Height_ST;
		uniform float4 _BaseColorTint;
		uniform sampler2D _BaseColorAlpha;
		uniform sampler2D _Emissive;
		uniform float _EmissiveMultiplier;
		uniform sampler2D _DETMRAO;
		uniform float _RoughnessMultiplier;
		uniform float _AmbientOcclusionMultiplier;
		uniform float _GradientRadius;
		uniform float _GradientDensity;
		uniform float _HeightClamp;
		uniform float _OpacityEdgeThreshold;
		uniform float _Cutoff = 1;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, (float)dot( normalWorld, viewWorld ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
				result.z = dot( curv, currTexOffset * currTexOffset );
				currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r * ( 1 - result.z );
				if ( currHeight > currRayZ )
				{
					stepIndex = numSteps + 1;
				}
				else
				{
					stepIndex++;
					prevTexOffset = currTexOffset;
					prevRayZ = currRayZ;
					prevHeight = currHeight;
					currTexOffset += deltaTex;
					currRayZ -= layerHeight * ( 1 - result.z ) * (1+_CurvFix);
				}
			}
			int sectionSteps = 10;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
				intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
				finalTexOffset = prevTexOffset + intersection * deltaTex;
				newZ = prevRayZ - intersection * layerHeight;
				newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
				if ( newHeight > newZ )
				{
					currTexOffset = finalTexOffset;
					currHeight = newHeight;
					currRayZ = newZ;
					deltaTex = intersection * deltaTex;
					layerHeight = intersection * layerHeight;
				}
				else
				{
					prevTexOffset = finalTexOffset;
					prevHeight = newHeight;
					prevRayZ = newZ;
					deltaTex = ( 1 - intersection ) * deltaTex;
					layerHeight = ( 1 - intersection ) * layerHeight;
				}
				sectionIndex++;
			}
			#ifdef UNITY_PASS_SHADOWCASTER
			if ( unity_LightShadowBias.z == 0.0 )
			{
			#endif
				if ( result.z > 1 )
					clip( -1 );
			#ifdef UNITY_PASS_SHADOWCASTER
			}
			#endif
			return uvs + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult20 = (float2(_UVTileOffset.x , _UVTileOffset.y));
			float2 appendResult21 = (float2(_UVTileOffset.z , _UVTileOffset.w));
			float2 uv_TexCoord12 = i.uv_texcoord * appendResult20 + appendResult21;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float2 appendResult63 = (float2(_CurvatureU , _CurvatureV));
			float2 OffsetPOM7 = POM( _Height, uv_TexCoord12, ddx(uv_TexCoord12), ddx(uv_TexCoord12), ase_worldNormal, worldViewDir, i.viewDir, 16, 64, _POMHeight, 0, _Height_ST.xy, appendResult63, 0.0 );
			float2 customUVs15 = OffsetPOM7;
			#ifdef _USE_POM_ON
				float staticSwitch56 = 1.0;
			#else
				float staticSwitch56 = 0.0;
			#endif
			float2 lerpResult26 = lerp( uv_TexCoord12 , customUVs15 , staticSwitch56);
			float4 tex2DNode46 = tex2D( _Normal, lerpResult26, ddx( uv_TexCoord12 ), ddy( uv_TexCoord12 ) );
			#ifdef _INVERT_NORMAL_ON
				float4 staticSwitch48 = ( float4( float3(1,-1,1) , 0.0 ) * tex2DNode46 );
			#else
				float4 staticSwitch48 = tex2DNode46;
			#endif
			o.Normal = staticSwitch48.rgb;
			float4 tex2DNode34 = tex2D( _BaseColorAlpha, lerpResult26 );
			o.Albedo = ( _BaseColorTint * tex2DNode34 ).rgb;
			o.Emission = ( tex2D( _Emissive, lerpResult26 ) * _EmissiveMultiplier ).rgb;
			float4 tex2DNode38 = tex2D( _DETMRAO, lerpResult26 );
			o.Metallic = tex2DNode38.r;
			#ifdef _INVERT_ROUGHNESS_ON
				float staticSwitch39 = ( 1.0 - tex2DNode38.g );
			#else
				float staticSwitch39 = tex2DNode38.g;
			#endif
			o.Smoothness = ( _RoughnessMultiplier * staticSwitch39 );
			o.Occlusion = ( tex2DNode38.b / _AmbientOcclusionMultiplier );
			o.Alpha = 1;
			float2 uv_Height31 = i.uv_texcoord;
			float4 tex2DNode31 = tex2D( _Height, uv_Height31 );
			float temp_output_6_0_g4 = ( distance( float2( 1,1 ) , float2( 0.5,0.5 ) ) * 1.0 );
			float temp_output_5_0_g4 = _GradientRadius;
			float temp_output_11_0_g4 = ( temp_output_6_0_g4 / temp_output_5_0_g4 );
			float temp_output_14_0_g4 = ( 1.0 - temp_output_11_0_g4 );
			float temp_output_11_0_g6 = temp_output_14_0_g4;
			float temp_output_13_0_g4 = _GradientDensity;
			float temp_output_10_0_g6 = ( temp_output_11_0_g6 * temp_output_13_0_g4 );
			float lerpResult8_g6 = lerp( temp_output_10_0_g6 , ( temp_output_10_0_g6 * temp_output_10_0_g6 ) , 1.0);
			float ifLocalVar1_g6 = 0;
			if( temp_output_11_0_g6 <= 0.0 )
				ifLocalVar1_g6 = 1.0;
			else
				ifLocalVar1_g6 = ( 1.0 / pow( 2.718 , lerpResult8_g6 ) );
			float temp_output_11_0_g5 = temp_output_11_0_g4;
			float temp_output_10_0_g5 = ( temp_output_11_0_g5 * temp_output_13_0_g4 );
			float lerpResult8_g5 = lerp( temp_output_10_0_g5 , ( temp_output_10_0_g5 * temp_output_10_0_g5 ) , 1.0);
			float ifLocalVar1_g5 = 0;
			if( temp_output_11_0_g5 <= 0.0 )
				ifLocalVar1_g5 = 1.0;
			else
				ifLocalVar1_g5 = ( 1.0 / pow( 2.718 , lerpResult8_g5 ) );
			float temp_output_29_0_g4 = ifLocalVar1_g5;
			float lerpResult25_g4 = lerp( ( 1.0 - ifLocalVar1_g6 ) , temp_output_29_0_g4 , (float)0);
			#ifdef _USERADIALGRADIENTHEIGHT_ON
				float staticSwitch73 = 1.0;
			#else
				float staticSwitch73 = 0.0;
			#endif
			float lerpResult72 = lerp( tex2DNode31.r , ( lerpResult25_g4 * tex2DNode31.r ) , staticSwitch73);
			float dotResult77 = dot( lerpResult72 , ( _HeightClamp * 10.0 ) );
			float temp_output_8_0_g8 = dotResult77;
			float temp_output_12_0_g8 = _OpacityEdgeThreshold;
			float temp_output_14_0_g8 = ( temp_output_12_0_g8 + temp_output_12_0_g8 );
			float lerpResult3_g8 = lerp( -5.0 , 1.0 , ( temp_output_8_0_g8 * ( 1.0 / temp_output_14_0_g8 ) ));
			float ifLocalVar1_g8 = 0;
			if( temp_output_8_0_g8 > temp_output_14_0_g8 )
				ifLocalVar1_g8 = temp_output_8_0_g8;
			else if( temp_output_8_0_g8 < temp_output_14_0_g8 )
				ifLocalVar1_g8 = ( lerpResult3_g8 * temp_output_14_0_g8 );
			#ifdef _USEMATERIALALPHA_ON
				float staticSwitch88 = 1.0;
			#else
				float staticSwitch88 = 0.0;
			#endif
			float lerpResult67 = lerp( pow( ifLocalVar1_g8 , 2.0 ) , tex2DNode34.a , staticSwitch88);
			clip( lerpResult67 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=15301
398;239;1889;805;4677.971;1839.06;3.930524;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2919.121,489.4027;Float;False;918.8176;294.3014;UV Tiling / Offset;6;12;21;20;19;16;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;19;-2883.024,570.6034;Float;False;Property;_UVTileOffset;UV Tile / Offset;0;0;Create;True;0;0;False;0;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;32;-3012.499,-374.0954;Float;False;1003.903;360.3977;Parallax Occlusion;7;7;13;15;61;62;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2959.985,-159.7381;Float;False;Property;_CurvatureU;Curvature U;22;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;86;-2185.521,-1534.711;Float;False;2172.505;641.9833;Opoacity;15;69;70;71;72;73;75;74;78;79;80;82;84;83;77;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2960.986,-88.87756;Float;False;Property;_CurvatureV;Curvature V;21;0;Create;True;0;0;False;0;0;0;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2643.821,573.2036;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;53;-3011.288,33.7029;Float;False;280;257.5;Height;1;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2643.821,662.9036;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2105.455,-1430.111;Float;False;Property;_GradientRadius;Gradient Radius;16;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2745.101,-324.5959;Float;False;Property;_POMHeight;POM Height;19;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-2600.681,-122.6875;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;64;-2957.2,-314.7928;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;6;-2759.889,-705.7017;Float;False;753;278.6001;Toggle Controls;4;5;4;56;58;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-2471.806,584.1044;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;14;-2963.591,80.90254;Float;True;Property;_Height;Height;9;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2106.92,-1302.757;Float;False;Property;_GradientDensity;Gradient Density;17;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2670.186,34.20272;Float;False;663.595;429.7004;Parallax;3;29;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;7;-2260.683,-203.2969;Float;False;0;16;64;10;0.02;0;False;1,1;True;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;31;-2626.891,99.90263;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-2708.79,-539.0026;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2704.789,-646.0037;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;80;-1691.36,-1404.127;Float;False;MF_RadialGradientExponential;-1;;4;991cde23618e17345b0c5469cd51125c;0;5;2;FLOAT2;1,1;False;4;FLOAT2;0.5,0.5;False;5;FLOAT;0.5;False;13;FLOAT;2.333;False;26;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1856.161,-1078.797;Float;False;Constant;_Float5;Float 5;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1856.162,-1173.834;Float;False;Constant;_Float4;Float 4;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1053.663,-1032.176;Float;False;Property;_HeightClamp;Height Clamp;23;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1140.11,-1322.226;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2233.5,-327.0948;Float;False;customUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;56;-2457.903,-656.1996;Float;False;Property;_Use_POM;Use_POM;18;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1576.106,-151.5979;Float;False;234;206;POM;1;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;73;-1643.661,-1173.528;Float;False;Property;_UseRadialGradientHeight;Use Radial Gradient + Height;14;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1154.799,325.0995;Float;False;987.1981;456.6984;DET [Metallic, Roughness, Ambient Occlusion];10;59;38;41;39;42;40;60;44;65;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;72;-940.8725,-1213.702;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-734.2034,-1046.127;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;-1526.106,-101.598;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DdxOpNode;16;-2172.296,584.704;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DdyOpNode;17;-2172.194,656.9021;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;51;-1148.502,-142.0014;Float;False;784.5138;431.4994;Normal;4;46;49;50;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;38;-1104.799,375.0995;Float;True;Property;_DETMRAO;DET [MRAO];5;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;84;-673.0154,-1343.172;Float;False;Property;_OpacityEdgeThreshold;Opacity Edge Threshold;15;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;77;-549.4553,-1153.284;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-555.0154,-1247.172;Float;False;Constant;_Float6;Float 6;22;0;Create;True;0;0;False;0;-5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;49;-976.9864,-92.00143;Float;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;False;0;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;46;-1098.502,59.49785;Float;True;Property;_Normal;Normal;10;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;37;-1074.981,-609.8984;Float;False;560.1816;451.2016;Base Color;3;34;35;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;82;-290.0154,-1283.172;Float;False;MF_SmoothThreshold;-1;;8;2d4f538fc77cc4341bdaed4bc6fc01cd;0;3;12;FLOAT;0;False;5;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;40;-805.5994,418.2986;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-946.1995,-559.8984;Float;False;Property;_BaseColorTint;Base Color Tint;4;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-1102.116,575.314;Float;True;Property;_Emissive;Emissive;12;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-763.9867,-21.30147;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;39;-629.6006,471.0986;Float;False;Property;_Invert_Roughness;Invert_Roughness;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-686.4854,697.276;Float;False;Property;_EmissiveMultiplier;Emissive Multiplier;13;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-621.5994,389.4982;Float;False;Property;_RoughnessMultiplier;Roughness Multiplier;6;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;85;-236.2052,-1025.728;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;88;-1074.755,-803.1628;Float;False;Property;_UseMaterialAlpha;Use Material Alpha;2;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-649.8396,607.67;Float;False;Property;_AmbientOcclusionMultiplier;Ambient Occlusion Multiplier;8;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-1024.981,-388.6968;Float;True;Property;_BaseColorAlpha;Base Color [Alpha];1;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;28;-1720.903,98.70188;Float;False;234;206;Parallax;1;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;58;-2483.503,-545.7991;Float;False;Property;_UseParallax;Use Parallax;20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-323.4854,670.276;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;25;-1670.903,148.7017;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-322.4002,403.8978;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;-320.0177,526.2169;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-153.4409,-468.5705;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2509.097,315.4029;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;48;-609.3866,67.09851;Float;False;Property;_Invert_Normal;Invert_Normal;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ParallaxMappingNode;29;-2257.096,223.4023;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-683.799,-385.4982;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;98.39996,-33.6;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;M_GT_Decal_Metallic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Masked;1;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;87;-2156.92,-1480.111;Float;False;882.2585;516.3145;Radial Gradient (To blend with height);0;;1,1,1,1;0;0
WireConnection;20;0;19;1
WireConnection;20;1;19;2
WireConnection;21;0;19;3
WireConnection;21;1;19;4
WireConnection;63;0;61;0
WireConnection;63;1;62;0
WireConnection;12;0;20;0
WireConnection;12;1;21;0
WireConnection;7;0;12;0
WireConnection;7;1;14;0
WireConnection;7;2;13;0
WireConnection;7;3;64;0
WireConnection;7;5;63;0
WireConnection;31;0;14;0
WireConnection;80;5;69;0
WireConnection;80;13;70;0
WireConnection;71;0;80;0
WireConnection;71;1;31;1
WireConnection;15;0;7;0
WireConnection;56;1;5;0
WireConnection;56;0;4;0
WireConnection;73;1;74;0
WireConnection;73;0;75;0
WireConnection;72;0;31;1
WireConnection;72;1;71;0
WireConnection;72;2;73;0
WireConnection;79;0;78;0
WireConnection;26;0;12;0
WireConnection;26;1;15;0
WireConnection;26;2;56;0
WireConnection;16;0;12;0
WireConnection;17;0;12;0
WireConnection;38;1;26;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;46;1;26;0
WireConnection;46;3;16;0
WireConnection;46;4;17;0
WireConnection;82;12;84;0
WireConnection;82;5;83;0
WireConnection;82;8;77;0
WireConnection;40;0;38;2
WireConnection;59;1;26;0
WireConnection;50;0;49;0
WireConnection;50;1;46;0
WireConnection;39;1;38;2
WireConnection;39;0;40;0
WireConnection;85;0;82;0
WireConnection;88;1;74;0
WireConnection;88;0;75;0
WireConnection;34;1;26;0
WireConnection;58;1;5;0
WireConnection;58;0;4;0
WireConnection;65;0;59;0
WireConnection;65;1;66;0
WireConnection;25;0;12;0
WireConnection;25;1;29;0
WireConnection;25;2;58;0
WireConnection;41;0;42;0
WireConnection;41;1;39;0
WireConnection;60;0;38;3
WireConnection;60;1;44;0
WireConnection;67;0;85;0
WireConnection;67;1;34;4
WireConnection;67;2;88;0
WireConnection;48;1;46;0
WireConnection;48;0;50;0
WireConnection;29;0;12;0
WireConnection;29;1;31;1
WireConnection;29;2;13;0
WireConnection;29;3;30;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;0;0;36;0
WireConnection;0;1;48;0
WireConnection;0;2;65;0
WireConnection;0;3;38;1
WireConnection;0;4;41;0
WireConnection;0;5;60;0
WireConnection;0;10;67;0
ASEEND*/
//CHKSM=98E86E83ABDD6DDE572D5DF530A9FB766A9AC5A5