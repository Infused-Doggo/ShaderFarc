
//=== Settings: ===//
  // LUT:
  float Lut_Intensity = 1.1;
  #define TONE_MAP_SAT_GAMMA_SAMPLES 32
	
//==============================//
float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass  = "scene";
	string ScriptOrder  = "postprocess";
> = 0.8;
//==============================//
	
float R_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Offset +";>;
float R_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Offset -";>;
float G_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Offset +";>;
float G_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Offset -";>;
float B_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Offset +";>;
float B_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Offset -";>;

float R_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Scale +";>;
float R_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Scale -";>;
float G_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Scale +";>;
float G_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Scale -";>;
float B_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Scale +";>;
float B_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Scale -";>;

float SaturationA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation +";>;
float SaturationB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation -";>;
float ExposureA   : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure +";>;
float ExposureB   : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure -";>;
float GammaA      : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma +";>;
float GammaB      : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma -";>;

float tone_type      : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Tonemap_Type";>;
float auto_exposure  : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Auto_Exposure";>;
float Saturation_Pow : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation_Pow";>;
float Fade_alpha     : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_Alpha";>;
float Fade_A         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_R +";>;
float Fade_B         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_G +";>;
float Fade_C         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_B +";>;
float Override       : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Override";>;

float set(float A, float B) {
    return lerp(1 + (A * 1.5) * 1 - B, A, (int)Override); }

float set2(float A, float B) {
    return lerp((A * 1.5) - (B * 1.5), A, (int)Override); }

static float exposure = set(ExposureA, ExposureB);
static float exposure_rate = Override >= 0 ? 2 : 1;
static float4 g_exposure    = float4(exposure * exposure_rate, 0.0625f, exposure * exposure_rate * 0.5f, auto_exposure ? 1.0f : 0.0f);
static float4 g_fade_color  = float4(Fade_A, Fade_B, Fade_C, Fade_alpha);
static float4 g_tone_scale  = float4(set(R_ScaleA, R_ScaleB), set(G_ScaleA, G_ScaleB), set(B_ScaleA, B_ScaleB), 0.00);
static float4 g_tone_offset = float4(set2(R_OffsetA, R_OffsetB), set2(G_OffsetA, G_OffsetB), set2(B_OffsetA, B_OffsetB), 0.66667);

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

texture2D g_tone_map : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int Width  = 256;
    int Height = 1;
	string Format = "A16B16G16R16F";
