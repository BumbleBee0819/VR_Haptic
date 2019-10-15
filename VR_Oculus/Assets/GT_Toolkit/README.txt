GAMETEXTURES SHADE - Unity 2018
===============================================
SHADE is a collection of pre-defined materials
for Metallic and Specular workflows
-----------------------------------------------


SHADE - Unity consists of four basic shaders:

M_GT_Basic
M_GT_Basic_Packed
M_GT_Blend
M_GT_Decal


===============================================
M_GT_Basic
===============================================
Basic shader template for any type of asset.
Geared toward entry-level users.
-----------------------------------------------

[METALLIC]
Base Color (tex)
Base Color Tint (color)
Metallic (tex)
Roughness (tex)
Invert Roughness (bool)
Roughness Multiplier (scalar)

[SPECULAR]
Albedo (tex)
Albedo Color Tint (color)
Specular Color (tex)
Glossiness (tex)
Invert Glossiness (bool)
Glossiness Multiplier (scalar)

[GLOBAL]
UV Tile / Offset (v4): X/Y = UV, Z/W = OFFSET
Ambient Occlusion (tex)
Ambient Occlusion Multiplier (scalar)
Height (tex)
Normal (tex)
Invert Normal (bool)
Emissive (tex)
Emissive Multiplier (scalar)
Opacity (tex)
Mask Clip Value(scalar)

[POM]
Use Pom (bool)
POM Height (scalar)
Curvature V (scalar)
Curvature U (scalar)

===============================================
M_GT_Basic Packed
===============================================
Basic shader template for any type of asset.
Geared toward entry-level users.
Optimized with packed textures.
-----------------------------------------------

[METALLIC]
Base Color [Alpha] (tex)
Base Color Tint (color)
Mask Clip Value (scalar)
DET [MRAO] (tex): Packed texture map - [Red: Metallic, Green: Roughness, Blue: Ambient Occlusion]
Roughness Multiplier (scalar)
Invert Roughness (bool)

[SPECULAR]
Albedo [Alpha] (tex)
Albedo Color Tint (color)
Mask Clip Value (scalar)
Specular Color [Glossiness] (tex)
Glossiness Multiplier (scalar)
Invert Glossiness (bool)

[GLOBAL]
UV Tile / Offset (v4): X/Y = UV, Z/W = OFFSET
Ambient Occlusion Multiplier (scalar)
Height (tex)
Normal (tex)
Invert Normal (bool)
Emissive (tex)
Emissive Multiplier (scalar)

[POM]
Use Pom (bool)
POM Height (scalar)
Curvature V (scalar)
Curvature U (scalar)

===============================================
M_GT_Blend
===============================================
Basic blend material by vertex color
Blends Top material with Base material using height map
-----------------------------------------------

[GLOBAL]
Use POM (bool)
Mask Clip Value (scalar)

[METALLIC / TOP & BASE Materials]
UV Tile / Offset (v4): X/Y = UV, Z/W = OFFSET
Base Color [Alpha] (tex)
Base Color Tint (color)
Mask Clip Value (scalar)
DET [MRAO] (tex): Packed texture map - [Red: Metallic, Green: Roughness, Blue: Ambient Occlusion]
Roughness Multiplier (scalar)
Invert Roughness (bool)

[SPECULAR / TOP & BASE Materials]
UV Tile / Offset (v4): X/Y = UV, Z/W = OFFSET
Albedo [Alpha] (tex)
Albedo Color Tint (color)
Mask Clip Value (scalar)
Specular Color [Glossiness] (tex)
Glossiness Multiplier (scalar)
Invert Glossiness (bool)

[POM]
Use Pom (bool)
POM Height (scalar)
Curvature V (scalar)
Curvature U (scalar)

===============================================
M_GT_Decal
===============================================
Decal material to use with Unity Projectors or 
any other third-party decal system
-----------------------------------------------

[METALLIC]
Base Color [Alpha] (tex)
Base Color Tint (color)
Mask Clip Value (scalar)
DET [MRAO] (tex): Packed texture map - [Red: Metallic, Green: Roughness, Blue: Ambient Occlusion]
Roughness Multiplier (scalar)
Invert Roughness (bool)

[SPECULAR]
Albedo [Alpha] (tex)
Albedo Color Tint (color)
Mask Clip Value (scalar)
Specular Color [Glossiness] (tex)
Glossiness Multiplier (scalar)
Invert Glossiness (bool)

[GLOBAL]
UV Tile / Offset (v4): X/Y = UV, Z/W = OFFSET
Ambient Occlusion Multiplier (scalar)
Height (tex)
Normal (tex)
Invert Normal (bool)
Emissive (tex)
Emissive Multiplier (scalar)

[DECAL CONTROLS]
Use Radial Gradient + Height (bool)
Opacity Edge Threshold (scalar)
Gradient Radius (scalar)
Gradient Density (scalar)
Height Clamp (scalar)

[POM]
Use Pom (bool)
POM Height (scalar)
Curvature V (scalar)
Curvature U (scalar)