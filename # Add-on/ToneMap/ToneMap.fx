////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Adjuster.fx v0.11
//  作成: データP
//
////////////////////////////////////////////////////////////////////////////////////////////////

	float4 g_texcoord_modifier = float4(1, 1, 0, 0);


float set(float A, float B) {
    return 1 + (A * 1.5) * 1 - B;
}

float set2(float A, float B) {
    return (A * 1.5) - (B * 1.5);
}

float R_ScaleA : CONTROLOBJECT <string name="(self)"; string item="R_Scale +";>;
float R_ScaleB : CONTROLOBJECT <string name="(self)"; string item="R_Scale -";>;
float R_OffsetA : CONTROLOBJECT <string name="(self)"; string item="R_Offset +";>;
float R_OffsetB : CONTROLOBJECT <string name="(self)"; string item="R_Offset -";>;

float G_ScaleA : CONTROLOBJECT <string name="(self)"; string item="G_Scale +";>;
float G_ScaleB : CONTROLOBJECT <string name="(self)"; string item="G_Scale -";>;
float G_OffsetA : CONTROLOBJECT <string name="(self)"; string item="G_Offset +";>;
float G_OffsetB : CONTROLOBJECT <string name="(self)"; string item="G_Offset -";>;

float B_ScaleA : CONTROLOBJECT <string name="(self)"; string item="B_Scale +";>;
float B_ScaleB : CONTROLOBJECT <string name="(self)"; string item="B_Scale -";>;
float B_OffsetA : CONTROLOBJECT <string name="(self)"; string item="B_Offset +";>;
float B_OffsetB : CONTROLOBJECT <string name="(self)"; string item="B_Offset -";>;

float ExposureA : CONTROLOBJECT <string name="(self)"; string item="Exposure +";>;
float ExposureB : CONTROLOBJECT <string name="(self)"; string item="Exposure -";>;

float GammaA : CONTROLOBJECT <string name="(self)"; string item="Gamma +";>;
float GammaB : CONTROLOBJECT <string name="(self)"; string item="Gamma -";>;

float SaturationA : CONTROLOBJECT <string name="(self)"; string item="Saturation +";>;
float SaturationB : CONTROLOBJECT <string name="(self)"; string item="Saturation -";>;

// floats!
static float exposure = set(ExposureA, ExposureB);
float exposure_rate = 2.0f;
float auto_exposure = 0; // Excluded

float samples = 0.1;
static float gamma = set(GammaA, GammaB);
float gamma_rate = 1;
	
static float saturate_coeff = set(SaturationA, SaturationB);

static float4 g_exposure = float4(exposure * exposure_rate, 0.0625f, exposure * exposure_rate * 0.5f, auto_exposure ? 1.0f : 0.0f);
	float4 g_fade_color = float4(0.00, 0.00, 0.00, 0.00);
static float4 g_tone_scale = float4(set(R_ScaleA, R_ScaleB), set(G_ScaleA, G_ScaleB), set(B_ScaleA, B_ScaleB), 0.00);
static float4 g_tone_offset = float4(set2(R_OffsetA, R_OffsetB), set2(G_OffsetA, G_OffsetB), set2(B_OffsetA, B_OffsetB), 0.66667);

	float4x4 g_texcoord_transforms = float4x4(
	0.00, 0.00, 0.00, 0.00,
	0.00, 0.00, 0.00, 1.00,
	0.00, 0.00, 0.00, 0.00,
	0.00, 0.00, 0.00, 0.00);

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
sampler2D g_samplers_0__s = sampler_state {
    texture = <OrgScreen>;
    MINFILTER = POINT;
    MAGFILTER = POINT;
    //MIPFILTER = POINT;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

//=== Bloom ===//
sampler2D g_samplers_1__s = sampler_state {
    texture = <OrgScreen>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

texture2D RampTex <string ResourceName = _ramp;>;
sampler2D g_tone_map = sampler_state {
	texture = <RampTex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};


//=== Exposure ===//
texture2D g_textures_3_;
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
  r1.xy = tex2Dlod(g_tone_map, float4(r1.xy, 0, 0)).yx;
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

float4 ps_ramp(vs_out i):COLOR{
	
	float4 v0 = i.o0;
	float4 v1 = i.o1;
	float4 v2 = i.o2;
	float4 v3 = i.o3;
	float4 v4 = i.o4;

	float4 result = 1;
	
	float2 tex_data;
	
	float2 Lut = v1.zz;
	
	float tone_map_scale = (float)(1.0 / samples);
	float gamma_power = gamma * gamma_rate * 1.5f;
	
	tex_data.x = pow(1.0f - exp(-Lut.x * tone_map_scale), gamma_power);
	
	float saturation = tex_data.x * 2.0f - 1.0f;
	
    tex_data.y = tex_data.x * saturate_coeff * (samples / Lut) * (1.0f - saturation);
	
	result.xyz = float3(tex_data.xy, 0);
	return result;
}

float4 ClearColor = {1,1,1,0};
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
	pass Ramp < string Script = "Draw=Buffer;"; >{
		AlphaBlendEnable = false;
		AlphaTestEnable  = false;
		VertexShader = compile vs_3_0 vs_model();
		PixelShader  = compile ps_3_0 ps_ramp();
	}
	
};
