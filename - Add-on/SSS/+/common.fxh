const float4 _red_coef_709 = float4(1.5748, 1.0, 0.0, 1.0);
const float4 _grn_coef_709 = float4(-0.4681, 1.0, -0.1873, 1.0);
const float4 _blu_coef_709 = float4(0.0, 1.0, 1.8556, 1.0);
const float4 _red_coef_601 = float4(1.4022, 1.0, 0.0, 1.0);
const float4 _grn_coef_601 = float4(-0.714486, 1.0, -0.345686, 1.0);
const float4 _blu_coef_601 = float4(0.0, 1.0, 1.771, 1.0);
const float4 _y_coef_601 = float4(0.2989, 0.5866, 0.1145, 1.0);
const float4 _cb_coef_601 = float4(-0.1687747, -0.3312253, 0.5, 1.0);
const float4 _cr_coef_601 = float4(0.5, -0.4183426, -0.0816574, 1.0);

// - - - ° Addition ° - - - //

float3 inv(float3 x) {
    return x * float3(1, 1, -1);
}

float4x4 CTF(float3 frg_position, float4 frg_normal, float4 frg_texcoord) {
	float4x4 Out;
	frg_position = frg_position * float3(1, 1, -1);
	float3 p_dx = ddx(frg_position.xyz);
	float3 p_dy = ddy(frg_position.xyz);
	float2 tc_dx = ddx(frg_texcoord.xy);
	float2 tc_dy = ddy(frg_texcoord.xy);
	float direction = tc_dx.x * tc_dy.y - tc_dx.y * tc_dy.x > 0.0f ? 1.0f : -1.0f;
	float3 t = normalize(tc_dy.y * p_dx - tc_dx.y * p_dy);
	float3 b = normalize( (tc_dy.x * p_dx - tc_dx.x * p_dy) * direction );
	float3 n = normalize(frg_normal);
	float3 x = cross(n, t);
	t = cross(x, n);
	t = normalize(t);
	x = cross(b, n);
	b = cross(n, x);
	b = normalize(b);
	
	Out[0].xyz = t;
	Out[1].xyz = b;
	Out[2] = frg_normal;
	return Out;
}