>;
sampler2D g_tone_map_s = sampler_state {
	texture = <g_tone_map>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

shared texture2D g_exposure_tex : RENDERCOLORTARGET <
	int Width  = 1;
    int Height = 1;
	string Format = "R16F";
>;
sampler2D g_exposure_s = sampler_state {
	texture = <g_exposure_tex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;

const float4 to_ybr = float4(0.3, 0.59, 0.11, 1.0);
const float4 to_rgb = float4(-0.508475, 1.0, -0.186441, 1.0);
//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 v0 : POSITION0;
  float4 v1 : TEXCOORD0;
  float4 v2 : TEXCOORD1;
  float4 v3 : TEXCOORD2;
  float4 v4 : TEXCOORD3;
};
struct vs_out
{
  float4 o0 : SV_POSITION0;
  float4 o1 : TEXCOORD0;
  float4 o2 : TEXCOORD1;
  float4 o3 : TEXCOORD2;
  float4 o4 : TEXCOORD3;
  float4 exposure2 : TEXCOORD4;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i)
{
    vs_out o = (vs_out)0;
		
  o.o0 = i.v0;
  o.o1 = i.v1 + ViewportOffset.xyxy;
  
  float4 g_texcoord_modifier = float4(1, 1, 0, 0);
	float4 g_texel_size = float4(ViewportSize.xy*0.5*0.5* 0.00001, 320.00*2, 180.00*2);
	float2 r0 = i.v1;
  r0.xy = r0.xy * g_texcoord_modifier.xy + g_texcoord_modifier.zw;
  
  o.o2.xy = r0.xy;
  o.o3.xyzw = g_texel_size.xyxy * float4(-2,0,2,0) + r0.xyxy;
  o.o4.xyzw = g_texel_size.xyxy * float4(0,8,0,-8) + r0.xyxy;
  
	float exposure = tex2Dlod(g_exposure_s, (0.0)).x;
    exposure = (exp2(exposure * -1.8) * 2.9 + 0.4) * g_exposure.z;

    float4 ex_col;
    ex_col.x = g_exposure.w > 0.0 ? exposure : g_exposure.x;
    ex_col.y = ex_col.x * g_exposure.y;
    ex_col.z = 1.0;

        ex_col.w = 1.0;

    o.exposure2 = ex_col;
  
    return o;
}
//============================================================================//
// Fragment Shader(s) :
float4 ps_model(vs_out i):COLOR{

	bool TONE_MAP_1 = tone_type >= 0.33;
	bool TONE_MAP_2 = tone_type >= 0.66;

	float4 frg_texcoord0 = i.o1;
	float4 frg_exposure = i.exposure2;
	float4 result;
  
    float4 sum = tex2D(g_texture_s, frg_texcoord0.xy);
    float4 col = 0;
    sum.rgb = lerp(sum.rgb, sum.rgb + col.rgb, float(frg_exposure.z > 0.0));  
	
	float3 res;
	if (TONE_MAP_2) { // #if TONE_MAP_2_DEF
        res = min(sum.rgb * 0.25 * frg_exposure.x, 0.80);
    }
    else if (TONE_MAP_1) { // #elif TONE_MAP_1_DEF
        res = min(sum.rgb * 0.48 * frg_exposure.x, 0.96);
    }
    else { // #else
        float3 ybr;
        ybr.y = dot(sum.rgb, to_ybr.xyz);
        ybr.xz = sum.xz - ybr.y;
        col = tex2D(g_tone_map_s, float2(ybr.y * frg_exposure.y, 0.0)).xxxy;
        col.xz = col.w * frg_exposure.x * ybr.xz;
        res.rb = col.xz + col.y;
        res.g = dot(col.rgb, to_rgb.xyz);
    } // #endif
	
	result.a = sum.a;

    res = clamp(res * g_tone_scale.rgb + g_tone_offset.rgb, (0.0), (1.0));

    if (1) { // #if SCENE_FADE_DEF
        const float blend = g_tone_scale.w;
        bool3 cc = (blend) == float3(0.0, 1.0, 2.0);
        res = lerp(res, lerp(res, g_fade_color.rgb, g_fade_color.a), float(cc.x));
        res = lerp(res, res * g_fade_color.rgb, float(cc.y));
        res = lerp(res, res + g_fade_color.rgb, float(cc.z));
    } // #endif
    result.rgb = res;
	return result;
}

float4 ps_ramp(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
	UV = UV/1.2;
	
	static float gamma_rate = set(GammaA, GammaB);
    static float saturate_coeff = set(SaturationA, SaturationB);
	
	const float tone_map_scale = (float)(UV.x / (double)TONE_MAP_SAT_GAMMA_SAMPLES);
    const int tone_map_size = 16 * TONE_MAP_SAT_GAMMA_SAMPLES;
	
	float2 tex_data[16 * TONE_MAP_SAT_GAMMA_SAMPLES];
    float gamma_power = 0.8333 * gamma_rate * 1.5f;
    
    tex_data[0].x = 0.0f;
    tex_data[0].y = 0.0f;
	for (int i = 1; i < tone_map_size; i++) {
		float gamma = pow(1.0f - exp((float)-i * tone_map_scale), gamma_power);
		tex_data[0].x = gamma;
	}
	
	int saturate_power = (int)(Saturation_Pow * 7);
	saturate_power = Saturation_Pow == 0 ? 1 : saturate_power;
	float saturation = tex_data[0].x * 2.0f - 1.0f;
	for (int j = 0; j < saturate_power; j++) {
		saturation *= saturation;
		saturation *= saturation;
		saturation *= saturation;
		saturation *= saturation;
    }
	
	tex_data[0].y = tex_data[0].x * saturate_coeff * ((float)TONE_MAP_SAT_GAMMA_SAMPLES / UV.x / 512) * (1.0f - saturation);
	return tex_data[0].xyxy;
}
//============================================================================//
float4 ClearColor = {0.75, 0.75, 0.75, 0};
float ClearDepth  = 1.0;
//============================================================================//
//  Technique(s)  : 
technique ToneMap <
	string Script = 
		"RenderColorTarget0=g_tone_map;"
		"RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=Ramp;"
		
		"RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"
			
		"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Main;"
	;
>{
	pass Ramp < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_ramp();
	}
	pass Main < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
	}
};
