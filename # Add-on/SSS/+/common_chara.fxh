float3 apply_chara_color(float3 color) {
    float3 chara_color = lerp(g_chara_color0.rgb, g_chara_color1.rgb, dot(color, _y_coef_601.rgb));
    return max(lerp(color, chara_color, g_chara_color1.a), 0.0);
}

float3 apply_fog_color(float3 color, float4 fog_color) {
    return lerp(color, fog_color.rgb, fog_color.w);
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