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

static const float2 g_framebuffer_size = 1 + ViewportOffset;
static float4 g_material = float4(1, 1, 1, saturate(MaterialDiffuse.w) * 1 );
float2 gl_FragCoord;

static float4 g_npr_cloth_spec_color = float4(LightSpecular.xyz * 2, 0.20);
#ifdef PMX_Color
float4 PMX_Specular = Specular;
	static float4 g_material_state_specular = float4(MaterialSpecular.xyz, length(LightAmbient.xyz)* Specular.w);
#else
	static float4 g_material_state_specular = float4(Specular.xyz, length(LightAmbient.xyz) * Specular.w);
#endif

float4 g_sss_param = float4(SSS_Intensity, 0.00, 0.00, 0.50);


#if Fresnel > 8
    static float fresnel_i = 9.0f;
#else
    static float fresnel_i = 7.0f;
#endif

#if Phong_Shading == 1
static float line_light_f = (float)Line_light * (float)(1.0 / 9.0);
#else
static float line_light_f = 0.0f;
#endif
static float fresnel_f = (fresnel_i - 1.0f) * 0.12f * 0.82f;

static float4 g_fresnel_coefficients = float4(fresnel_f, 0.18f, line_light_f, 0.00f);
	

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

#if SHADER_TYPE == 100 || SHADER_TYPE == 101 || SHADER_TYPE == 102 || SHADER_TYPE == 103 || SHADER_TYPE == 104
static float4 g_texcoord_transforms[2] = { float4(
(TX0_RPT + 1 == Color_Offset ? Color_Offset : TX0_RPT).x, 
(TX0_RPT + 1 == Color_Offset ? Color_Offset : TX0_RPT).y, 
-TX0_TRF.x,
-TX0_TRF.y)                               ,float4(
(TX1_RPT + 1 == ALT_Offset ? ALT_Offset : TX1_RPT).x, 
(TX1_RPT + 1 == ALT_Offset ? ALT_Offset : TX1_RPT).y, 
-TX1_TRF.x,
-TX1_TRF.y)};
#else
float4 g_texcoord_transforms[2] = {
float4(1.00, 1.00, 1.00, 1.00),
float4(1.00, 1.00, 1.00, 1.00)};
#endif
	
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

#define M_PI 3.14159265359

#define RAD_TO_DEG ((double)(180.0 / M_PI))
#define DEG_TO_RAD ((double)(M_PI / 180.0))

#define RAD_TO_DEG_FLOAT ((float)(180.0 / M_PI))
#define DEG_TO_RAD_FLOAT ((float)(M_PI / 180.0))

static const float spec_coef = (float)(1.0 / (1.0 - cos(18.0 * DEG_TO_RAD)));
static const float luce_coef = (float)(1.0 / (1.0 - cos(45.0 * DEG_TO_RAD)));

static float4 g_light_env_stage_diffuse = Override ? stage_diffuse : LightAmbient * 1.6;
static float4 g_light_env_stage_specular = (Override ? stage_specular : LightAmbient * 1.6) + (Specular_A * 5) * (1 - Specular_B);
static float4 g_light_env_chara_diffuse = Override ? chara_diffuse : LightAmbient * 1.6;
static float4 g_light_env_chara_ambient = Override ? chara_ambient : LightDiffuse * 1.6;
static float4 g_light_env_chara_specular = (Override ? chara_specular : LightAmbient * 1.6) + (Specular_A * 5) * (1 - Specular_B);

static float4 g_light_stage_dir = float4(Light_Position(lerp(-LightDirection.xyz * float3(1, 1, -1), Stage_Dir, (int)Override)), 1.0);
static float4 g_light_stage_diff = g_light_env_stage_diffuse * IBL_Color[1];
static float4 g_light_stage_spec = g_light_env_stage_specular * IBL_Color[1] * spec_coef;

static float4 g_light_chara_dir = float4(Light_Position(lerp(-LightDirection.xyz, IBL_Dir, (int)Override)), 1.0);
static float4 g_light_chara_spec = g_light_env_chara_specular * IBL_Color[0] * spec_coef;
static float4 g_light_chara_luce = IBL_Color[0] * luce_coef;
static float4 g_light_chara_back = g_light_env_chara_specular * IBL_Color[2] * spec_coef;

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

float4 g_light_face_diff = float4(0.072474, 0.06, 1.00, 1.00);

static float4 g_view_position = float4(CameraPosition.xyz, 1.0);

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