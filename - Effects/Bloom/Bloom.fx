
//==============================//
float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;
//==============================//

// オリジナルの描画結果を記録するためのレンダーターゲット
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewportRatio = {1.0f, 1.0f};
	bool AntiAlias = true;
	int MipLevels = 1;
	string Format = "A16B16G16R16F";
>;

sampler2D ScnSamp = sampler_state {
	texture = <ScnMap>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

sampler2D g_texture_s = sampler_state {
	texture = <ScnMap>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

#define TEXFORMAT "A16B16G16R16F"
#define LINEAR_FILTER_MODE	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
#define ADDRESSING_MODE		AddressU = CLAMP; AddressV = CLAMP;

//  Textures / Samplers  :
#define RT( Tex, Sample, W, H) \
	texture2D Tex : RENDERCOLORTARGET < \
		bool AntiAlias = true; \
		int MipLevels = 1; \
		int Width  = W; \
		int Height = H; \
		string Format = TEXFORMAT; \
	>; \
	sampler2D Sample = sampler_state { \
		texture = <Tex>; \
		LINEAR_FILTER_MODE	ADDRESSING_MODE \
	}; \
	
texture2D g_reduce_1 : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int MipLevels = 1;
	float2 ViewportRatio = {0.5f, 0.5f};
	string Format = TEXFORMAT;
>;
sampler2D g_reduce_1_s = sampler_state {
	texture = <g_reduce_1>;
	LINEAR_FILTER_MODE	ADDRESSING_MODE
};
RT( g_reduce_2, g_reduce_2_s, 256, 144)
RT( g_reduce_3, g_reduce_3_s, 128, 72)
RT( g_reduce_4, g_reduce_4_s, 64, 36)
RT( g_reduce_5, g_reduce_5_s, 32, 18)
RT( g_reduce_6, g_reduce_6_s, 8, 8)
RT( g_gauss_1, g_gauss_1_s, 128, 72)
RT( g_gauss_2, g_gauss_2_s, 64, 36)
RT( g_gauss_3, g_gauss_3_s, 32, 18)
RT( g_gauss_4, g_gauss_4_s, 128, 72)
RT( g_gauss_5, g_gauss_5_s, 64, 36)
RT( g_gauss_6, g_gauss_6_s, 32, 18)
RT( g_gauss_7, g_gauss_7_s, 256, 144)

sampler2D g_texture0_s = sampler_state {
	texture = <g_reduce_6>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};
sampler2D g_texture1_s = sampler_state {
	texture = <g_gauss_5>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

RT( expos, expos_s, 32, 2)
RT( expos2, expos2_s, 32, 2)
sampler2D exposure_history = sampler_state {
	texture = <expos2>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

shared texture2D g_exposure_tex : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int MipLevels = 1;
	int Width  = 32;
	int Height = 2;
	string Format = TEXFORMAT;
>;
sampler2D uhmm = sampler_state {
	texture = <g_exposure_tex>;
	AddressU = CLAMP; AddressV = CLAMP;
};

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize.xy);

	float R_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_R +";>;
	float R_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_R -";>;
	float G_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_G +";>;
	float G_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_G -";>;
	float B_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_B +";>;
	float B_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_B -";>;
	float IntensityA   : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity +";>;
	float IntensityB   : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity -";>;
	float R_RadioA     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_R +";>;
	float R_RadioB     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_R -";>;
	float G_RadioA     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_G +";>;
	float G_RadioB     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_G -";>;
	float B_RadioA     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_B +";>;
	float B_RadioB     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_B -";>;
	float RadioA       : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio +";>;
	float RadioB       : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio -";>;
	float Override     : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Override";>;
	
float set(float A, float B) {
	return lerp(1 + (A * 3) * 0.5 - B, A, (int)Override); }
	
static float4 g_intensity = float4(set(R_IntensityA, R_IntensityB), set(G_IntensityA, G_IntensityB), set(B_IntensityA, B_IntensityB), 1);
static float4 g_radius =    float4(set(R_RadioA, R_RadioB), set(G_RadioA, G_RadioB), set(B_RadioA, B_RadioB), 1);
//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 Pos : POSITION0;
  float4 TX0 : TEXCOORD0;
};
struct vs_out
{
  float4 Pos : SV_POSITION0;
  float4 UV  : TEXCOORD0;
  float2 OG  : TEXCOORD1;
  float4 texcoord0 : TEXCOORD2;
  float4 texcoord1 : TEXCOORD3;
  float4 texcoord2 : TEXCOORD4;
  float4 texcoord3 : TEXCOORD5;
  float4 texcoord4 : TEXCOORD6;
  float4 texcoord5 : TEXCOORD7;
  float4 texcoord6 : TEXCOORD8;
  float4 texcoord7 : TEXCOORD9;
};

void draw_quad(int width, int height, float s0, float t0, float s1, float t1, float scale, float param_x, float param_y, float param_z, float param_w, out float4 g_texcoord_modifier, out float4 g_texel_size, out float4 g_color, out float4 g_texture_lod) {
	s0 -= s1;
    t0 -= t1;

	scale *= 0.5;
    float w = (float)max(width, 1);
    float h = (float)max(height, 1);
    g_texcoord_modifier = float4( 0.5f * s0, 0.5f * t0, 0.5f * s0 + s1, 0.5f * t0 + t1 ) * float4(1.0, -1, 1.0, 1) ; 
    g_texel_size = float4( scale / w, scale / h, w, h );
    g_color = float4( param_x, param_y, param_z, param_w );
    g_texture_lod = 0.0f;
}

void calculate_gaussian_kernel(float radius, int stride, int offset, out float gk_0, out float gk_1, out float gk_2, out float gk_3, out float gk_4, out float gk_5, out float gk_6, out float gk_7) {
	float start = 1.0f;  float step = 1.0f;  int kernel_size = 7;  float radius_scale = 0.8f;  float intensity_scale = 1.0f;
            float first_val = (start - step * 0.5f) * 2.0f;
            for (int i = 0; i < kernel_size; i++)

            float temp_gaussian_kernel[20];
            float s = radius * radius_scale;
            s = 1.0f / (2.0f * s * s);

            double sum = first_val;
            temp_gaussian_kernel[0] = first_val;
            float val = start;
            for (int i = 1; i < kernel_size; i++) {
                sum += temp_gaussian_kernel[i] = exp(-(val * val * s)) * step;
                val += step;
            }

            sum = 1.0f / sum;
            for (int i = 0; i < kernel_size; i++)
                gk_0 = (float)(temp_gaussian_kernel[0] * sum);
				gk_1 = (float)(temp_gaussian_kernel[1] * sum);
				gk_2 = (float)(temp_gaussian_kernel[2] * sum);
				gk_3 = (float)(temp_gaussian_kernel[3] * sum);
				gk_4 = (float)(temp_gaussian_kernel[4] * sum);
				gk_5 = (float)(temp_gaussian_kernel[5] * sum);
				gk_6 = (float)(temp_gaussian_kernel[6] * sum);
				gk_7 = (float)(temp_gaussian_kernel[7] * sum);
};

void calc_gaussian_blur(float start, float step, int kernel_size, float radius_scale, float intensity_scale, out float4 g_coef_0, out float4 g_coef_1, out float4 g_coef_2, out float4 g_coef_3, out float4 g_coef_4, out float4 g_coef_5, out float4 g_coef_6, out float4 g_coef_7) {
	float3 radius = g_radius.xyz;  int stride = 3;  int offset = 0;
		float3 gauss[20];
        calculate_gaussian_kernel(radius.x, 3, 0, gauss[0].x, gauss[1].x, gauss[2].x, gauss[3].x, gauss[4].x, gauss[5].x, gauss[6].x, gauss[7].x);
        calculate_gaussian_kernel(radius.y, 3, 1, gauss[0].y, gauss[1].y, gauss[2].y, gauss[3].y, gauss[4].y, gauss[5].y, gauss[6].y, gauss[7].y);
        calculate_gaussian_kernel(radius.z, 3, 2, gauss[0].z, gauss[1].z, gauss[2].z, gauss[3].z, gauss[4].z, gauss[5].z, gauss[6].z, gauss[7].z);
        float3 intensity = g_intensity * (intensity_scale * 0.5f);

        for (int i = 0; i < kernel_size && i < 8; i++) {
            g_coef_0 = float4(gauss[0] * intensity, 0.0f);
			g_coef_1 = float4(gauss[1] * intensity, 0.0f);
			g_coef_2 = float4(gauss[2] * intensity, 0.0f);
			g_coef_3 = float4(gauss[3] * intensity, 0.0f);
			g_coef_4 = float4(gauss[4] * intensity, 0.0f);
			g_coef_5 = float4(gauss[5] * intensity, 0.0f);
			g_coef_6 = float4(gauss[6] * intensity, 0.0f);
			g_coef_7 = float4(gauss[7] * intensity, 0.0f);
        }
}
		float4 g_texcoord_modifier, g_texel_size, g_color, g_texture_lod;
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i, uniform int width, uniform int height, uniform float s0, uniform float t0, uniform float s1, uniform float t1, uniform float scale, uniform float param_x, uniform float param_y, uniform float param_z, uniform float param_w)
{	draw_quad(width, height, s0, t0, s1, t1, scale, param_x, param_y, param_z, param_w, g_texcoord_modifier, g_texel_size, g_color, g_texture_lod);
    vs_out o = (vs_out)0;
		
	o.Pos = i.Pos;
	o.UV = i.TX0 + ( 0.5 / float4(width, height, width, height) );
	o.OG = i.TX0;
	
	float2 tex = i.TX0 + ( 0.5 / float2(width, height) );
    o.texcoord0 = tex.xyxy + float4(-1.0, -1.0,  1.0, -1.0) * g_texel_size.xyxy;
    o.texcoord1 = tex.xyxy + float4(-1.0,  1.0,  1.0,  1.0) * g_texel_size.xyxy;
	o.texcoord2 = tex.xyxy + float4(-1.5, -0.6, -0.5, -0.6) * g_texel_size.xyxy;
    o.texcoord3 = tex.xyxy + float4( 0.5, -0.6,  1.5, -0.6) * g_texel_size.xyxy;
    o.texcoord4 = tex.xyxy + float4(-1.5,  0.6, -0.5,  0.6) * g_texel_size.xyxy;
    o.texcoord5 = tex.xyxy + float4( 0.5,  0.6,  1.5,  0.6) * g_texel_size.xyxy;
	o.texcoord6 = tex.xyxy + float4(-0.5, -0.5,  0.5, -0.5) * g_texel_size.xyxy;
    o.texcoord7 = tex.xyxy + float4(-0.5,  0.5,  0.5,  0.5) * g_texel_size.xyxy;
    return o;
}
//============================================================================//
// Fragment Shader(s) :

float4 reduce_tex_reduce_4(vs_out i, uniform sampler2D smp) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord0;
	float4 frg_texcoord1 = i.texcoord1;

    float4 sum = tex2D(smp, frg_texcoord0.xy);
    sum += tex2D(smp, frg_texcoord0.zw);
    sum += tex2D(smp, frg_texcoord1.xy);
    sum += tex2D(smp, frg_texcoord1.zw);
    return sum * 0.25;
}

