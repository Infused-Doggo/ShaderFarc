//=== Settings: ===//
	// SSS:
	float4 SSS_Tone = float4(1.00, 0.96, 1.00, 0.00);
	
	// Aniso:
	float Size = 8.0f; // Blur Size (Radius)
	float Intensity = 1;  // Aniso Intensity
	//  More settings in "ps_aniso".
	
	// LUT:
	float Lut_Intensity = 1.1;
	#define TONE_MAP_SAT_GAMMA_SAMPLES 32
	
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
	MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

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
	string Format = "A16B16G16R16F";
>;
	
//  Textures / Samplers  :
//=== SSS ===//
texture2D SSS_SF : OFFSCREENRENDERTARGET
<
    string Description = "SSS Material Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
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
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

//=== ANISO ===//
texture2D ANISO_SF : OFFSCREENRENDERTARGET
<
    string Description = "(ANISO) U/V/Radial Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
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
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

texture2D g_expand : RENDERCOLORTARGET <
	bool AntiAlias = true;
	string Format = "A16B16G16R16F";
>;

sampler2D Aniso = sampler_state {
    texture = <g_expand>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

//=== DEPTH ===//
texture DEPTH_SF : OFFSCREENRENDERTARGET
<   string Description = "ShaderFarc Depth";
    float2 ViewPortRatio = {1.0f, 1.0f};
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
	MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

// レンダリングターゲットのクリア値
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;
#define cmp

	float GammaA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma +";>;
	float GammaB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Gamma -";>;
	float SaturationA : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation +";>;
	float SaturationB : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation -";>;
	float Saturation_Pow : CONTROLOBJECT <string name="#ToneMap_Controller.pmx"; string item="Saturation_Pow";>;
	
	float set(float A, float B) {
		return Lut_Intensity + (A * 2.5) * 1 - B;
	}

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
  r1.x = cmp(r0.w == 1.000000);
  if (r1.x != 0) {
    o0.xyz = r0.xyz;
    o0.w = 1;
    return o0;
  }
  r1.xyzw = tex2D(Expand_S, v2.xy).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(Expand_S, v2.zw).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(Expand_S, v3.xy).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(Expand_S, v3.zw).xyzw;
  r2.x = cmp(r0.w < r1.w);
  o0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  return o0;
}

float4 ps_model(vs_out i) : COLOR0
{	
	float4 g_color = SSS_Tone;
	float4 g_param = float4(1.00, 0.00, 1.00, 1.00);
	float4 g_texcoord_modifier = float4(0.50, -0.50, 0.50, 0.50);
	float4 g_texel_size = float4(0.00313, 0.00556, 320.00, 180.00);
	
	//GaussianCoef
	float4 g_coef[36] = {
    float4(0.13436, 0.69615, 0.53141, 0.00),
    float4(0.10347, 0.07231, 0.09273, 0.00),
    float4(0.0528, 0.02162, 0.02528, 0.00),
    float4(0.02541, 0.00655, 0.0118, 0.00),
    float4(0.01524, 0.00124, 0.00635, 0.00),
    float4(0.01045, 0.00014, 0.00293, 0.00),
    float4(0.10347, 0.07231, 0.09273, 0.00),
    float4(0.08109, 0.03804, 0.05171, 0.00),
    float4(0.04393, 0.01701, 0.02004, 0.00),
    float4(0.02303, 0.00516, 0.01074, 0.00),
    float4(0.01448, 0.00097, 0.00583, 0.00),
    float4(0.0101, 0.00011, 0.00269, 0.00),
    float4(0.0528, 0.02162, 0.02528, 0.00),
    float4(0.04393, 0.01701, 0.02004, 0.00),
    float4(0.02842, 0.00832, 0.01307, 0.00),
    float4(0.01819, 0.00253, 0.00823, 0.00),
    float4(0.01264, 0.00048, 0.00451, 0.00),
    float4(0.00918, 0.00006, 0.00208, 0.00),
    float4(0.02541, 0.00655, 0.0118, 0.00),
    float4(0.02303, 0.00516, 0.01074, 0.00),
    float4(0.01819, 0.00253, 0.00823, 0.00),
    float4(0.01381, 0.00077, 0.00535, 0.00),
    float4(0.01045, 0.00014, 0.00293, 0.00),
    float4(0.00798, 0.00002, 0.00136, 0.00),
    float4(0.01524, 0.00124, 0.00635, 0.00),
    float4(0.01448, 0.00097, 0.00583, 0.00),
    float4(0.01264, 0.00048, 0.00451, 0.00),
    float4(0.01045, 0.00014, 0.00293, 0.00),
    float4(0.00842, 0.00003, 0.00161, 0.00),
    float4(0.00676, 3.19379E-06, 0.00074, 0.00),
    float4(0.01045, 0.00014, 0.00293, 0.00),
    float4(0.0101, 0.00011, 0.00269, 0.00),
    float4(0.00918, 0.00006, 0.00208, 0.00),
    float4(0.00798, 0.00002, 0.00136, 0.00),
	float4(0.00676, 3.19379E-06, 0.00074, 0.00),
	float4(0.00566, 3.73915E-07, 0.00034, 0.00)};
	  
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
	return result;
}

float4 ps_aniso(vs_out i) : COLOR0
{	
  float2 v1 = i.o1;
  float4 o0 = 0;
  
  float Pi = 6.28318530718; // Pi*2
  
	float Quality = 4.0f; // Blur Quality (Default 4.0)
    float Directions = 16.0f; // Blur Directions (Default 16.0)   
    float2 Radius = (Size * saturate(1-tex2D(DS, v1)/100))/ViewportSize.xy;
    
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

float4 ps_screen(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
  return tex2D(ScnSamp, UV).xyzw;
}

float4 ps_tonemap(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
	static float gamma_rate = set(GammaA, GammaB);
    static float saturate_coeff = set(SaturationA, SaturationB);
	
	const float tone_map_scale = (float)(UV.x / (double)TONE_MAP_SAT_GAMMA_SAMPLES);
    const int tone_map_size = 16 * TONE_MAP_SAT_GAMMA_SAMPLES;
	
	int saturate_power = 1;
	
	float4 tex_data = 1;
    float gamma_power = 1 * gamma_rate * 1.5f; // 2.2 = gamma
	
    for (int i = 1; i < tone_map_size; i++) {
        float gamma = pow(1.0f - exp((float)-i * tone_map_scale), gamma_power);
		float saturation = gamma * 2.0f - 1.0f;
		float saturation2 = 1.0f;
        for (int j = 0; j < saturate_power; j++) {
            saturation2 *= saturation;
            saturation2 *= saturation2;
			saturation2 *= saturation2;
			saturation2 *= saturation2;
		}
		tex_data.x = gamma;
		tex_data.y = gamma * saturate_coeff * (1.0f - (Saturation_Pow > 0.5 ? saturation2 : saturation));
	}
	return tex_data;
}
//============================================================================//
//  Technique(s)  : 
technique SSS <
	string Script = 
		"RenderColorTarget0=g_expand;"
		"RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=Expand;"
		
		"RenderColorTarget0=g_sss;"
		"RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=Main;"
		
		"RenderColorTarget0=g_aniso;"
		"RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=Aniso;"
		
		"RenderColorTarget0=g_tonemap;"
		"RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"Pass=Ramp;"

		"RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
			
		"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Screen;"
	;
> {
	pass Expand < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_expand();
	}
	pass Main < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
	}
	pass Aniso < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_aniso();
	}
	pass Ramp < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_tonemap();
	}
	pass Screen < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
