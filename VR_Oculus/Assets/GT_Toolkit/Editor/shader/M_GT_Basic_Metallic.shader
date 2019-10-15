Shader "M_GT_Basic_Metallic"
{
	Properties
	{
		_UVTileOffset("UV Tile / Offset", Vector) = (1,1,0,0)
		[NoScaleOffset]_Opacity("Opacity", 2D) = "white" {}
		_Cutoff("Mask Clip Value", Float) = 1
		[NoScaleOffset]_BaseColor("Base Color", 2D) = "white" {}
		_BaseColorTint("Base Color Tint", Color) = (1,1,1,0)
		[NoScaleOffset]_Roughness("Roughness", 2D) = "white" {}
		[Toggle(_INVERT_ROUGHNESS_ON)] _Invert_Roughness("Invert_Roughness", Float) = 0
		_RoughnessMultiplier("Roughness Multiplier", Range( 0 , 10)) = 0
		[NoScaleOffset]_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		_AmbientOcclusionMultiplier("Ambient Occlusion Multiplier", Range( 0 , 10)) = 1
		[NoScaleOffset]_Height("Height", 2D) = "white" {}
		[NoScaleOffset][Normal]_Normal("Normal", 2D) = "white" {}
		[Toggle(_INVERT_NORMAL_ON)] _Invert_Normal("Invert_Normal", Float) = 0
		[NoScaleOffset]_Emissive("Emissive", 2D) = "black" {}
		_EmissiveMultiplier("Emissive Multiplier", Range( 0 , 10)) = 1
		[Header(Parallax Occlusion Mapping)]
		[Toggle(_USE_POM_ON)] _Use_POM("Use_POM", Float) = 0
		_POMHeight("POM Height", Range(0 , 1)) = 0
		_CurvatureU("Curvature U", Range(0 , 100)) = 0
		_CurvatureV("Curvature V", Range(0 , 30)) = 0
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
		uniform sampler2D _BaseColor;
		uniform sampler2D _Emissive;
		uniform float _EmissiveMultiplier;
		uniform float _RoughnessMultiplier;
		uniform sampler2D _Roughness;
		uniform sampler2D _AmbientOcclusion;
		uniform float _AmbientOcclusionMultiplier;
		uniform sampler2D _Opacity;
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
			float2 appendResult65 = (float2(_CurvatureU , _CurvatureV));
			float2 OffsetPOM7 = POM( _Height, uv_TexCoord12, ddx(uv_TexCoord12), ddx(uv_TexCoord12), ase_worldNormal, worldViewDir, i.viewDir, 16, 64, _POMHeight, 0, _Height_ST.xy, appendResult65, 0.0 );
			float2 customUVs15 = OffsetPOM7;
			#ifdef _USE_POM_ON
				float staticSwitch56 = 1.0;
			#else
				float staticSwitch56 = 0.0;
			#endif
			float2 lerpResult26 = lerp( uv_TexCoord12 , customUVs15 , staticSwitch56);
			float3 tex2DNode46 = UnpackNormal( tex2D( _Normal, lerpResult26, ddx( uv_TexCoord12 ), ddy( uv_TexCoord12 ) ) );
			#ifdef _INVERT_NORMAL_ON
				float3 staticSwitch48 = ( float3(1,-1,1) * tex2DNode46 );
			#else
				float3 staticSwitch48 = tex2DNode46;
			#endif
			o.Normal = staticSwitch48;
			o.Albedo = ( _BaseColorTint * tex2D( _BaseColor, lerpResult26 ) ).rgb;
			float4 tex2DNode61 = tex2D( _Emissive, lerpResult26 );
			o.Emission = tex2DNode61.rgb;
			o.Metallic = ( tex2DNode61 * _EmissiveMultiplier ).r;
			float4 tex2DNode60 = tex2D( _Roughness, lerpResult26 );
			#ifdef _INVERT_ROUGHNESS_ON
				float4 staticSwitch39 = ( 1.0 - tex2DNode60 );
			#else
				float4 staticSwitch39 = tex2DNode60;
			#endif
			o.Smoothness = ( _RoughnessMultiplier * staticSwitch39 ).r;
			o.Occlusion = ( tex2D( _AmbientOcclusion, lerpResult26 ) / _AmbientOcclusionMultiplier ).r;
			o.Alpha = 1;
			clip( tex2D( _Opacity, lerpResult26 ).r - _Cutoff );
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
398;239;1889;805;1879.694;589.0983;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2919.121,489.4027;Float;False;918.8176;294.3014;UV Tiling / Offset;6;12;21;20;19;16;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;19;-2883.024,570.6034;Float;False;Property;_UVTileOffset;UV Tile / Offset;0;0;Create;True;0;0;False;0;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;32;-3012.499,-374.0954;Float;False;1009.444;397.7998;Parallax Occlusion;7;66;64;13;65;7;15;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-3000.615,-124.1002;Float;False;Property;_CurvatureU;Curvature U;19;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2998.615,-52.10016;Float;False;Property;_CurvatureV;Curvature V;20;0;Create;True;0;0;False;0;0;0;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2643.821,662.9036;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;53;-3011.288,33.7029;Float;False;280;257.5;Height;1;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2643.821,573.2036;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-2471.806,584.1044;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;6;-2759.889,-705.7017;Float;False;753;278.6001;Toggle Controls;4;5;4;58;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;-2711.615,-98.10016;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2982.604,-340.5961;Float;False;Property;_POMHeight;POM Height;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-2963.591,80.90254;Float;True;Property;_Height;Height;11;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;67;-2958.884,-266.8873;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;7;-2241.084,-238.497;Float;False;0;16;64;10;0.02;0;False;1,1;True;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2708.79,-539.0026;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2704.789,-646.0037;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1576.106,-151.5979;Float;False;234;206;POM;1;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2216.301,-336.295;Float;False;customUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;56;-2256.637,-661.5055;Float;False;Property;_Use_POM;Use_POM;16;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1154.599,147.1055;Float;False;1028.198;1303.198;Metallic, Roughness, Ambient Occlusion, Emissive;13;62;61;59;41;42;39;44;38;40;60;63;68;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;26;-1526.106,-101.598;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;60;-1104.738,453.7148;Float;True;Property;_Roughness;Roughness;6;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;51;-1148.502,-356.2011;Float;False;784.5138;431.4994;Normal;4;46;49;50;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DdyOpNode;17;-2172.194,656.9021;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DdxOpNode;16;-2172.296,584.704;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;40;-771.3992,448.1067;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;46;-1098.502,-154.7021;Float;True;Property;_Normal;Normal;12;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;49;-976.9864,-306.2012;Float;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;False;0;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;37;-1074.981,-824.0994;Float;False;560.1816;451.2016;Base Color;3;34;35;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;39;-604.5007,524.3065;Float;False;Property;_Invert_Roughness;Invert_Roughness;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-596.4995,442.7062;Float;False;Property;_RoughnessMultiplier;Roughness Multiplier;8;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1720.903,98.70188;Float;False;234;206;Parallax;1;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2670.186,34.20272;Float;False;663.595;429.7004;Parallax;3;29;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;34;-1024.981,-602.897;Float;True;Property;_BaseColor;Base Color;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-763.9867,-235.5014;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;38;-1097.899,709.1061;Float;True;Property;_AmbientOcclusion;Ambient Occlusion;9;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-649.8016,785.2058;Float;False;Property;_AmbientOcclusionMultiplier;Ambient Occlusion Multiplier;10;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-946.1995,-774.0994;Float;False;Property;_BaseColorTint;Base Color Tint;3;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;-669.0967,1027.443;Float;False;Property;_EmissiveMultiplier;Emissive Multiplier;15;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;-1098.803,965.812;Float;True;Property;_Emissive;Emissive;14;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-1094.711,206.1154;Float;True;Property;_Metallic;Metallic;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;58;-2483.503,-545.7991;Float;False;Property;_UseParallax;Use Parallax;18;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-297.3006,457.1057;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;31;-2625.891,99.90263;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;63;-350.7197,721.0131;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;25;-1670.903,148.7017;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-683.799,-599.6984;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;62;-1098.712,1223.914;Float;True;Property;_Opacity;Opacity;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;48;-609.3866,-147.1015;Float;False;Property;_Invert_Normal;Invert_Normal;13;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ParallaxMappingNode;29;-2257.096,223.4023;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2509.097,315.4029;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-356.1639,944.144;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;177.4,97.40003;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;M_GT_Basic_Metallic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Masked;1;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;19;3
WireConnection;21;1;19;4
WireConnection;20;0;19;1
WireConnection;20;1;19;2
WireConnection;12;0;20;0
WireConnection;12;1;21;0
WireConnection;65;0;64;0
WireConnection;65;1;66;0
WireConnection;7;0;12;0
WireConnection;7;1;14;0
WireConnection;7;2;13;0
WireConnection;7;3;67;0
WireConnection;7;5;65;0
WireConnection;15;0;7;0
WireConnection;56;1;5;0
WireConnection;56;0;4;0
WireConnection;26;0;12;0
WireConnection;26;1;15;0
WireConnection;26;2;56;0
WireConnection;60;1;26;0
WireConnection;17;0;12;0
WireConnection;16;0;12;0
WireConnection;40;0;60;0
WireConnection;46;1;26;0
WireConnection;46;3;16;0
WireConnection;46;4;17;0
WireConnection;39;1;60;0
WireConnection;39;0;40;0
WireConnection;34;1;26;0
WireConnection;50;0;49;0
WireConnection;50;1;46;0
WireConnection;38;1;26;0
WireConnection;61;1;26;0
WireConnection;59;1;26;0
WireConnection;58;1;5;0
WireConnection;58;0;4;0
WireConnection;41;0;42;0
WireConnection;41;1;39;0
WireConnection;31;0;14;0
WireConnection;63;0;38;0
WireConnection;63;1;44;0
WireConnection;25;0;12;0
WireConnection;25;1;29;0
WireConnection;25;2;58;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;62;1;26;0
WireConnection;48;1;46;0
WireConnection;48;0;50;0
WireConnection;29;0;12;0
WireConnection;29;1;31;1
WireConnection;29;2;13;0
WireConnection;29;3;30;0
WireConnection;68;0;61;0
WireConnection;68;1;69;0
WireConnection;0;0;36;0
WireConnection;0;1;48;0
WireConnection;0;2;61;0
WireConnection;0;3;68;0
WireConnection;0;4;41;0
WireConnection;0;5;63;0
WireConnection;0;10;62;1
ASEEND*/
//CHKSM=D9C02C38BFDC3CF3DEADD9BBF065EF831B63D0FB