float4 reduce_tex_reduce_4_extract(vs_out i) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord0;
	float4 frg_texcoord1 = i.texcoord1;
	float4 result;

    float3 col0 = tex2D(g_reduce_1_s, frg_texcoord0.xy).rgb;
    float3 col1 = tex2D(g_reduce_1_s, frg_texcoord0.zw).rgb;
    float3 col2 = tex2D(g_reduce_1_s, frg_texcoord1.xy).rgb;
    float3 col3 = tex2D(g_reduce_1_s, frg_texcoord1.zw).rgb;
    float3 sum = col0 + col1 + col2 + col3;
    sum *= 0.25;
    result.rgb = max(max(max(col0, col1),  max(col2, col3)) - float3(1.1, 1.1, 1.1), (0.0));
	
	const float4 to_ybr = float4(0.35, 0.45, 0.2, 1.0);
    result.a = dot(sum, to_ybr.rgb);
	return result;
}

float4 exposure_minify(vs_out i) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord2;
	float4 frg_texcoord1 = i.texcoord3;
	float4 frg_texcoord2 = i.texcoord4;
	float4 frg_texcoord3 = i.texcoord5;
	float4 result;

    float4 sum = tex2D(g_reduce_5_s, frg_texcoord0.xy);
    sum += tex2D(g_reduce_5_s, frg_texcoord0.zw);
    sum += tex2D(g_reduce_5_s, frg_texcoord1.xy);
    sum += tex2D(g_reduce_5_s, frg_texcoord1.zw);
    sum += tex2D(g_reduce_5_s, frg_texcoord2.xy);
    sum += tex2D(g_reduce_5_s, frg_texcoord2.zw);
    sum += tex2D(g_reduce_5_s, frg_texcoord3.xy);
    sum += tex2D(g_reduce_5_s, frg_texcoord3.zw);
	return sum * 0.125;
}

