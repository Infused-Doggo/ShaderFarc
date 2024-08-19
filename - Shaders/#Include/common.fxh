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
	float3 p_dx = ddx(frg_position.xyz);
	float3 p_dy = ddy(frg_position.xyz);
	float2 tc_dx = ddx(frg_texcoord.xy);
	float2 tc_dy = ddy(frg_texcoord.xy);
	float direction = tc_dx.x * tc_dy.y - tc_dx.y * tc_dy.x > 0.0f ? 1.0f : -1.0f;
	float3 t = normalize(tc_dy.y * p_dx - tc_dx.y * p_dy) * direction;
	float3 b = normalize( (tc_dy.x * p_dx - tc_dx.x * p_dy) * direction );
	float3 n = normalize(frg_normal.xyz);
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

float4x4 inverse(float4x4 m) {
    float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
    float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
    float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
    float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

    float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

    float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    float idet = 1.0f / det;

    float4x4 ret;

    ret[0][0] = t11 * idet;
    ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
    ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
    ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

    ret[1][0] = t12 * idet;
    ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
    ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
    ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

    ret[2][0] = t13 * idet;
    ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
    ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
    ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

    ret[3][0] = t14 * idet;
    ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
    ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
    ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

    return ret;
}

float3x3 Rotation(float3 in_axis, float s, float c)
{	
	float3x3 in_m1;
    float c_1 = 1.0f - c;
    float3 axis = normalize(in_axis);
    float3 axis_s = axis * s;

    float3 temp;
    temp = axis * axis.x * c_1;
    in_m1[0].x = temp.x + c;
    in_m1[1].x = temp.y - axis_s.z;
    in_m1[2].x = temp.z + axis_s.y;
    temp = axis * axis.y * c_1;
    in_m1[0].y = temp.x + axis_s.z;
    in_m1[1].y = temp.y + c;
    in_m1[2].y = temp.z - axis_s.x;
    temp = axis * axis.z * c_1;
    in_m1[0].z = temp.x - axis_s.y;
    in_m1[1].z = temp.y + axis_s.x;
    in_m1[2].z = temp.z + c;
	return in_m1;
}

float3x3 NormalTransform(float3 light_chara_ibl_direction, float3 light_chara_position)
{	
	float3x3 CUBETransform;
	float flength = length(light_chara_ibl_direction);
    if (flength >= 0.000001f) {
        float3 ibl_direction = light_chara_ibl_direction * (1.0f / flength);

        flength = length(light_chara_position);
        if (flength >= 0.000001f) {
            float3 position = light_chara_position * (1.0f / flength);

            float3 axis = cross(ibl_direction, position);
            flength = length(axis);

            float v52 = dot(ibl_direction, position);
            float angle = abs(atan2(flength, v52));
            if (angle >= 0.01f && angle <= 3.131592653589793f) {
                if (flength != 0.0f)
                    axis *= 1.0f / flength;
				
			CUBETransform = Rotation(axis, sin(-angle), cos(-angle)); } } }
	return CUBETransform;
}

float3 Light_Position(float3 pos_dir)
{
		float flength = length(pos_dir);
        if (flength <= 0.000001)
            pos_dir = float3(0.0f, 1.0f, 0.0f);
        else
            pos_dir *= 1.0f / flength;
        return pos_dir;
}

static float3x3 g_normal_tangent_transforms = NormalTransform( IBL_Direction[0].xyz, lerp(-LightDirection.xyz, IBL_Dir, (int)Override) );