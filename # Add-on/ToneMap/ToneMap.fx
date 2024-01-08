////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Adjuster.fx v0.11
//  作成: データP
//
////////////////////////////////////////////////////////////////////////////////////////////////

	float4 g_texcoord_modifier = float4(1, 1, 0, 0);
	float4 g_exposure = float4(2.00, 0.0625, 1.00, 1.00);
	float4 g_fade_color = float4(0.00, 0.00, 0.00, 0.00);
	float4 g_tone_scale = float4(1.00, 1.00, 1.00, 0.00);
	float4 g_tone_offset = float4(0.00, 0.00, 0.00, 0.66667);

	float4x4 g_texcoord_transforms = float4x4(
	0.00, 0.00, 0.00, 0.00,
	0.00, 0.00, 0.00, 1.00,
	0.00, 0.00, 0.00, 0.00,
	0.00, 0.00, 0.00, 0.00);

#define _basetex "Scene.dds"
#define _bloom "Bloom.dds"
#define _exposure "Exposure.dds"
#define _ramp "Ramp.dds"

#define cmp -

// ポストエフェクト宣言
float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// MMD本来のsamplerを上書きしないための記述です。削除不可。
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

float Tr : CONTROLOBJECT <string name="(self)"; string item="合成弱め";>;
float BrightPlus : CONTROLOBJECT <string name="(self)"; string item="明るく";>;
float BrightNeg : CONTROLOBJECT <string name="(self)"; string item="暗く";>;
float SharpPlus : CONTROLOBJECT <string name="(self)"; string item="くっきり";>;
float SharpNeg : CONTROLOBJECT <string name="(self)"; string item="ぼんやり";>;
float StrengthPlus : CONTROLOBJECT <string name="(self)"; string item="濃く";>;
float StrengthNeg : CONTROLOBJECT <string name="(self)"; string item="薄く";>;
float2 ViewportSize : VIEWPORTPIXELSIZE;

static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;

// 処理用テクスチャ
texture OrgScreen : RENDERCOLORTARGET <
	string Format = "A16B16G16R16F";
	float2 ViewPortRatio = {1,1};