float4 pp_gauss_usual(vs_out i, uniform sampler2D g_texture, uniform int w, uniform int h, uniform int X, uniform int Y) : COLOR0
{	
	float4 frg_texcoord = i.UV;
	float4 g_coef[8];
	calc_gaussian_blur(1.0f, 1.0f, 7, 0.8f, 1.0f, g_coef[0], g_coef[1], g_coef[2], g_coef[3], g_coef[4], g_coef[5], g_coef[6], g_coef[7]);
	
    float4 sum = tex2D(g_texture, frg_texcoord);
    sum.rgb *= g_coef[0].rgb;

    float2 s = float2(0.5 / w, 0.5 / h) * float2(X, Y);
    float2 stex1 = s;
    float2 stex2 = s * 2.0;
    float2 stex3 = s * 3.0;
    float2 stex4 = s * 4.0;
    float2 stex5 = s * 5.0;
    float2 stex6 = s * 6.0;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex1).rgb * g_coef[1].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex1).rgb * g_coef[1].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex2).rgb * g_coef[2].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex2).rgb * g_coef[2].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex3).rgb * g_coef[3].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex3).rgb * g_coef[3].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex4).rgb * g_coef[4].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex4).rgb * g_coef[4].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex5).rgb * g_coef[5].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex5).rgb * g_coef[5].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord + stex6).rgb * g_coef[6].rgb;
    sum.rgb += tex2D(g_texture, frg_texcoord - stex6).rgb * g_coef[6].rgb;
    return sum;
}

