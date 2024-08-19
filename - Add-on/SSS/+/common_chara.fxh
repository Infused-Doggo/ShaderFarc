float Override_TM : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Override";>;

float set(float A, float B) {
    return lerp(1 + (A * 1.5) * 1 - B, A, (int)Override_TM);
}

float set2(float A, float B) {
    return lerp((A * 1.5) - (B * 1.5), A, (int)Override_TM);
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
float exposure_rate = 1.0f;
float auto_exposure = 0; // Excluded

static float4 g_exposure = float4(exposure * exposure_rate, 0.0625f, exposure * exposure_rate * 0.5f, auto_exposure ? 1.0f : 0.0f);
static float4 g_fade_color = float4(0.00, 0.00, 0.00, 0.00);
static float4 g_tone_scale = float4(set(R_ScaleA, R_ScaleB), set(G_ScaleA, G_ScaleB), set(B_ScaleA, B_ScaleB), 0.00);
static float4 g_tone_offset = float4(set2(R_OffsetA, R_OffsetB), set2(G_OffsetA, G_OffsetB), set2(B_OffsetA, B_OffsetB), 0.66667);


float3 apply_tonemap(float3 color) {

  return color;
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