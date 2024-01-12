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