float4 pp_gauss_cone(vs_out i) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord6;
	float4 frg_texcoord1 = i.texcoord7;

    float4 sum = tex2D(g_reduce_2_s, frg_texcoord0.xy);
    sum += tex2D(g_reduce_2_s, frg_texcoord0.zw);
    sum += tex2D(g_reduce_2_s, frg_texcoord1.xy);
    sum += tex2D(g_reduce_2_s, frg_texcoord1.zw);
    return sum * 0.25 * g_intensity;
}

float4 reduce_tex_reduce_composite_4(vs_out i) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord0;
	float4 frg_texcoord1 = i.texcoord1;
	float2 frg_texcoord2 = i.OG;
	float4 result;
	
	g_color = float4(0.15, 0.25, 0.25, 0.25);
	
    float4 col0 = tex2D(g_gauss_7_s, frg_texcoord2 + (float2(0.5,0.5)/float2(256, 144)));
    float4 col1 = tex2D(g_gauss_4_s, frg_texcoord2 + (float2(0.5,0.5)/float2(128, 72)));
    float4 col2 = tex2D(g_gauss_5_s, frg_texcoord2 + (float2(0.5,0.5)/float2(64, 36)));
    float3 sum = tex2D(g_gauss_6_s, frg_texcoord0.xy).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord0.zw).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord1.xy).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord1.zw).rgb;
    sum *= 0.25 * g_color.w;
    sum += col0.rgb * g_color.x;
    sum += col1.rgb * g_color.y;
    sum += col2.rgb * g_color.z;
    result.rgb = sum;
    result.a = 0;
	return result + tex2D(ScnSamp, frg_texcoord2 + ViewportOffset).xyzw;
}

