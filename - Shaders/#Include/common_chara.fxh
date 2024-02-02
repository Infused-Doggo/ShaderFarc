float set(float A, float B) {
    return 1 + (A * 1.5) * 1 - B;
}

float set2(float A, float B) {
    return (A * 1.5) - (B * 1.5);
}

float R_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Scale +";>;
float R_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Scale -";>;
float R_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Offset +";>;
float R_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="R_Offset -";>;
float G_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Scale +";>;
float G_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Scale -";>;
float G_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Offset +";>;
float G_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="G_Offset -";>;
float B_ScaleA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Scale +";>;
float B_ScaleB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Scale -";>;
float B_OffsetA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Offset +";>;
float B_OffsetB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="B_Offset -";>;

float ExposureA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure +";>;
float ExposureB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure -";>;

float GammaA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma +";>;
float GammaB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma -";>;
float SaturationA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation +";>;
float SaturationB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation -";>;

// floats!
static float exposure = set(ExposureA, ExposureB);
float exposure_rate = 2.5f;
float auto_exposure = 0; // Excluded

static float4 g_exposure = float4(exposure * exposure_rate, 0.0625f, exposure * exposure_rate * 0.5f, auto_exposure ? 1.0f : 0.0f);
static float4 g_fade_color = float4(0.00, 0.00, 0.00, 0.00);
static float4 g_tone_scale = float4(set(R_ScaleA, R_ScaleB), set(G_ScaleA, G_ScaleB), set(B_ScaleA, B_ScaleB), 0.00);
static float4 g_tone_offset = float4(set2(R_OffsetA, R_OffsetB), set2(G_OffsetA, G_OffsetB), set2(B_OffsetA, B_OffsetB), 0.66667);

#define _ramp "- Shaders/#Include/Tonemap.dds"
texture2D RampTex <string ResourceName = _ramp;
	string Format = "A16B16G16R16F";>;
sampler2D g_ramp_s = sampler_state {
	texture = <RampTex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

shared texture2D g_tonemap : RENDERCOLORTARGET <
	string Format = "A16B16G16R16F";>;
sampler2D g_tonemap_s = sampler_state {
	texture = <g_tonemap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

float3 apply_tonemap(float3 color) {

	float3 o0;
	float3 r0;
	float4 r1;
	float4 r2;
	float3 r3;
	float3 r4;
	
  float2 v3 = float2(g_exposure.x, g_exposure.y * g_exposure.x);
  r0 = color;
  r0.y = dot(r0.xyz, float3(0.300000012,0.589999974,0.109999999));
  r0.xz = r0.xz + -r0.yy;
  r1.x = v3.y * r0.y;
  r1.y = 0;
  if(SF_Valid) {
  r1.xy = tex2Dlod(g_tonemap_s, float4(r1.xy, 0, 0)).yx;
  } else {
  r1.xy = tex2Dlod(g_ramp_s, float4(r1.xy, 0, 0)).yx;
  }
  r0.y = v3.x * r1.x;
  r1.xz = r0.yy * r0.xz;
  r0.xz = r0.yy * r0.xz + r1.yy;
  r0.y = dot(r1.xyz, float3(-0.508475006,1,-0.186441004));
  r0.xyz = saturate(r0.xyz * g_tone_scale.xyz + g_tone_offset.xyz);
  r1.x = (0 < g_fade_color.w);
  r1.yzw = g_fade_color.xyz + -r0.xyz;
  r1.yzw = g_fade_color.www * r1.yzw + r0.xyz;
  r2.xy = (g_tone_scale.ww == float2(0,2));
  r3.xyz = g_fade_color.xyz + r0.xyz;
  r4.xyz = g_fade_color.xyz * r0.xyz;
  r2.yzw = r2.yyy ? r3.xyz : r4.xyz;
  r1.yzw = r2.xxx ? r1.yzw : r2.yzw;
  o0.xyz = r1.xxx ? r1.yzw : r0.xyz;
  return o0;
}

float3 apply_chara_color(float3 color) {
    float3 chara_color = lerp(g_chara_color0.rgb, g_chara_color1.rgb, dot(color, _y_coef_601.rgb));
    return apply_tonemap(max(lerp(color, chara_color, g_chara_color1.a), 0.0));
}

float3 apply_fog_color(float3 color, float4 fog_color) {
    return apply_tonemap(lerp(color, fog_color.rgb, fog_color.w));
}

float2 get_chara_shadow(sampler2D tex, float3 normal, float3 texcoord) {
    float2 _tmp0;
    _tmp0.x = tex2D(tex, texcoord.xy).x;
    _tmp0.x = (_tmp0.x - texcoord.z) * g_esm_param.x;
	
	_tmp0.x = HgShadow_GetSelfShadowRate(gl_FragCoord);;
	
    //_tmp0.x = exp2(_tmp0.x * g_material_state_emission.w);
    _tmp0.y = dot(g_light_chara_dir.xyz, normal) + 1.0;
    _tmp0 = clamp(_tmp0, float2(0.0, 0.0), float2(1.0, 1.0));
    _tmp0.y *= _tmp0.y;
    _tmp0.y *= _tmp0.y;
    return float2(_tmp0.x, min(_tmp0.x, _tmp0.y));
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