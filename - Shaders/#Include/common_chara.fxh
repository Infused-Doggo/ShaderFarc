
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

float tone_type : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Tonemap_Type";>;
float auto_exposure  : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Auto_Exposure";>;
float Saturation_Pow : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation_Pow";>;
float Fade_alpha     : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_Alpha";>;
float Fade_A         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_R +";>;
float Fade_B         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_G +";>;
float Fade_C         : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Fade_B +";>;
float Override_TM    : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Override";>;

float set(float A, float B) {
    return lerp(1 + (A * 1.5) * 1 - B, A, (int)Override_TM);
}

float set2(float A, float B) {
    return lerp((A * 1.5) - (B * 1.5), A, (int)Override_TM);
}

static float exposure = set(ExposureA, ExposureB);
static float exposure_rate = 1.5;
static float4 g_exposure    = float4(exposure * exposure_rate, 0.0625f, exposure * exposure_rate * 0.5f, auto_exposure ? 1.0f : 0.0f);
static float4 g_fade_color  = float4(Fade_A, Fade_B, Fade_C, Fade_alpha);
static float4 g_tone_scale  = float4(set(R_ScaleA, R_ScaleB), set(G_ScaleA, G_ScaleB), set(B_ScaleA, B_ScaleB), 0.00);
static float4 g_tone_offset = float4(set2(R_OffsetA, R_OffsetB), set2(G_OffsetA, G_OffsetB), set2(B_OffsetA, B_OffsetB), 0.66667);

texture2D RampTex <string ResourceName = "- Shaders/#Include/Tonemap.dds";
	int Width  = 256;  int Height = 1;
	string Format = "A16B16G16R16F"; >;
sampler2D g_ramp_s = sampler_state {
	texture = <RampTex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

shared texture2D g_tonemap : RENDERCOLORTARGET <
	string Format = "A16B16G16R16F";>;
sampler2D g_tone_map_s = sampler_state {
	texture = <g_tonemap>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

bool TM_x : CONTROLOBJECT < string name = "ToneMap.x"; >;
bool EX_x : CONTROLOBJECT < string name = "Bloom.x"; >;
const float4 to_ybr = float4(0.3, 0.59, 0.11, 1.0);
const float4 to_rgb = float4(-0.508475, 1.0, -0.186441, 1.0);

float3 apply_tonemap(float3 color) {

	g_tone_scale.xyz = g_tone_scale.xyz * 1.1;
	g_tone_offset.xyz = g_tone_offset.xyz * lerp(1.1, -1.1, (int)Override_TM);
	float2 frg_exposure = float2(g_exposure.x, g_exposure.y * g_exposure.x);
	
	float4 col = 0;
    float3 sum = color;  
	
	float3 res;
	if (tone_type >= 0.66) { // #if TONE_MAP_2_DEF
        res = min(sum.rgb * 0.25 * frg_exposure.x, 0.80);
    }
    else if (tone_type >= 0.33) { // #elif TONE_MAP_1_DEF
        res = min(sum.rgb * 0.48 * frg_exposure.x, 0.96);
    }
    else { // #else
        float3 ybr;
        ybr.y = dot(sum.rgb, to_ybr.xyz);
        ybr.xz = sum.xz - ybr.y;
		if (SF_Valid) {
			col = tex2D(g_tone_map_s, float2(ybr.y * frg_exposure.y, 0.0)).xxxy;
		} else {
			col = tex2Dlod(g_ramp_s, float4(ybr.y * frg_exposure.y, 0.0, 0, 0)).xxxy*0.98;
			col.w = saturate( pow(col.w, 0.92)*1.5*1-col.y*0.23 )*set(SaturationA, SaturationB);
		}
        col.xz = col.w * frg_exposure.x * ybr.xz;
        res.rb = col.xz + col.y;
        res.g = dot(col.rgb, to_rgb.xyz);
    } // #endif
	
    res = clamp(res * g_tone_scale.rgb + g_tone_offset.rgb, (0.0), (1.0));

        const float blend = g_tone_scale.w;
        bool3 cc = (blend) == float3(0.0, 1.0, 2.0);
        res = lerp(res, lerp(res, g_fade_color.rgb, g_fade_color.a), float(cc.x));
        res = lerp(res, res * g_fade_color.rgb, float(cc.y));
        res = lerp(res, res + g_fade_color.rgb, float(cc.z));
  
	if (TM_x || EX_x) {
		res = color;
	}
	return res;
}

float3 apply_chara_color(float3 color) {
    float3 chara_color = lerp(g_chara_color0.rgb, g_chara_color1.rgb, dot(color, _y_coef_601.rgb));
    return apply_tonemap(max(lerp(color, chara_color, g_chara_color1.a), 0.0));
}

float3 apply_fog_color(float3 color, float4 fog_color) {
    return apply_tonemap(lerp(color, fog_color.rgb, fog_color.w));
}

float3 normalizedot(float3 x, float y) {
    return sqrt(dot(x, x))/y;
}

float2 get_chara_shadow(sampler2D tex, float3 normal, float3 texcoord) {
    float2 _tmp0;
    _tmp0.x = tex2D(tex, texcoord.xy).x;
    _tmp0.x = (_tmp0.x - texcoord.z) * g_esm_param.x;
	
	_tmp0.x = HgShadow_GetSelfShadowRate(gl_FragCoord);
	
    //_tmp0.x = exp2(_tmp0.x * g_material_state_emission.w);
    _tmp0.y = dot(g_light_chara_dir.xyz, normal) + 1.0;
    _tmp0 = clamp(_tmp0, float2(0.0, 0.0), float2(1.0, 1.0));
    _tmp0.y *= _tmp0.y;
    _tmp0.y *= _tmp0.y;
    return float2(_tmp0.x, min(_tmp0.x, _tmp0.y));
}

float4 get_stage_shadow(sampler2D shadow0_tex, sampler2D shadow1_tex,
    sampler2D shadow_depth1_tex, float3 texcoord_shadow0, float3 texcoord_shadow1, bool shadow1) {

    return 1;
}

float3 get_ibl_diffuse(samplerCUBE tex, float3 ray, float lc) {
    float3 col0 = texCUBElod(tex, float4(ray, 0.0)).rgb;
    float3 col1 = texCUBElod(tex, float4(ray, 1.0)).rgb;
    return lerp(col1, col0, lc);
}

float3 get_tone_curve(float3 normal) {
    float tonecurve = dot(normal, g_chara_f_dir.xyz) * 0.5 + 0.5;
    tonecurve = clamp((tonecurve - g_chara_tc_param.x) * g_chara_tc_param.y, 0.0, 1.0);
    return lerp(g_chara_f_ambient.rgb, g_chara_f_diffuse.rgb, tonecurve) * g_chara_tc_param.z;
}