float4 exposure_measure(vs_out i, float2 UV : TEXCOORD3) : COLOR0
{	
	float4 g_spot_weight = float4(1.56, 0.00, 0.00, 0.00);
	
	const float4 p_center_coef = float4(0.8, 1.0, 1.2, 0.0);
	
	float fovii = 1;
	float height = 1;
	float width = 1;
	
	#define M_PI 3.14159265359
	#define RAD_TO_DEG_FLOAT ((float)(180.0 / M_PI))

    #define DEG_TO_RAD_FLOAT ((float)(M_PI / 180.0))
	
	float3 v41 = 400;float4 v40 = { 66.0f, 1.0f, 1.0f, 40.0f };
	
				float4 v34 = { 0.05f, 0.0f, -0.04f, 1.0f };
                float4 v33 = { 1.0f, 0.0f, 0.0f, 0.0f };
	
	
				float v12 = 1.0f / v40.w;
                float v13 = v40.x * v12;
                float v14 = v40.y * v12;
                //if (v41.z >= 0.0f || abs(v13) >= 1.0f || abs(v14) >= 1.0f)
                   // continue;
	
				float v31 = 0.5f - (abs(v14) - 1.0f) * 2.5f;
                float v32 = 0.5f - (abs(v13) - 1.0f) * 2.5f;

                float v16 = min(min(v31, v32), 1.0f);	
	
				float3 v39 = 0.3;
	
				float v17 = (v39.z + 1.0f) * 0.5f;
                if (v17 > 0.8f)
                    v17 = 0.8f;
                else if (v17 < 0.2f)
                    v17 = 0.0f;
	
	
				float v18 = (float)height / (float)width;
                float v20 = tan(fovii * 0.5f * DEG_TO_RAD_FLOAT);
                float v21 = 0.25f / sqrt(pow(v20 * 3.4f, 2.0f) * (v41.z * v41.z));
                float v22;
                if (v21 < 0.055f)
                    v22 = max((v21 - 0.035f) * 50.0f, 0.0f);
                else if (v21 > 0.5f)
                    v22 = max(1.0f - (v21 - 0.5f) * 3.3333333f, 0.0f);
                else
                    v22 = 1.0f;
	
static float4 spot_coefficients[8];	
	spot_coefficients[0].x = (v13 + v21 * 0.0f * v18 + 1.0f) * 0.5f;
    spot_coefficients[0].y = (v14 + v21 * 0.1f + 1.0f) * 0.5f;
    spot_coefficients[0].z = 0.0f;
    spot_coefficients[0].w = 4.0f;
    spot_coefficients[1].x = (v13 + v21 * 0.0f * v18 + 1.0f) * 0.5f;
    spot_coefficients[1].y = (v14 - v21 * 0.3f + 1.0f) * 0.5f;
    spot_coefficients[1].z = 0.0f;
    spot_coefficients[1].w = 4.0f;
    spot_coefficients[2].x = (v13 + v21 * -0.5f * v18 + 1.0f) * 0.5f;
    spot_coefficients[2].y = (v14 + v21 * -0.5f + 1.0f) * 0.5f;
    spot_coefficients[2].z = 0.0f;
    spot_coefficients[2].w = 3.0f;
    spot_coefficients[3].x = (v13 - v21 * 0.6f * v18 + 1.0f) * 0.5f;
    spot_coefficients[3].y = (v14 - v21 * 0.1f + 1.0f) * 0.5f;
    spot_coefficients[3].z = 0.0f;
    spot_coefficients[3].w = 2.0f;
    spot_coefficients[4].x = (v13 + v21 * 0.6f * v18 + 1.0f) * 0.5f;
    spot_coefficients[4].y = (v14 - v21 * 0.1f + 1.0f) * 0.5f;
    spot_coefficients[4].z = 0.0f;
    spot_coefficients[4].w = 2.0f;
    spot_coefficients[5].x = (v13 + v21 * 0.5f * v18 + 1.0f) * 0.5f;
    spot_coefficients[5].y = (v14 + v21 * -0.5f + 1.0f) * 0.5f;
    spot_coefficients[5].z = 0.0f;
    spot_coefficients[5].w = 3.0f;
    spot_coefficients[6].x = (v13 + v21 * 0.0f * v18 + 1.0f) * 0.5f;
    spot_coefficients[6].y = (v14 - v21 * 0.8f + 1.0f) * 0.5f;
    spot_coefficients[6].z = 0.0f;
    spot_coefficients[6].w = 3.0f;
	spot_coefficients[7].x = 0.0f;
    spot_coefficients[7].y = 0.0f;
    spot_coefficients[7].z = 0.0f;
    spot_coefficients[7].w = 0.0f;

	float spot_weight;
	spot_weight = v16 * 1.6f * v17 * v22;

	//static float4 g_spot_coefficients[32];
	//for (int j = 0; j < 8; j++)
	//g_spot_coefficients[1 * 8 + j] = spot_coefficients[j];
		
float4 g_spot_coefficients[32] = {
    float4(0.50013, 0.67579, 0.00, 4.00),
    float4(0.50013, 0.66396, 0.00, 4.00),
    float4(0.49181, 0.65805, 0.00, 3.00),
    float4(0.49015, 0.66988, 0.00, 2.00),
    float4(0.51011, 0.66988, 0.00, 2.00),
    float4(0.50845, 0.65805, 0.00, 3.00),
    float4(0.50013, 0.64918, 0.00, 3.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.68195, 0.55201, 0.00, 4.00),
    float4(0.68195, 0.54175, 0.00, 4.00),
    float4(0.67474, 0.53661, 0.00, 3.00),
    float4(0.67329, 0.54688, 0.00, 2.00),
    float4(0.69062, 0.54688, 0.00, 2.00),
    float4(0.68917, 0.53661, 0.00, 3.00),
    float4(0.68195, 0.52892, 0.00, 3.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.49823, 0.62291, 0.00, 4.00),
    float4(0.49823, 0.61565, 0.00, 4.00),
    float4(0.49312, 0.61201, 0.00, 3.00),
    float4(0.4921, 0.61928, 0.00, 2.00),
    float4(0.50436, 0.61928, 0.00, 2.00),
    float4(0.50334, 0.61201, 0.00, 3.00),
    float4(0.49823, 0.60656, 0.00, 3.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00)
};
	
    float2 sum = float2(0.0, 1e-09);
    sum.x += tex2D(g_texture0_s, float2(0.125, 0.125)).w * p_center_coef.x;
    sum.y += p_center_coef.x;
    sum.x += tex2D(g_texture0_s, float2(0.375, 0.125)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.625, 0.125)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.875, 0.125)).w * p_center_coef.x;
    sum.y += p_center_coef.x;
    sum.x += tex2D(g_texture0_s, float2(0.125, 0.375)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.375, 0.375)).w * p_center_coef.z;
    sum.y += p_center_coef.z;
    sum.x += tex2D(g_texture0_s, float2(0.625, 0.375)).w * p_center_coef.z;
    sum.y += p_center_coef.z;
    sum.x += tex2D(g_texture0_s, float2(0.875, 0.375)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.125, 0.625)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.375, 0.625)).w * p_center_coef.z;
    sum.y += p_center_coef.z;
    sum.x += tex2D(g_texture0_s, float2(0.625, 0.625)).w * p_center_coef.z;
    sum.y += p_center_coef.z;
    sum.x += tex2D(g_texture0_s, float2(0.875, 0.625)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.125, 0.875)).w * p_center_coef.x;
    sum.y += p_center_coef.x;
    sum.x += tex2D(g_texture0_s, float2(0.375, 0.875)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.625, 0.875)).w * p_center_coef.y;
    sum.y += p_center_coef.y;
    sum.x += tex2D(g_texture0_s, float2(0.875, 0.875)).w * p_center_coef.x;
    sum.y += p_center_coef.x;
    float center = sum.x * (1.0 / sum.y);

    float4 spot;
    sum = float2(0.0, 1e-09);
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[0].xy).w * g_spot_coefficients[0].w;
    sum.y += g_spot_coefficients[0].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[1].xy).w * g_spot_coefficients[1].w;
    sum.y += g_spot_coefficients[1].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[2].xy).w * g_spot_coefficients[2].w;
    sum.y += g_spot_coefficients[2].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[3].xy).w * g_spot_coefficients[3].w;
    sum.y += g_spot_coefficients[3].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[4].xy).w * g_spot_coefficients[4].w;
    sum.y += g_spot_coefficients[4].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[5].xy).w * g_spot_coefficients[5].w;
    sum.y += g_spot_coefficients[5].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[6].xy).w * g_spot_coefficients[6].w;
    sum.y += g_spot_coefficients[6].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[7].xy).w * g_spot_coefficients[7].w;
    sum.y += g_spot_coefficients[7].w;
    spot.x = sum.x * (1.0 / (sum.y * 1.1));

    sum = float2(0.0, 1e-09);
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[8].xy).w * g_spot_coefficients[8].w;
    sum.y += g_spot_coefficients[8].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[9].xy).w * g_spot_coefficients[9].w;
    sum.y += g_spot_coefficients[9].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[10].xy).w * g_spot_coefficients[10].w;
    sum.y += g_spot_coefficients[10].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[11].xy).w * g_spot_coefficients[11].w;
    sum.y += g_spot_coefficients[11].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[12].xy).w * g_spot_coefficients[12].w;
    sum.y += g_spot_coefficients[12].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[13].xy).w * g_spot_coefficients[13].w;
    sum.y += g_spot_coefficients[13].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[14].xy).w * g_spot_coefficients[14].w;
    sum.y += g_spot_coefficients[14].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[15].xy).w * g_spot_coefficients[15].w;
    sum.y += g_spot_coefficients[15].w;
    spot.y = sum.x * (1.0 / (sum.y * 1.1));

    sum = float2(0.0, 1e-09);
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[16].xy).w * g_spot_coefficients[16].w;
    sum.y += g_spot_coefficients[16].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[17].xy).w * g_spot_coefficients[17].w;
    sum.y += g_spot_coefficients[17].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[18].xy).w * g_spot_coefficients[18].w;
    sum.y += g_spot_coefficients[18].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[19].xy).w * g_spot_coefficients[19].w;
    sum.y += g_spot_coefficients[19].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[20].xy).w * g_spot_coefficients[20].w;
    sum.y += g_spot_coefficients[20].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[21].xy).w * g_spot_coefficients[21].w;
    sum.y += g_spot_coefficients[21].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[22].xy).w * g_spot_coefficients[22].w;
    sum.y += g_spot_coefficients[22].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[23].xy).w * g_spot_coefficients[23].w;
    sum.y += g_spot_coefficients[23].w;
    spot.z = sum.x * (1.0 / (sum.y * 1.1));

    sum = float2(0.0, 1e-09);
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[24].xy).w * g_spot_coefficients[24].w;
    sum.y += g_spot_coefficients[24].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[25].xy).w * g_spot_coefficients[25].w;
    sum.y += g_spot_coefficients[25].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[26].xy).w * g_spot_coefficients[26].w;
    sum.y += g_spot_coefficients[26].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[27].xy).w * g_spot_coefficients[27].w;
    sum.y += g_spot_coefficients[27].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[28].xy).w * g_spot_coefficients[28].w;
    sum.y += g_spot_coefficients[28].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[29].xy).w * g_spot_coefficients[29].w;
    sum.y += g_spot_coefficients[29].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[30].xy).w * g_spot_coefficients[30].w;
    sum.y += g_spot_coefficients[30].w;
    sum.x += tex2D(g_texture1_s, g_spot_coefficients[31].xy).w * g_spot_coefficients[31].w;
    sum.y += g_spot_coefficients[31].w;
    spot.w = sum.x * (1.0 / (sum.y * 1.1));

    sum.x = center;
    sum.x += spot.x * g_spot_weight.x;
    sum.x += spot.y * g_spot_weight.y;
    sum.x += spot.z * g_spot_weight.z;
    sum.x += spot.w * g_spot_weight.w;
    sum.y = 1.0;
    sum.y += g_spot_weight.x;
    sum.y += g_spot_weight.y;
    sum.y += g_spot_weight.z;
    sum.y += g_spot_weight.w;
    float4 result = sum.x * (1.0 / sum.y);	
	float2 OG = i.OG;
	return lerp(result, tex2D(expos2_s, UV+float2(0.0, 0)).xyzw,smoothstep(OG.x+1.63, 1.66, 1.635));
}

