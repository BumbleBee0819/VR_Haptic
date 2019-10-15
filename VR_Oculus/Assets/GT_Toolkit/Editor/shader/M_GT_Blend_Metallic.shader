Shader "M_GT_Blend_Metallic"
{
	Properties
	{
		[Header(Global)]
		[Toggle(_USE_POM_ON)] _Use_POM("Use_POM", Float) = 0
		_Cutoff("Mask Clip Value", Float) = 1
		[Header(Top Material)]
		_UVTileOffsetTop("UV Tile / Offset (Top)", Vector) = (1,1,0,0)
		[NoScaleOffset]_BaseColorTop("Base Color (Top)", 2D) = "white" {}
		_BaseColorTintTop("Base Color Tint (Top)", Color) = (1,1,1,0)
		[NoScaleOffset]_DETMRAOTop("DET [MRAO] (Top)", 2D) = "white" {}
		_RoughnessMultiplierTop("Roughness Multiplier (Top)", Range(0 , 10)) = 0
		[Toggle(_INVERTROUGHNESSTOP_ON)] _InvertRoughnessTop("Invert Roughness (Top)", Float) = 0
		_AmbientOcclusionMultiplierTop("Ambient Occlusion Multiplier (Top)", Range(0 , 10)) = 1
		[NoScaleOffset]_HeightTop("Height (Top)", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalTop("Normal (Top)", 2D) = "white" {}
		[Toggle(_INVERTNORMALTOP_ON)] _InvertNormalTop("Invert Normal (Top)", Float) = 0
		[NoScaleOffset]_EmissiveTop("Emissive (Top)", 2D) = "black" {}
		_EmissiveMultiplierTop("Emissive Multiplier (Top)", Range(0 , 10)) = 1
		[Header(Parallax Occlusion Mapping TOP)]
		_POMHeightTop("POM Height (Top)", Range(0 , 10)) = 0
		_CurvatureVTop("Curvature V (Top)", Range(0 , 30)) = 0
		_CurvatureUTop("Curvature U (Top)", Range(0 , 100)) = 0
		[Header(Base Material)]
		_UVTileOffsetBase("UV Tile / Offset (Base)", Vector) = (1,1,0,0)
		[NoScaleOffset]_BaseColorAlphaBase("Base Color [Alpha] (Base)", 2D) = "white" {}
		_BaseColorTintBase("Base Color Tint (Base)", Color) = (1,1,1,0)
		[NoScaleOffset]_DETMRAOBase("DET [MRAO] (Base)", 2D) = "white" {}
		_RoughnessMultiplierBase("Roughness Multiplier (Base)", Range( 0 , 10)) = 0
		[Toggle(_INVERT_ROUGHNESSBASE_ON)] _Invert_RoughnessBase("Invert Roughness (Base)", Float) = 0
		_AmbientOcclusionMultiplierBase("Ambient Occlusion Multiplier (Base)", Range( 0 , 10)) = 1
		[NoScaleOffset]_HeightBase("Height (Base)", 2D) = "white" {}
		[NoScaleOffset][Normal]_NormalBase("Normal (Base)", 2D) = "white" {}
		[Toggle(_INVERT_NORMAL_ON)] _Invert_Normal("Invert_Normal", Float) = 0
		[NoScaleOffset]_EmissiveBase("Emissive (Base)", 2D) = "black" {}
		_EmissiveMultiplierBase("Emissive Multiplier (Base)", Range( 0 , 10)) = 1
		[Header(Parallax Occlusion Mapping BASE)]
		_POMHeightBase("POM Height (Base)", Range( 0 , 10)) = 0
		_CurvatureVBase("Curvature V (Base)", Range( 0 , 30)) = 0
		_CurvatureUBase("Curvature U (Base)", Range( 0 , 100)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] _CurvFix("Curvature Bias", Range(0 , 1)) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _INVERTNORMALTOP_ON
		#pragma shader_feature _USE_POM_ON
		#pragma shader_feature _INVERT_NORMAL_ON
		#pragma shader_feature _INVERTROUGHNESSTOP_ON
		#pragma shader_feature _INVERT_ROUGHNESSBASE_ON
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
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _NormalTop;
		uniform float4 _UVTileOffsetTop;
		uniform sampler2D _HeightTop;
		uniform float _POMHeightTop;
		uniform float _CurvFix;
		uniform float _CurvatureUTop;
		uniform float _CurvatureVTop;
		uniform float4 _HeightTop_ST;
		uniform sampler2D _NormalBase;
		uniform float4 _UVTileOffsetBase;
		uniform sampler2D _HeightBase;
		uniform float _POMHeightBase;
		uniform float _CurvatureUBase;
		uniform float _CurvatureVBase;
		uniform float4 _HeightBase_ST;
		uniform float4 _BaseColorTintTop;
		uniform sampler2D _BaseColorTop;
		uniform float4 _BaseColorTintBase;
		uniform sampler2D _BaseColorAlphaBase;
		uniform sampler2D _EmissiveTop;
		uniform float _EmissiveMultiplierTop;
		uniform sampler2D _EmissiveBase;
		uniform float _EmissiveMultiplierBase;
		uniform sampler2D _DETMRAOTop;
		uniform sampler2D _DETMRAOBase;
		uniform float _RoughnessMultiplierTop;
		uniform float _RoughnessMultiplierBase;
		uniform float _AmbientOcclusionMultiplierTop;
		uniform float _AmbientOcclusionMultiplierBase;
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
			float2 appendResult73 = (float2(_UVTileOffsetTop.x , _UVTileOffsetTop.y));
			float2 appendResult72 = (float2(_UVTileOffsetTop.z , _UVTileOffsetTop.w));
			float2 uv_TexCoord76 = i.uv_texcoord * appendResult73 + appendResult72;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float2 appendResult79 = (float2(_CurvatureUTop , _CurvatureVTop));
			float2 OffsetPOM81 = POM( _HeightTop, uv_TexCoord76, ddx(uv_TexCoord76), ddx(uv_TexCoord76), ase_worldNormal, worldViewDir, i.viewDir, 16, 64, _POMHeightTop, 0, _HeightTop_ST.xy, appendResult79, 0.0 );
			float2 myVarName182 = OffsetPOM81;
			#ifdef _USE_POM_ON
				float staticSwitch56 = 1.0;
			#else
				float staticSwitch56 = 0.0;
			#endif
			float2 lerpResult84 = lerp( uv_TexCoord76 , myVarName182 , staticSwitch56);
			float4 tex2DNode91 = tex2D( _NormalTop, lerpResult84, ddx( uv_TexCoord76 ), ddy( uv_TexCoord76 ) );
			#ifdef _INVERTNORMALTOP_ON
				float4 staticSwitch106 = ( float4( float3(1,-1,1) , 0.0 ) * tex2DNode91 );
			#else
				float4 staticSwitch106 = tex2DNode91;
			#endif
			float2 appendResult20 = (float2(_UVTileOffsetBase.x , _UVTileOffsetBase.y));
			float2 appendResult21 = (float2(_UVTileOffsetBase.z , _UVTileOffsetBase.w));
			float2 uv_TexCoord12 = i.uv_texcoord * appendResult20 + appendResult21;
			float2 appendResult63 = (float2(_CurvatureUBase , _CurvatureVBase));
			float2 OffsetPOM7 = POM( _HeightBase, uv_TexCoord12, ddx(uv_TexCoord12), ddx(uv_TexCoord12), ase_worldNormal, worldViewDir, i.viewDir, 16, 64, _POMHeightBase, 0, _HeightBase_ST.xy, appendResult63, 0.0 );
			float2 customUVs15 = OffsetPOM7;
			float2 lerpResult26 = lerp( uv_TexCoord12 , customUVs15 , staticSwitch56);
			float4 tex2DNode46 = tex2D( _NormalBase, lerpResult26, ddx( uv_TexCoord12 ), ddy( uv_TexCoord12 ) );
			#ifdef _INVERT_NORMAL_ON
				float4 staticSwitch48 = ( float4( float3(1,-1,1) , 0.0 ) * tex2DNode46 );
			#else
				float4 staticSwitch48 = tex2DNode46;
			#endif
			float2 uv_HeightBase31 = i.uv_texcoord;
			float4 tex2DNode31 = tex2D( _HeightBase, uv_HeightBase31 );
			float HeightMask127 = saturate(pow(((tex2DNode31.r*1.0)*4)+(1.0*2),i.vertexColor.r));
			float4 lerpResult116 = lerp( staticSwitch106 , staticSwitch48 , HeightMask127);
			o.Normal = lerpResult116.rgb;
			float4 tex2DNode98 = tex2D( _BaseColorTop, lerpResult84 );
			float4 tex2DNode34 = tex2D( _BaseColorAlphaBase, lerpResult26 );
			float4 lerpResult115 = lerp( ( _BaseColorTintTop * tex2DNode98 ) , ( _BaseColorTintBase * tex2DNode34 ) , HeightMask127);
			o.Albedo = lerpResult115.rgb;
			float4 lerpResult120 = lerp( ( tex2D( _EmissiveTop, lerpResult84 ) * _EmissiveMultiplierTop ) , ( tex2D( _EmissiveBase, lerpResult26 ) * _EmissiveMultiplierBase ) , HeightMask127);
			o.Emission = lerpResult120.rgb;
			float4 tex2DNode86 = tex2D( _DETMRAOTop, lerpResult84 );
			float4 tex2DNode38 = tex2D( _DETMRAOBase, lerpResult26 );
			float lerpResult117 = lerp( tex2DNode86.r , tex2DNode38.r , HeightMask127);
			o.Metallic = lerpResult117;
			#ifdef _INVERTROUGHNESSTOP_ON
				float staticSwitch101 = ( 1.0 - tex2DNode86.g );
			#else
				float staticSwitch101 = tex2DNode86.g;
			#endif
			#ifdef _INVERT_ROUGHNESSBASE_ON
				float staticSwitch39 = ( 1.0 - tex2DNode38.g );
			#else
				float staticSwitch39 = tex2DNode38.g;
			#endif
			float lerpResult118 = lerp( ( _RoughnessMultiplierTop * staticSwitch101 ) , ( _RoughnessMultiplierBase * staticSwitch39 ) , HeightMask127);
			o.Smoothness = lerpResult118;
			float lerpResult119 = lerp( ( tex2DNode86.b / _AmbientOcclusionMultiplierTop ) , ( tex2DNode38.b / _AmbientOcclusionMultiplierBase ) , HeightMask127);
			o.Occlusion = lerpResult119;
			o.Alpha = 1;
			float lerpResult126 = lerp( tex2DNode98.a , tex2DNode34.a , HeightMask127);
			clip( lerpResult126 - _Cutoff );
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
				fixed4 color : COLOR0;
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
				o.color = v.color;
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
				surfIN.vertexColor = IN.color;
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
398;239;1889;805;2071.847;-81.20212;2.578167;True;True
Node;AmplifyShaderEditor.CommentaryNode;125;-3071.378,-806.4025;Float;False;2944.898;1472.174;Base Material;9;22;32;53;27;45;51;37;28;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;113;-3121.524,1348.588;Float;False;2944.898;1472.175;TOP MATERIAL;9;68;70;71;83;85;89;92;95;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2928,342.8985;Float;False;918.8176;294.3014;UV Tiling / Offset;6;12;21;20;19;16;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2978.146,2497.889;Float;False;918.8176;294.3014;UV Tiling / Offset;6;88;87;76;73;72;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;69;-2942.049,2579.09;Float;False;Property;_UVTileOffsetTop;UV Tile / Offset (Top);0;0;Create;True;0;0;False;0;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;32;-3021.378,-520.5996;Float;False;1003.903;360.3977;Parallax Occlusion;7;7;13;15;61;62;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-3071.524,1634.391;Float;False;1003.903;360.3977;Parallax Occlusion;7;82;81;80;79;78;75;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;19;-2891.903,424.0992;Float;False;Property;_UVTileOffsetBase;UV Tile / Offset (Base);1;0;Create;True;0;0;False;0;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;72;-2702.847,2671.39;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;71;-3070.313,2042.189;Float;False;280;257.5;Height;1;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2652.7,426.6994;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-2702.847,2581.69;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2967.864,-307.2423;Float;False;Property;_CurvatureUBase;Curvature U (Base);31;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-3020.167,-112.8013;Float;False;280;257.5;Height;1;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3019.011,1848.748;Float;False;Property;_CurvatureUTop;Curvature U (Top);32;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-3022.012,1919.609;Float;False;Property;_CurvatureVTop;Curvature V (Top);30;0;Create;True;0;0;False;0;0;0;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2969.865,-235.3819;Float;False;Property;_CurvatureVBase;Curvature V (Base);29;0;Create;True;0;0;False;0;0;0;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-2652.7,516.3995;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-2609.56,-269.1918;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;-2659.707,1885.799;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;6;-3120.821,849.4921;Float;False;753;278.6001;Toggle Controls;4;5;4;56;58;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-2480.685,437.6002;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;14;-2972.47,-65.6017;Float;True;Property;_HeightBase;Height (Base);16;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2530.832,2592.591;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;77;-3022.617,2089.389;Float;True;Property;_HeightTop;Height (Top);15;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2753.98,-471.1001;Float;False;Property;_POMHeightBase;POM Height (Base);27;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2804.126,1683.891;Float;False;Property;_POMHeightTop;POM Height (Top);26;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;80;-3016.226,1693.694;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;64;-2966.079,-461.297;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-3069.722,1016.191;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-3065.721,909.19;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;81;-2319.708,1805.19;Float;False;0;16;64;10;0.02;0;False;1,1;True;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;7;-2269.562,-349.8011;Float;False;0;16;64;10;0.02;0;False;1,1;True;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-2292.525,1681.392;Float;False;myVarName1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1642.362,-364.086;Float;False;234;206;POM;1;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2242.379,-473.599;Float;False;customUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;83;-1692.507,1790.905;Float;False;234;206;POM;1;84;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;56;-2818.835,898.9941;Float;False;Property;_Use_POM;Use_POM;25;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;85;-1213.823,2333.586;Float;False;987.1981;456.6984;DET [Metallic, Roughness, Ambient Occlusion];10;111;110;105;103;102;101;96;94;90;86;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;84;-1642.507,1840.905;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1163.678,178.5952;Float;False;987.1981;456.6984;DET [Metallic, Roughness, Ambient Occlusion];10;59;38;41;39;42;40;60;44;65;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;26;-1592.362,-314.086;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DdxOpNode;16;-2181.175,438.1998;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DdyOpNode;17;-2181.073,510.398;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;86;-1163.823,2383.586;Float;True;Property;_DETMRAOTop;DET [MRAO] (Top);8;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-1113.678,228.5952;Float;True;Property;_DETMRAOBase;DET [MRAO] (Base);7;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DdxOpNode;87;-2231.321,2593.19;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1207.526,1866.485;Float;False;784.5138;431.4994;Normal;4;106;100;93;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DdyOpNode;88;-2231.22,2665.388;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;51;-1157.381,-288.5056;Float;False;784.5138;431.4994;Normal;4;46;49;50;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;40;-814.4785,271.7944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;49;-985.8654,-238.5057;Float;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;False;0;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;90;-864.6246,2426.785;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;93;-1036.011,1916.485;Float;False;Constant;_Vector2;Vector 2;13;0;Create;True;0;0;False;0;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;91;-1157.526,2067.984;Float;True;Property;_NormalTop;Normal (Top);17;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;37;-1083.86,-756.4025;Float;False;560.1816;451.2016;Base Color;3;34;35;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2679.065,-112.3015;Float;False;663.595;429.7004;Parallax;3;29;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;46;-1107.381,-87.00639;Float;True;Property;_NormalBase;Normal (Base);18;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;92;-1134.005,1398.588;Float;False;560.1816;451.2016;Base Color;3;108;99;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-823.0118,1987.185;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-695.3644,550.7719;Float;False;Property;_EmissiveMultiplierBase;Emissive Multiplier (Base);24;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-658.7186,461.1658;Float;False;Property;_AmbientOcclusionMultiplierBase;Ambient Occlusion Multiplier (Base);14;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1694.033,923.6158;Float;False;Constant;_Float2;Float 2;33;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-630.4785,242.9939;Float;False;Property;_RoughnessMultiplierBase;Roughness Multiplier (Base);10;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;39;-638.4796,324.5944;Float;False;Property;_Invert_RoughnessBase;Invert_Roughness (Base);12;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-1110.995,428.8098;Float;True;Property;_EmissiveBase;Emissive (Base);21;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;103;-817.829,2712.715;Float;False;Property;_EmissiveMultiplierTop;Emissive Multiplier (Top);23;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;67;-1936.756,934.8276;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-772.8657,-167.8057;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;34;-1033.86,-535.201;Float;True;Property;_BaseColorAlphaBase;Base Color [Alpha] (Base);2;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;96;-704.6926,2582.781;Float;False;Property;_AmbientOcclusionMultiplierTop;Ambient Occlusion Multiplier (Top);13;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-680.6247,2397.984;Float;False;Property;_RoughnessMultiplierTop;Roughness Multiplier (Top);9;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;98;-1084.006,1619.79;Float;True;Property;_BaseColorTop;Base Color (Top);3;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;-955.0786,-706.4025;Float;False;Property;_BaseColorTintBase;Base Color Tint (Base);6;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;99;-1005.224,1449.588;Float;False;Property;_BaseColorTintTop;Base Color Tint (Top);5;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;101;-688.6259,2479.585;Float;False;Property;_InvertRoughnessTop;Invert Roughness (Top);11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;31;-2635.77,-46.60162;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;102;-1161.14,2583.8;Float;True;Property;_EmissiveTop;Emissive (Top);22;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-692.678,-532.0024;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;48;-618.2656,-79.40573;Float;False;Property;_Invert_Normal;Invert_Normal;19;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;105;-379.0428,2534.703;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-1705.337,2158.827;Float;False;234;206;Parallax;1;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;-2729.211,2042.689;Float;False;663.595;429.7004;Parallax;3;109;107;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;106;-668.4119,2075.585;Float;False;Property;_InvertNormalTop;Invert Normal (Top);20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-331.2793,257.3936;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1655.192,3.837075;Float;False;234;206;Parallax;1;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;-328.8968,379.7127;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-332.3645,523.7719;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-742.8243,1622.988;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;132;282.2719,917.4864;Float;False;234;206;Metallic;1;117;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;133;283.6574,702.6523;Float;False;234;206;Normal;1;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;283.6801,1131.422;Float;False;234;206;Roughness;1;118;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;129;287.7708,1562.633;Float;False;234;206;Emissive;1;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;130;285.1267,1346.854;Float;False;234;206;AO;1;119;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-381.4253,2412.384;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HeightMapBlendNode;127;-1485.514,908.0983;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-382.5105,2678.762;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;134;281.2145,488.6307;Float;False;234;206;Opacity;1;126;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;135;282.5686,271.6583;Float;False;234;206;Base Color;1;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;118;333.6801,1181.422;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;119;335.1267,1396.854;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;337.7708,1612.633;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;117;332.2719,967.4862;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;115;332.5686,321.6583;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;126;331.2145,538.631;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;116;333.6574,752.6523;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;58;-2844.435,1009.395;Float;False;Property;_UseParallax;Use Parallax;28;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;-1605.192,53.83691;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;112;-1655.337,2208.827;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;29;-2265.975,76.89804;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2517.976,168.8986;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;109;-2568.123,2323.889;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxMappingNode;107;-2316.122,2231.888;Float;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;104;-2685.917,2108.389;Float;True;Property;_TextureSample5;Texture Sample 5;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;973.6823,825.8264;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;M_GT_Blend_Metallic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Masked;1;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;72;0;69;3
WireConnection;72;1;69;4
WireConnection;20;0;19;1
WireConnection;20;1;19;2
WireConnection;73;0;69;1
WireConnection;73;1;69;2
WireConnection;21;0;19;3
WireConnection;21;1;19;4
WireConnection;63;0;61;0
WireConnection;63;1;62;0
WireConnection;79;0;75;0
WireConnection;79;1;74;0
WireConnection;12;0;20;0
WireConnection;12;1;21;0
WireConnection;76;0;73;0
WireConnection;76;1;72;0
WireConnection;81;0;76;0
WireConnection;81;1;77;0
WireConnection;81;2;78;0
WireConnection;81;3;80;0
WireConnection;81;5;79;0
WireConnection;7;0;12;0
WireConnection;7;1;14;0
WireConnection;7;2;13;0
WireConnection;7;3;64;0
WireConnection;7;5;63;0
WireConnection;82;0;81;0
WireConnection;15;0;7;0
WireConnection;56;1;5;0
WireConnection;56;0;4;0
WireConnection;84;0;76;0
WireConnection;84;1;82;0
WireConnection;84;2;56;0
WireConnection;26;0;12;0
WireConnection;26;1;15;0
WireConnection;26;2;56;0
WireConnection;16;0;12;0
WireConnection;17;0;12;0
WireConnection;86;1;84;0
WireConnection;38;1;26;0
WireConnection;87;0;76;0
WireConnection;88;0;76;0
WireConnection;40;0;38;2
WireConnection;90;0;86;2
WireConnection;91;1;84;0
WireConnection;91;3;87;0
WireConnection;91;4;88;0
WireConnection;46;1;26;0
WireConnection;46;3;16;0
WireConnection;46;4;17;0
WireConnection;100;0;93;0
WireConnection;100;1;91;0
WireConnection;39;1;38;2
WireConnection;39;0;40;0
WireConnection;59;1;26;0
WireConnection;50;0;49;0
WireConnection;50;1;46;0
WireConnection;34;1;26;0
WireConnection;98;1;84;0
WireConnection;101;1;86;2
WireConnection;101;0;90;0
WireConnection;31;0;14;0
WireConnection;102;1;84;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;48;1;46;0
WireConnection;48;0;50;0
WireConnection;105;0;86;3
WireConnection;105;1;96;0
WireConnection;106;1;91;0
WireConnection;106;0;100;0
WireConnection;41;0;42;0
WireConnection;41;1;39;0
WireConnection;60;0;38;3
WireConnection;60;1;44;0
WireConnection;65;0;59;0
WireConnection;65;1;66;0
WireConnection;108;0;99;0
WireConnection;108;1;98;0
WireConnection;111;0;94;0
WireConnection;111;1;101;0
WireConnection;127;0;31;1
WireConnection;127;1;128;0
WireConnection;127;2;67;1
WireConnection;110;0;102;0
WireConnection;110;1;103;0
WireConnection;118;0;111;0
WireConnection;118;1;41;0
WireConnection;118;2;127;0
WireConnection;119;0;105;0
WireConnection;119;1;60;0
WireConnection;119;2;127;0
WireConnection;120;0;110;0
WireConnection;120;1;65;0
WireConnection;120;2;127;0
WireConnection;117;0;86;1
WireConnection;117;1;38;1
WireConnection;117;2;127;0
WireConnection;115;0;108;0
WireConnection;115;1;36;0
WireConnection;115;2;127;0
WireConnection;126;0;98;4
WireConnection;126;1;34;4
WireConnection;126;2;127;0
WireConnection;116;0;106;0
WireConnection;116;1;48;0
WireConnection;116;2;127;0
WireConnection;58;1;5;0
WireConnection;58;0;4;0
WireConnection;25;0;12;0
WireConnection;25;1;29;0
WireConnection;25;2;58;0
WireConnection;112;0;76;0
WireConnection;112;1;107;0
WireConnection;112;2;58;0
WireConnection;29;0;12;0
WireConnection;29;1;31;1
WireConnection;29;2;13;0
WireConnection;29;3;30;0
WireConnection;107;0;76;0
WireConnection;107;1;104;1
WireConnection;107;2;78;0
WireConnection;107;3;109;0
WireConnection;104;0;77;0
WireConnection;0;0;115;0
WireConnection;0;1;116;0
WireConnection;0;2;120;0
WireConnection;0;3;117;0
WireConnection;0;4;118;0
WireConnection;0;5;119;0
WireConnection;0;10;126;0
ASEEND*/
//CHKSM=8C26C9FE6A7FB8ADADE4F04B3411815044F97A2E