>;
sampler OrgSampler = sampler_state {
	texture = <OrgScreen>;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

texture OrgSizeDepth : RENDERDEPTHSTENCILTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	string Format = "D24S8";
>;

//=== Scene ===//
texture2D g_textures_0_ <string ResourceName = _basetex;
string Format = "A16B16G16R16F";>;
sampler2D g_samplers_0__s = sampler_state {
    texture = <OrgScreen>;
    MINFILTER = POINT;
    MAGFILTER = POINT;
    //MIPFILTER = POINT;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

//=== Bloom ===//
shared texture2D g_Combine <string ResourceName = _bloom;
string Format = "A16B16G16R16F";>;
sampler2D g_samplers_1__s = sampler_state {
    texture = <OrgScreen>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

//=== Exposure ===//
texture2D g_textures_2_ <string ResourceName = _ramp;
string Format = "G16R16F";>;
sampler2D g_samplers_2__s = sampler_state {
    texture = <g_textures_2_>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    //MIPFILTER = POINT;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};


//=== Exposure ===//
texture2D g_textures_3_ <string ResourceName = _exposure;>;
sampler2D g_samplers_3__s = sampler_state {
    texture = <g_textures_3_>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = POINT;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

//=== Exposure ===//
texture2D g_textures_4_;
sampler2D g_samplers_4__s = sampler_state {
    texture = <g_textures_4_>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

//=== Exposure ===//
texture2D g_textures_5_;
sampler2D g_samplers_5__s = sampler_state {
    texture = <g_textures_5_>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

//=== Exposure ===//
texture2D g_textures_7_;
sampler2D g_samplers_7__s = sampler_state {
    texture = <g_textures_7_>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};
//============================================================================//
//  Base Structure  :
struct vs_in
{
    float4 v0 : POSITION0;
	float4 v1 : TEXCOORD0;
};
struct vs_out
{
	float4 o0 : SV_POSITION0;
	float4 o1 : TEXCOORD0;
	float4 o2 : TEXCOORD1;
	float4 o3 : TEXCOORD2;
	float4 o4 : TEXCOORD3;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i)
{
    vs_out o = (vs_out)0;
	
	float4 r0 = 1;
	float4 r1 = 1;
	float4 r2 = 1;
	float4 r3 = 1;
	float4 r4 = 1;
	float4 r5 = 1;
	float4 r6 = 1;
	float4 r7 = 1;
	float4 r8 = 1;
	float4 r9 = 1;
	
	float4 v0 = i.v0;
	float4 v1 = i.v1;
	
	//o0.xy = r0.xy;
	//o0.zw = float2(0,1);
	
	o.o0 = v0;
	
  r0.xy = v1 + ViewportOffset.xy;
  
  r0.zw = r0.xy * float2(1,1);
  o.o1.zw = r0.zw;
  o.o4.xy = g_texcoord_transforms[1].ww * r0.zw;
  o.o1.xy = r0.xy * g_texcoord_modifier.xy + g_texcoord_modifier.zw;
	r0.z = dot(g_texcoord_transforms[0].xy, r0.xy);
	o.o2.x = g_texcoord_transforms[0].z + r0.z;
	r0.z = dot(g_texcoord_transforms[1].xy, r0.xy);
	o.o2.y = g_texcoord_transforms[1].z + r0.z;
	r0.z = dot(g_texcoord_transforms[2].xy, r0.xy);
	r0.x = dot(g_texcoord_transforms[3].xy, r0.xy);
	o.o2.w = g_texcoord_transforms[3].z + r0.x;
	o.o2.z = g_texcoord_transforms[2].z + r0.z;
	r0.x = 1.00586;
	r0.x = 1.79999995 * r0.x;
	r0.x = exp2(-r0.x);
	r0.x = r0.x * 2.9000001 + 0.400000006;
	r0.x = g_exposure.z * r0.x;
	r0.y = cmp(0 < g_exposure.w);
	r0.x = r0.y ? r0.x : g_exposure.x;
	o.o3.y = g_exposure.y * r0.x;
	o.o3.x = r0.x;
	o.o3.z = 1;
	o.o3.w = g_exposure.w;
	o.o4.z = g_texcoord_transforms[3].w;
    return o;
}

//============================================================================//
// Fragment Shader(s) :
float4 ps_model(vs_out i):COLOR{

	float4 v0 = i.o0;
	float4 v1 = i.o1;
	float4 v2 = i.o2;
	float4 v3 = i.o3;
	float4 v4 = i.o4;

	float4 o0 = 1;
	float4 r0 = 1;
	float4 r1 = 1;
	float4 r2 = 1;
	float4 r3 = 1;
	float4 r4 = 1;
	
	r0.xyzw = tex2D(g_samplers_0__s, v1.xy).xyzw;
	r1.xyz = saturate(tex2Dlod(g_samplers_1__s, float4(v1.zw, 0, 1)).xyz-2.6);
	r1.w = cmp(0 < v3.z);
	r1.xyz = r1.xyz + r0.xyz;
	r0.xyz = r1.www ? r1.xyz : r0.xyz;
	r1.x = cmp(0 < g_texcoord_transforms[0].w);
  if (r1.x != 0) {
    r1.xyz = tex2D(g_samplers_4__s, v2.xy).xyz;
    r1.xyz = r1.xyz * r1.xyz;
    r0.xyz = r1.xyz * g_texcoord_transforms[0].www + r0.xyz;
  }
  r1.x = cmp(0 < g_texcoord_transforms[2].w);
  if (r1.x != 0) {
    r1.xyz = tex2D(g_samplers_5__s, v2.zw).xyz;
    r1.xyz = r1.xyz * r1.xyz;
    r0.xyz = r1.xyz * g_texcoord_transforms[2].www + r0.xyz;
  }
  r1.x = cmp(0 < v4.z);
  if (r1.x != 0) {
    r1.xyz = tex2D(g_samplers_7__s, v4.xy).xyz;
    r0.xyz = r1.xyz + r0.xyz;
  }
  r0.y = dot(r0.xyz, float3(0.300000012,0.589999974,0.109999999));
  r0.xz = r0.xz + -r0.yy;
  r1.x = v3.y * r0.y;
  r1.y = 0;
  r1.xy = tex2Dlod(g_samplers_2__s, float4(r1.xy, 0, 0)).yx;
  r0.y = v3.x * r1.x;
  r1.xz = r0.yy * r0.xz;
  r0.xz = r0.yy * r0.xz + r1.yy;
  r0.y = dot(r1.xyz, float3(-0.508475006,1,-0.186441004));
  r0.xyz = saturate(r0.xyz * g_tone_scale.xyz + g_tone_offset.xyz);
  r1.x = cmp(0 < g_fade_color.w);
  r1.yzw = g_fade_color.xyz + -r0.xyz;
  r1.yzw = g_fade_color.www * r1.yzw + r0.xyz;
  r2.xy = cmp(g_tone_scale.ww == float2(0,2));
  r3.xyz = g_fade_color.xyz + r0.xyz;
  r4.xyz = g_fade_color.xyz * r0.xyz;
  r2.yzw = r2.yyy ? r3.xyz : r4.xyz;
  r1.yzw = r2.xxx ? r1.yzw : r2.yzw;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  o0.w = r0.w;
	return o0;
}

float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1;

technique PostEffectTec <
	string Script =
		"RenderColorTarget=OrgScreen;"
		"RenderDepthStencilTarget=OrgSizeDepth;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"

		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=Effect;"
	;
>{
	pass Effect < string Script = "Draw=Buffer;"; >{
		AlphaBlendEnable = false;
		AlphaTestEnable  = false;
		VertexShader = compile vs_3_0 vs_model();
		PixelShader  = compile ps_3_0 ps_model();
	}
};