float4 ps_screen22(vs_out i, float2 UV : TEXCOORD3) : COLOR0
{	
  return tex2D(expos_s, UV).xyzw;
}

float4 exposure_average(vs_out i, float2 UV : TEXCOORD3) : COLOR0
{	
    float4 sum = tex2D(exposure_history, float2(0.03125, 0.25));
    sum += tex2D(exposure_history, float2(0.09375, 0.25));
    sum += tex2D(exposure_history, float2(0.15625, 0.25));
    sum += tex2D(exposure_history, float2(0.21875, 0.25));
    sum += tex2D(exposure_history, float2(0.28125, 0.25));
    sum += tex2D(exposure_history, float2(0.34375, 0.25));
    sum += tex2D(exposure_history, float2(0.40625, 0.25));
    sum += tex2D(exposure_history, float2(0.46875, 0.25));
    sum += tex2D(exposure_history, float2(0.53125, 0.25));
    sum += tex2D(exposure_history, float2(0.59375, 0.25));
    sum += tex2D(exposure_history, float2(0.65625, 0.25));
    sum += tex2D(exposure_history, float2(0.71875, 0.25));
    sum += tex2D(exposure_history, float2(0.78125, 0.25));
    sum += tex2D(exposure_history, float2(0.84375, 0.25));
    sum += tex2D(exposure_history, float2(0.90625, 0.25));
    sum += tex2D(exposure_history, float2(0.96875, 0.25));
	return sum * 0.0625;
}

