#define SHADER_TYPE 6
// 0 = ITEM
// 1 = SKIN
// 2 = CLOTH
// 3 = TIGHTS
// 4 = HAIR
// 5 = EYEBALL

#define U37 1
#define NPR_DEF 0
#define U26 1

// Texture Maps :
//==================================================//
#define _Normal "+/F_DIVA_UNUSED_S.png"
#define _Specular "+/F_DIVA_UNUSED_S.png"
#define _Env_Map "+/F_DIVA_UNUSED_S.png"
// - - - - - - - - - - - - - - - - - - - -
#define _Translucency "+/F_DIVA_UNUSED_S.png"
#define _Transparency "+/F_DIVA_UNUSED_S.png"

bool PMX_Color = 0;  //Standard MMD material
//====== General: ======//
#define Diffuse float4(1, 1, 1, 1)
#define Ambient float4(1, 1, 1, 1)
#define Specular float4(0.5, 0.5, 0.5, 1)
#define Emission float4(0, 0, 0, 1)
#define Shininess 50
#define Intensity 0
// - - - - - - - - - - -
#define Bump_depth 1

//====== Flags: ======//
#define Normal 1
#define SpecularMap 1
#define Environment 1
#define Transparency 0
#define Translucency 0
#define OverrideIBL 1
// - - - - - - - - - - -
#define NormalAlt 0
#define Color 1
#define ColorAlpha 0
#define ColorL1 0
#define ColorL1Alpha 1
#define ColorL2 0
#define ColorL2Alpha 1
#define ColorL3 0
#define ColorL3Alpha 0

//====== Shader Flags: ======//
#define Vertex_translation 0
// 0 = Default;
// 1 = Envelope;
// 2 = Morphing;
// - - - - - - - - - - -
#define Color_source 0
// 0 = Material Color;
// 1 = Vertex Color;
// 2 = Vertex Morph;
// - - - - - - - - - - -
#define Lambert_Shading 1
#define Phong_Shading 1
#define Per_Pixel_Shading 0
#define Double_Shading 0
// - - - - - - - - - - -
#define Bump_map 2
// 0 = None;
// 1 = Dot;
// 2 = Env;
// - - - - - - - - - - -
#define Fresnel 0
#define Line_light 5
#define Receive_shadow 0
#define Cast_shadow 0
#define Specular_quality  0   // Low - 0 / High - 1
// - - - - - - - - - - -
#define Aniso_Direction 0
// 0 = Normal;
// 1 = U;
// 2 = V;
// 3 = Radial;
	
//====== Blend Flags: ======//
#define Alpha_texture 0
#define Material_texture 0
#define Punch_through 0
#define Double_sided 0
#define Normal_direction 0
// - - - - - - - - - - -
#define Src_blend 4
#define Dst_blend 5
// - - - - - - - - - - -
// 0 = ZERO;
// 1 = ONE;
// 2 = SRCCOLOR;
// 3 = INVSRCCOLOR;
// 4 = SRCALPHA;
// 5 = INVSRCALPHA; 
// 6 = DESTALPHA;
// 7 = INVDESTALPHA;
// 8 = DESTCOLOR;
// 9 = INVDESTCOLOR;
// 10 = SRCALPHASAT;
// - - - - - - - - - - -
#define Blend_operation 0
#define ZBias 0
#define No_fog 0

#include "+/- Settings.fxsub"
#include "+/- Header.fxsub"