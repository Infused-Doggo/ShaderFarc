//==============================//
//           GENERAL : 
//==============================//

	float4 g_shader_flags = float4(1.00, 1.00, 1.00, 1.00);
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
float4 g_light_env_reflect_diffuse = float4(0.00, 0.00, 0.00, 1.00);
float4 g_light_env_reflect_ambient = float4(0.00, 0.00, 0.00, 1.00);
float4 g_light_env_reflect_specular = float4(0.00, 0.00, 0.00, 1.00);
float4 g_light_env_proj_diffuse = float4(0.00, 0.00, 0.00, 0.00);
float4 g_light_env_proj_specular = float4(0.00, 0.00, 0.00, 0.00);
float4 g_light_env_proj_position = float4(0.00, 0.00, 1.00, 1.00);
float4 g_light_stage_dir = float4(-0.5946, 0.39273, 0.70158, 0.00);
float4 g_light_stage_diff = float4(1.19026, 1.19026, 1.19026, 0.00);
float4 g_light_stage_spec = float4(24.31912, 24.31912, 24.31912, 0.00);

float4 g_light_face_diff = float4(0.07247, 0.06, 1.00, 1.00);
float4 g_chara_color0 = float4(0.00, 0.00, 0.00, 0.00);
float4 g_chara_color1 = float4(0.00, 0.00, 0.00, 0.00);
float4 g_chara_f_dir = float4(0.00, 1.00, 0.00, 0.00);
float4 g_chara_f_ambient = float4(0.00, 0.00, 0.00, 0.00);
float4 g_chara_f_diffuse = float4(0.00, 0.00, 0.00, 0.00);
float4 g_chara_tc_param = float4(0.00, 0.00, 0.00, 0.00);
float4 g_fog_depth_color = float4(1.00, 1.00, 1.00, 1.00);
float4 g_fog_height_params = float4(0.00, 0.00, 10.00, 0.10);
float4 g_fog_height_color = float4(1.00, 1.00, 1.00, 1.00);
float4 g_fog_bump_params = float4(0.00, 1.00, 1000.00, 0.001);
float4 g_fog_state_params = float4(0.00, 10.00, 1000.00, 0.00101);

float4 g_esm_param = float4(2296.77051, 0.00, 0.00, 0.00);
	
float4 g_self_shadow_receivers[6] = {
	float4(-0.03936, 0.00, -0.4148, 0.51692),
	float4(0.00313, -0.41665, -0.0003, 0.82625),
	float4(-0.05003, -0.00038, 0.00475, 0.49519),
	float4(-0.03936, 0.00, -0.4148, 0.51692),
	float4(0.00313, -0.41665, -0.0003, 0.82625),
	float4(-0.05003, -0.00038, 0.00475, 0.49519)
};

float4 g_shadow_ambient = float4(0.40, 0.40, 0.40, 1.00);
float4 g_shadow_ambient1 = float4(0.60, 0.60, 0.60, 0.00);

float4 g_light_reflect_dir = float4(0.9955, 0.00755, -0.09445, 0.00);
float4 g_clip_plane = float4(0.00, -1.00, 0.00, 0.00);
		

float4 g_view_inverse[3] = {
float4(0.99779, 0.00376, -0.06638, -0.03803),
float4(-1.69966E-08, 0.9984, 0.05653, 1.39072),
float4(0.06649, -0.0564, 0.99619, 3.4827)};

float4 g_projection_view[4] = {
float4(2.72123, 0.00001, 0.18159, -0.52896),
float4(0.01819, 4.84077, -0.273, -5.78068),
float4(-5.53178E-07, 4.71048E-07, 8.30167E-06, 0.04997),
float4(0.06638, -0.05653, -0.99619, 3.55057)};



float4 g_light_projection[4] = {
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00)};
	
float4 g_light_projection_depth[4] = {
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00),
float4(0.00, 0.00, 0.00, 0.00)};

float4 g_foward_z_projection_row2 = float4(0.00, 0.00, -1.00002, -0.10);
	
//////////////////////////////////////////////////////////////////////////////////////////



float4 g_texcoord_transforms[2] = {
float4(1.00, 1.00, 1.00, 1.00),
float4(1.00, 1.00, 1.00, 1.00)};
	
float4 g_blend_color = float4(1.00, 1.00, 1.00, 1.00);
float4 g_offset_color = float4(0.00, 0.00, 0.00, 0.00);
                              //float4 g_material_state_diffuse = float4(1.00, 1.00, 1.00, 1.00);
                              //float4 g_material_state_ambient = float4(1.00, 1.00, 1.00, 1.00);
                              //float4 g_material_state_emission = float4(0.00, 0.00, 0.00, 1.00);
                              //float4 g_material_state_shininess = float4(0.30357, 0.00, 0.00, 1.00);
                              //float4 g_material_state_specular = float4(0.50, 0.50, 0.50, 1.00);
//float4 g_fresnel_coefficients = float4(0.1904, 0.18, 0.555, 0.00);
float4 g_texture_color_coefficients = float4(1.00, 1.00, 1.00, 0.00);
float4 g_texture_color_offset = float4(0.00, 0.00, 0.00, 0.00);