float4 ps_screen(vs_out i, float2 UV : TEXCOORD3) : COLOR0
{	
  return tex2D(ScnSamp, UV).xyzw;
}
//============================================================================//
float4 ClearColor = {0,0,0,0};
float  ClearDepth = 1.0;
//============================================================================//
//  Technique(s)  : 
technique Bloom <
	string Script = 		
		"RenderColorTarget0=;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"

		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"
		
		"RenderColorTarget=g_reduce_1;  Pass=Reduce_1;"
		"RenderColorTarget=g_reduce_2;  Pass=Reduce_2;"
		"RenderColorTarget=g_reduce_3;  Pass=Reduce_3;"
		"RenderColorTarget=g_reduce_4;  Pass=Reduce_4;"
		"RenderColorTarget=g_reduce_5;  Pass=Reduce_5;"
		"RenderColorTarget=g_reduce_6;  Pass=Reduce_6;"
		"RenderColorTarget=g_gauss_1;   Pass=Gauss_1;"
		"RenderColorTarget=g_gauss_2;   Pass=Gauss_2;"
		"RenderColorTarget=g_gauss_3;   Pass=Gauss_3;"
		"RenderColorTarget=g_gauss_4;   Pass=Gauss_4;"
		"RenderColorTarget=g_gauss_5;   Pass=Gauss_5;"
		"RenderColorTarget=g_gauss_6;   Pass=Gauss_6;"
		"RenderColorTarget=g_gauss_7;   Pass=Gauss_7;"
		"RenderColorTarget=expos;       Pass=exposure_me;"
		"RenderColorTarget0=expos2;     Pass=Screen22;"
		"RenderColorTarget0=g_exposure_tex;   Pass=Exposure_Average;"
			
		"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Composite;"
	;
