
//=== Settings: ===//
  // SSS:
  float4 SSS_Tone = float4(1.00, 0.96, 1.00, 0.00)*float4(0.95, 0.97, 1.00, 0.00);
	
  // Aniso:
  float2 Intervals = float2(8.0f, 0.0f); // Blur Size (Radius)
  float Intensity = 1;  // Aniso Intensity
  //  More settings in "ps_aniso".
	
  // LUT:
  float Lut_Intensity = 1;
  #define TONE_MAP_SAT_GAMMA_SAMPLES 32
	
//==============================//
float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass  = "scene";
	string ScriptOrder  = "postprocess";
> = 0.8;
//==============================//

//  Textures / Samplers  :
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
	
//=== SSS ===//
texture2D SSS_SF : OFFSCREENRENDERTARGET
<
	int Width  = 1080;
    int Height = 720;
    string Description = "SSS Material Array";
    float4 ClearColor = {1.0f, 1.0f, 1.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 0;
	string Format = "A16B16G16R16F";
	string DefaultEffect =
	    //"self=hide;"
	    "*=SSS/SSS_Base.fx;";
>;
sampler2D SSSS = sampler_state {
    texture = <SSS_SF>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

//=== ANISO ===//
texture2D ANISO_SF : OFFSCREENRENDERTARGET
<
    string Description = "(ANISO) U/V/Radial Array";
	int Width  = 1080;
    int Height = 720;
    float4 ClearColor = {1.0f, 1.0f, 1.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 0;
	string Format = "A16B16G16R16F";
	string DefaultEffect =
	    //"self=hide;"
	    "*=ANISO/V.fx;";
>;
sampler2D Expand_S = sampler_state {
    texture = <ANISO_SF>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

texture2D g_expand : RENDERCOLORTARGET <
	bool AntiAlias = true;
	string Format = "A16B16G16R16F";
>;
sampler2D Aniso = sampler_state {
    texture = <g_expand>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

//=== DEPTH ===//
texture DEPTH_SF : OFFSCREENRENDERTARGET
<   string Description = "ShaderFarc Depth";
    int Width  = 1080;
    int Height = 720;
    float4 ClearColor = {0.0f, 0.0f, 0.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 1;
	string Format = "D3DFMT_R32F";
	string DefaultEffect = 
        "self = hide;"
        "*=ANISO/+/Depth.fx;";
>;
sampler2D DS = sampler_state {
	texture = <DEPTH_SF>;
    FILTER = ANISOTROPIC;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};

shared texture2D g_sss : RENDERCOLORTARGET <
	bool AntiAlias = true;
	string Format = "A16B16G16R16F";
>;

shared texture2D g_aniso : RENDERCOLORTARGET <
	bool AntiAlias = true;
	string Format = "A16B16G16R16F";
>;

shared texture2D g_tonemap : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int Width  = 256;
    int Height = 1;
	string Format = "A16B16G16R16F";
>;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

float Saturat_Pow : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation_Pow";>;
float SaturationA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation +";>;
float SaturationB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation -";>;
float ExposureA   : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure +";>;
float ExposureB   : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Exposure -";>;
float GammaA      : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma +";>;
float GammaB      : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma -";>;
float Override    : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Override";>;
	
float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;

float set(float A, float B) {
	return lerp(Lut_Intensity + (A * 2.5) * 1 - B, A, (int)Override); }
//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 v0 : POSITION0;
  float4 v1 : TEXCOORD0;
  float4 v2 : TEXCOORD1;
  float4 v3 : TEXCOORD2;
  float4 v4 : TEXCOORD3;
};
struct vs_out
{
  float4 o0 : SV_POSITION0;
  float4 o1 : TEXCOORD0;
  float4 o2 : TEXCOORD1;
  float4 o3 : TEXCOORD2;
  float4 o4 : TEXCOORD3;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i)
{
    vs_out o = (vs_out)0;
		
  o.o0 = i.v0;
  o.o1 = i.v1 + ViewportOffset.xyxy;
  
  float4 g_texcoord_modifier = float4(1, 1, 0, 0);
	float4 g_texel_size = float4(ViewportSize.xy*0.5*0.5* 0.00001, 320.00*2, 180.00*2);
	float2 r0 = i.v1;
  r0.xy = r0.xy * g_texcoord_modifier.xy + g_texcoord_modifier.zw;
  
  o.o2.xy = r0.xy;
  o.o3.xyzw = g_texel_size.xyxy * float4(-2,0,2,0) + r0.xyxy;
  o.o4.xyzw = g_texel_size.xyxy * float4(0,8,0,-8) + r0.xyxy;
  
    return o;
}
//============================================================================//
// Fragment Shader(s) :
float4 ps_expand(vs_out i) : COLOR0
{	
	float4 r0 = 1;
	float4 r1 = 1;
	float4 r2 = 1;
	
	float2 v1 = i.o1;
	float4 v2 = i.o3;
	float4 v3 = i.o4;
	float4 o0 = 0;
	
	r0.xyzw = tex2D(Expand_S, v1.xy).xyzw;
	return r0;
}

float4 ps_model(vs_out i) : COLOR0
{	
	float4 g_color = SSS_Tone;
	float4 g_param = float4(5.00, 0.00, 1.00, 1.00);
	float4 g_texcoord_modifier = float4(0.50, -0.50, 0.50, 0.50);
	float4 g_texel_size = float4(0.00313, 0.00556, 320.00, 180.00);
	
	//GaussianCoef
	float4 g_coef[36] = {
    float4(0.60405, 0.97521, 0.86797, 0.00),
    float4(0.09639, 0.01213, 0.05464, 0.00),
    float4(0.02369, 1.03713E-06, 0.00187, 0.00),
    float4(0.00888, 1.72203E-13, 6.79345E-06, 0.00),
    float4(0.00252, 5.55048E-23, 2.60061E-09, 0.00),
    float4(0.0005, 3.47299E-35, 1.05140E-13, 0.00),
    float4(0.09639, 0.01213, 0.05464, 0.00),
    float4(0.04905, 0.00053, 0.01775, 0.00),
    float4(0.01883, 4.56956E-08, 0.00061, 0.00),
    float4(0.00742, 7.58721E-15, 2.20773E-06, 0.00),
    float4(0.00211, 2.44552E-24, 8.45142E-10, 0.00),
    float4(0.00042, 1.53019E-36, 3.41683E-14, 0.00),
    float4(0.02369, 1.03713E-06, 0.00187, 0.00),
    float4(0.01883, 4.56956E-08, 0.00061, 0.00),
    float4(0.01065, 3.90840E-12, 0.00002, 0.00),
    float4(0.00432, 6.48943E-19, 7.57722E-08, 0.00),
    float4(0.00123, 2.09169E-28, 2.90064E-11, 0.00),
    float4(0.00024, 0.00, 1.17270E-15, 0.00),
    float4(0.00888, 1.72203E-13, 6.79345E-06, 0.00),
    float4(0.00742, 7.58721E-15, 2.20773E-06, 0.00),
    float4(0.00432, 6.48943E-19, 7.57722E-08, 0.00),
    float4(0.00176, 1.07749E-25, 2.74653E-10, 0.00),
    float4(0.0005, 3.47299E-35, 1.05140E-13, 0.00),
    float4(0.0001, 0.00, 4.25073E-18, 0.00),
    float4(0.00252, 5.55048E-23, 2.60061E-09, 0.00),
    float4(0.00211, 2.44552E-24, 8.45142E-10, 0.00),
    float4(0.00123, 2.09169E-28, 2.90064E-11, 0.00),
    float4(0.0005, 3.47299E-35, 1.05140E-13, 0.00),
    float4(0.00014, 0.00, 4.02488E-17, 0.00),
    float4(0.00003, 0.00, 1.62723E-21, 0.00),
    float4(0.0005, 3.47299E-35, 1.05140E-13, 0.00),
    float4(0.00042, 1.53019E-36, 3.41683E-14, 0.00),
    float4(0.00024, 0.00, 1.17270E-15, 0.00),
    float4(0.0001, 0.00, 4.25073E-18, 0.00),
    float4(0.00003, 0.00, 1.62723E-21, 0.00),
    float4(5.57189E-06, 0.00, 6.57873E-26, 0.00)
};

	  
  float2 frg_texcoord = i.o1;
  float4 result;

    //#if U16_DEF
        float4 col = tex2D(SSSS, frg_texcoord);
        if (col.a < 0.5) {
            result = col;
            return result;
        }

        const float step_x = g_param.z * g_texel_size.x;
        const float step_y = g_param.w * g_texel_size.y;

        float3 sum = (1e-05);
        float3 sum_coef = (1e-05);

        uint idx = 0;
        sum += col.rgb * g_coef[idx].rgb;
        sum_coef += g_coef[idx].rgb;
        idx++;

        float3 coeff;
        float4 stex = frg_texcoord.xyxy;
        const int count = 5;//int(floor(g_param.x));
        for (int i = 0; i < count; i++) {
            stex.x += step_x;
            stex.z -= step_x;

            col = tex2D(SSSS, stex.xy);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;

            col = tex2D(SSSS, stex.zw);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;
            idx++;
        }

        float4 ttex = frg_texcoord.xyxy;
        for (int i = 0; i < count; i++) {
            ttex.y += step_y;
            ttex.w -= step_y;

            col = tex2D(SSSS, ttex.xy);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;

            col = tex2D(SSSS, ttex.zw);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;
            idx++;

            float4 stex0 = ttex.xyxy;
            float4 stex2 = ttex.zwzw;

            for (int j = 0; j < count; j++) {
                stex0.x += step_x;
                stex0.z -= step_x;
                stex2.x += step_x;
                stex2.z -= step_x;

                col = tex2D(SSSS, stex0.xy);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(SSSS, stex0.zw);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(SSSS, stex2.xy);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(SSSS, stex2.zw);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;
                idx++;
            }
        }

        result.rgb = sum * (1.0 / sum_coef) * g_color.rgb;
        result.a = 1.0;
    //#else
    //    result = tex2D(SSSS, frg_texcoord);
    //#endif
	return lerp(result, tex2D(SSSS, frg_texcoord), saturate(tex2D(DS, frg_texcoord).x));
}

float4 ps_aniso(vs_out i) : COLOR0
{	
	float2 v1 = i.o1;
	float4 o0 = 0;
  
	float Pi = 6.28318530718; // Pi*2
  
	float Quality = 4.0f; // Blur Quality (Default 4.0)
    float Directions = 16.0f; // Blur Directions (Default 16.0)   
    float2 Radius = (lerp(Intervals.x, Intervals.y, saturate(tex2D(DS, v1).x)))/ViewportSize.xy;
    
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = v1.xy;
    // Pixel colour
    float4 Color = tex2D(Aniso, uv);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
			Color += pow(tex2D( Aniso, uv+float2(cos(d),sin(d))*Radius*i), 2.2);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions;
	  return pow(0.45, saturate(1 - Color)/2.2) * Intensity;
}

float4 ps_tonemap(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
	UV = UV/1.2;
	
	static float gamma_rate = set(GammaA, GammaB);
    static float saturate_coeff = set(SaturationA, SaturationB);
	
	const float tone_map_scale = (float)(UV.x / (double)TONE_MAP_SAT_GAMMA_SAMPLES);
    const int tone_map_size = 16 * TONE_MAP_SAT_GAMMA_SAMPLES;
	
	float2 tex_data[16 * TONE_MAP_SAT_GAMMA_SAMPLES];
    float gamma_power = 0.8333 * gamma_rate * 1.5f;
    
    tex_data[0].x = 0.0f;
    tex_data[0].y = 0.0f;
	for (int i = 1; i < tone_map_size; i++) {
		float gamma = pow(1.0f - exp((float)-i * tone_map_scale), gamma_power);
		tex_data[0].x = gamma;
	}
	
	int saturate_power = (int)(Saturat_Pow * 7);
	saturate_power = Saturat_Pow == 0 ? 1 : saturate_power;
	float saturation = tex_data[0].x * 2.0f - 1.0f;
	for (int j = 0; j < saturate_power; j++) {
		saturation *= saturation;
		saturation *= saturation;
		saturation *= saturation;
		saturation *= saturation;
    }
	
	tex_data[0].y = tex_data[0].x * saturate_coeff * ((float)TONE_MAP_SAT_GAMMA_SAMPLES / UV.x / 512) * (1.0f - saturation);
	return tex_data[0].xyxy;
}

float4 ps_screen(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
  return tex2D(ScnSamp, UV).xyzw;
}
//============================================================================//
float4 ClearColor = {1, 1, 1, 0};
float ClearDepth  = 1.0;
//============================================================================//
//  Technique(s)  : 
technique SSS <
	string Script = 
		"RenderColorTarget0=;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"

		"RenderColorTarget0=g_expand; Pass=Expand;"
		"RenderColorTarget0=g_sss; Pass=Main;"
		"RenderColorTarget0=g_aniso; Pass=Aniso;"
		"RenderColorTarget0=g_tonemap; Pass=Ramp;"
					
		"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Screen;"
	;
> {
	pass Expand < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_expand();
	}
	pass Main < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
	}
	pass Aniso < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_aniso();
	}
	pass Ramp < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = false; AlphaTestEnable = false;
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_tonemap();
	}
	pass Screen < string Script= "Draw=Buffer;"; > {
		ZEnable = false; ZWriteEnable = false;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
