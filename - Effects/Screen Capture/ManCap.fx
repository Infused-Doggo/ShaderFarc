// #For duplications, rename "ManCap_1" in a sequence (Or however you wanna name it)
// Name must match the fx you want to send it + make a new PMX if needed.

#define		FrameBuffer ManCap_1
#define RT \
	"RenderColorTarget= ManCap_1;" \
	
#define Use_PMX 1
#define PMX "ManCap Control.pmx"
#define ManCap_Count 4

//==============================//
float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass  = "scene";
	string ScriptOrder  = "postprocess";
> = 0.8;
//==============================//

#if Use_PMX
	float  F1 : CONTROLOBJECT < string name = PMX; string item = "- 1";>;
#else
	float F1 = 1;
#endif
float  F2 : CONTROLOBJECT < string name = PMX; string item = "- 2";>;
float  F3 : CONTROLOBJECT < string name = PMX; string item = "- 3";>;
float  F4 : CONTROLOBJECT < string name = PMX; string item = "- 4";>;
float  F5 : CONTROLOBJECT < string name = PMX; string item = "- 5";>;
float  F6 : CONTROLOBJECT < string name = PMX; string item = "- 6";>;
float  F7 : CONTROLOBJECT < string name = PMX; string item = "- 7";>;
float  F8 : CONTROLOBJECT < string name = PMX; string item = "- 8";>;
float  F9 : CONTROLOBJECT < string name = PMX; string item = "- 9";>;
float F10 : CONTROLOBJECT < string name = PMX; string item = "- 10";>;
	
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewportRatio = {1.0f, 1.0f};
	bool AntiAlias = true;
	int MipLevels = 1;
	string Format = "A16B16G16R16F";
>;
sampler2D g_texture_s = sampler_state {
	texture = <ScnMap>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

shared texture2D FrameBuffer : RENDERCOLORTARGET <
	float2 ViewportRatio = {1.0f, 1.0f};
	bool AntiAlias = true;
	string Format = "A8R8G8B8";
>;

#define TS( Tex, Sample ) \
	texture2D Tex : RENDERCOLORTARGET < bool AntiAlias = true; string Format = "A8R8G8B8"; >; \
	sampler2D Sample = sampler_state { \
		texture = <Tex>; \
		FILTER = ANISOTROPIC; \
		ADDRESSU = CLAMP;  ADDRESSV = CLAMP; \
	}; \

	TS( T1, Prev_F1 )
	TS( T2, Prev_F2 )
	TS( T3, Prev_F3 )
	TS( T4, Prev_F4 )
	TS( T5, Prev_F5 )
	TS( T6, Prev_F6 )
	TS( T7, Prev_F7 )
	TS( T8, Prev_F8 )
	TS( T9, Prev_F9 )
	TS( T10, Prev_F10 )

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET < string Format = "D24S8"; >;
float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;
//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 v0 : POSITION0;
  float2 v1 : TEXCOORD0;
};
struct vs_out
{
  float4 o0 : SV_POSITION0;
  float2 o1 : TEXCOORD0;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i)
{
    vs_out o = (vs_out)0;
		
	o.o0 = i.v0;
	o.o1 = i.v1 + ViewportOffset;
    return o;
}
//============================================================================//
// Fragment Shader(s) :
float4 ps_model(vs_out i):COLOR {

	float2 frg_texcoord0 = i.o1;
	return tex2D(g_texture_s, frg_texcoord0);
}

float4 mix(sampler2D Prev, float2 Coord, float4 Mix) {
    float4 S = tex2D(Prev, Coord);
    return lerp(Mix, S, S.w);
}

float4 ps_comp(vs_out i):COLOR {

	float2 frg_texcoord0 = i.o1;
	float4 S1 = tex2D(Prev_F1, frg_texcoord0);
	
	#if ManCap_Count >= 2
		S1 = mix(Prev_F2, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 3
		S1 = mix(Prev_F3, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 4
		S1 = mix(Prev_F4, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 5
		S1 = mix(Prev_F5, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 6
		S1 = mix(Prev_F6, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 7
		S1 = mix(Prev_F7, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 8
		S1 = mix(Prev_F8, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 9
		S1 = mix(Prev_F9, frg_texcoord0, S1);
	#endif
	#if ManCap_Count >= 10
		S1 = mix(Prev_F10, frg_texcoord0, S1);
	#endif
	return S1;
}
//============================================================================//
float4 ClearColor = {0, 0, 0, 0};
float ClearDepth  = 1.0;
//============================================================================//
//  Technique(s)  : 
technique ToneMap <
	string Script = 
		"RenderColorTarget0 = ScnMap;"
        "RenderDepthStencilTarget = DepthBuffer;"
        "ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"ScriptExternal = Color;"
		
	"LoopByCount = F1;"
	"RenderColorTarget=T1;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F1;"
	
	#if ManCap_Count >= 2
	"LoopByCount = F2;"
	"RenderColorTarget=T2;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F2;"
	#endif
	
	#if ManCap_Count >= 3
	"LoopByCount = F3;"
	"RenderColorTarget=T3;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F3;"
	#endif
	
	#if ManCap_Count >= 4
	"LoopByCount = F4;"
	"RenderColorTarget=T4;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F4;"
	#endif
	
	#if ManCap_Count >= 5
	"LoopByCount = F5;"
	"RenderColorTarget=T5;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F5;"
	#endif
	
	#if ManCap_Count >= 6
	"LoopByCount = F6;"
	"RenderColorTarget=T6;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F6;"
	#endif
	
	#if ManCap_Count >= 7
	"LoopByCount = F7;"
	"RenderColorTarget=T7;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F7;"
	#endif
	
	#if ManCap_Count >= 8
	"LoopByCount = F8;"
	"RenderColorTarget=T8;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F8;"
	#endif
	
	#if ManCap_Count >= 9
	"LoopByCount = F9;"
	"RenderColorTarget=T9;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F9;"
	#endif
	
	#if ManCap_Count >= 10
	"LoopByCount = F10;"
	"RenderColorTarget=T10;"
		"ClearSetColor = ClearColor;"  "ClearSetDepth = ClearDepth;"
		"Clear = Color;"  "Clear = Depth;"
		"Pass = Main;"
	"LoopEnd = F10;"
	#endif
		
	RT  "Pass = Max;"
    "RenderColorTarget =;"
		"RenderDepthStencilTarget =;"
		"ClearSetColor = ClearColor;"
		"ClearSetDepth = ClearDepth;"
		"Clear = Color;"
		"Clear = Depth;"
		"Pass = Main;"
	;
>{
	pass Max < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_comp();
	}
	pass Main < string Script= "Draw=Buffer;"; > {
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
	}
};