> {
	pass Reduce_1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( ViewportSize.x, ViewportSize.y, 1, 1, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_texture_s);
	}
	pass Reduce_2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( ViewportSize.x/2, ViewportSize.y/2, 1, 1, 0.0f, 0.0f, 1.0f, 1.1f, 1.1f, 1.1f, 0.0f );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4_extract();
	}
	pass Reduce_3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 256, 144, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_2_s);
	}
	pass Reduce_4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 128, 72, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_3_s);
	}
	pass Reduce_5 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 64, 36, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_4_s);
	}
	pass Reduce_6 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32, 18, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
        PixelShader = compile ps_3_0 exposure_minify();
	}
	pass Gauss_1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 128, 72, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_3_s, 128, 72, 1, 0 );
	}
	pass Gauss_2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 64, 36, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_4_s, 64, 36, 1, 0 );
	}
	pass Gauss_3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32, 18, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_5_s, 32, 18, 1, 0 );
	}
	pass Gauss_4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 128, 72, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_1_s, 128, 72, 0, 1 );
	}
	pass Gauss_5 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 64, 36, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_2_s, 64, 36, 0, 1 );
	}
	pass Gauss_6 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32, 18, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f);
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_3_s, 32, 18, 0, 1 );
	}
	pass Gauss_7 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 256, 144, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1* 0.5f, 1 * 0.5f, 1 * 0.5f, 1.0f );
        PixelShader = compile ps_3_0 pp_gauss_cone();
	}
	
	pass Composite < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32, 18, 1.0f, 1.0f, 0.0f, 0.0f, 0.25f, 0.15f, 0.25f, 0.25f, 0.25f);
        PixelShader = compile ps_3_0 reduce_tex_reduce_composite_4();
	}
	
	pass exposure_me < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32+ 0.5/32, 2+ 0.5/2, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
        PixelShader = compile ps_3_0 exposure_measure();
	}
	
	pass Screen22 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 32+ 0.5/32, 2+ 0.5/2, 1, 1, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f );
        PixelShader = compile ps_3_0 ps_screen22();
	}
	pass Exposure_Average < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( 1, 1, 1, 1, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f );
        PixelShader = compile ps_3_0 exposure_average();
	}
	pass Screen < string Script= "Draw=Buffer;"; > {
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model( ViewportSize.x / 2, ViewportSize.y / 2, 1, 1, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f );
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