float4 g_tex2D_color_coefficients = float4(1.00, 1.00, 1.00, 0.00);
float4 g_tex2D_color_offset = float4(0.00, 0.00, 0.00, 0.00);

float4 g_tex2D_specular_coefficients = float4(1.00, 1.00, 1.00, 1.00);
float4 g_tex2D_specular_offset = float4(0.00, 0.00, 0.00, 0.00);

float4 g_texture_specular_coefficients = float4(1.00, 1.00, 1.00, 1.00);
float4 g_texture_specular_offset = float4(0.00, 0.00, 0.00, 0.00);
                              //float4 g_shininess = float4(50.00, 0.00, 0.00, 0.00);
#if SHADER_TYPE == 3
float4 g_max_alpha = float4(0.00, 0.00, 0.5, 1.00);
#else
float4 g_max_alpha = float4(0.00, 0.00, 0.5, 0.00);
#endif
float4 g_morph_weight = float4(0.31152, 0.68848, 0.00, 0.00);
//float4 g_sss_param = float4(SSS_Intensity, 0.00, 0.00, 0.50);
float4 g_bump_depth = float4(1.00, 1.00, 0.00, 0.00);
                              //float4 g_intensity = float4(0.00, 1.00, 0.00, 1.00);
float4 g_reflect_uv_scale = float4(0.10, 0.10, 0.00, 0.00);

float4 g_shadow_position[2] = { 
float4(0.00054, 0.83113, 2.70621, 0.00),
float4(0.00054, 0.83113, 2.70621, 0.00)};

float4 g_shadow_direction[2] = {
float4(-0.21109, -0.32136, -0.92313, 0.00),
float4(-0.21109, -0.32136, -0.92313, 0.00)};

float4 g_shadow_param = float4(1.44, 1.00, 0.00, 0.00);
float4 g_skip_flags = uint4(8192, 0, 0, 0);

//#Scene
float4 g_irradiance_r_transforms[4] = {
	float4(0.11767, -0.04712, 0.04544, 0.10816),
	float4(-0.04712, -0.11767, 0.04903, -0.06989),
	float4(0.04544, 0.04903, 0.09179, -0.12506),
	float4(0.10816, -0.06989, -0.12506, 0.93679)
};
	
float4 g_irradiance_g_transforms[4] = {
	float4(0.10915, -0.04458, 0.04502, 0.10643),
	float4(-0.04458, -0.10915, 0.04714, -0.08354),
	float4(0.04502, 0.04714, 0.08321, -0.12376),
	float4(0.10643, -0.08354, -0.12376, 0.95604)
};

float4 g_irradiance_b_transforms[4] = {
    float4(0.07719, -0.035, 0.04343, 0.09989),
    float4(-0.035, -0.07719, 0.04001, -0.13468),
    float4(0.04343, 0.04001, 0.05106, -0.11887),
    float4(0.09989, -0.13468, -0.11887, 1.02817)
};

static float4 g_light_env_stage_diffuse = Override ? stage_diffuse : LightAmbient * 1.6;
static float4 g_light_env_stage_specular = (Override ? stage_specular : LightAmbient * 1.6) + (Specular_A * 5) * (1 - Specular_B);
static float4 g_light_env_chara_diffuse = Override ? chara_diffuse : LightAmbient * 1.6;
static float4 g_light_env_chara_ambient = Override ? chara_ambient : LightDiffuse * 1.6;
static float4 g_light_env_chara_specular = (Override ? chara_specular : LightAmbient * 1.6) + (Specular_A * 5) * (1 - Specular_B);

static float4 g_light_chara_dir = float4(-Light_Direction.xyz * float3(1, 1, -1), 1.0);
static float4 g_light_chara_spec = float4(36.81458, 36.81458, 36.81458, 0.00) * (Override ? chara_specular : LightAmbient * 1.6) + (Specular_A * 5 + 1) * (1 - Specular_B);
static float4 g_light_chara_luce = float4(6.15184, 6.15184, 6.15184, 0.00);
static float4 g_light_chara_back = float4(18.1604, 18.1604, 18.1604, 0.00) * (Override ? chara_specular : LightAmbient * 1.6) + (Specular_A * 5 + 1) * (1 - Specular_B);

static float4 g_view_position = float4(Camera_Position.xyz, 1.0);

//#Batch
static float4 g_material_state_diffuse = PMX_Color ? MaterialDiffuse : Diffuse;
static float4 g_material_state_ambient = PMX_Color ? MaterialAmbient : Ambient;
static float4 g_material_state_emission = PMX_Color ? Emission : Emission;
#if SHADER_TYPE == 5
float4 g_material_state_shininess = float4(10.0f, 0.00, 0.00, 0.00);
#else
static float4 g_material_state_shininess = float4(max((((PMX_Color ? SpecularPower : Shininess) - 16.0f)*(1.0f/112.0f)) + Shininess_A * 1-Shininess_B, 0.0f), 0.00, 0.00, 0.00);
#endif

static float4 g_shininess = float4(max(PMX_Color ? SpecularPower : Shininess, 1.0f), 0.00f, 0.00f, 0.00f);

static float4 g_intensity = float4(Intensity, 1.00, 0.00, 1.00);