
//=== Settings: ===//
// SSS:
float4 SSS_Tone = float4(1.00, 0.96, 1.00, 0.00); // SSS Multiplier

// Aniso:
float Size = 8.0f; // Blur Size (Radius)
//  More settings in "ps_aniso".

//==============================//
float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;
//==============================//

// オリジナルの描画結果を記録するためのレンダーターゲット
//=== SSS ===//
shared texture SSS_SF : OFFSCREENRENDERTARGET
<   string Description = "SSS Material Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
    float4 ClearColor = {0.0f, 0.0f, 0.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 1;
	string Format = "D3DFMT_A16B16G16R16F";
	string DefaultEffect = 
        "self = hide;"
        "*=SSS/SSS_Base.fx;";
>;

//=== ANISO ===//
shared texture ANISO_SF : OFFSCREENRENDERTARGET
<   string Description = "(ANISO) U/V/Radial Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
    float4 ClearColor = {0.0f, 0.0f, 0.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 1;
	string Format = "D3DFMT_A16B16G16R16F";
	string DefaultEffect = 
        "self = hide;"
        "*=Aniso/V.fx;";
>;

//=== DEPTH ===//
texture DEPTH_SF : OFFSCREENRENDERTARGET
<   string Description = "SSS Material Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
    float4 ClearColor = {0.0f, 0.0f, 0.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 1;
	string Format = "D3DFMT_R32F";
	string DefaultEffect = 
        "self = hide;"
        "*=Aniso/+/Depth.fx;";
>;

sampler2D DS = sampler_state {
	texture = <DEPTH_SF>;
	MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8";
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

//  Textures / Samplers  :

sampler2D SSSS = sampler_state {
    texture = <ANISO_SF>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

texture2D ExpandTex : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int Miplevels = 1;
	float2 ViewPortRatio = {1.0f, 1.0f};
	string Format = "D3DFMT_A16B16G16R16F";
>;

sampler2D ExpandAniso = sampler_state {
	texture = <ExpandTex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

sampler2D g_texture_s = sampler_state {
	texture = <SSS_SF>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

shared texture2D g_sss : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int Miplevels = 0;
	string Format = "D3DFMT_A16B16G16R16F";
	float2 ViewPortRatio = {1.0f, 1.0f};
>;

shared texture2D g_aniso : RENDERCOLORTARGET <
	bool AntiAlias = true;
	int Miplevels = 0;
	string Format = "D3DFMT_A16B16G16R16F";
	float2 ViewPortRatio = {1.0f, 1.0f};
>;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

// レンダリングターゲットのクリア値
float4 ClearColor = {0.35,0.35,0.35,0};
float ClearDepth  = 1.0;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;
#define cmp

//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 v0 : POSITION0;
  float2 v1 : TEXCOORD0;
  float4 v2 : TEXCOORD1;
  float4 v3 : TEXCOORD2;
  float4 v4 : TEXCOORD3;
};
struct vs_out
{
  float4 o0 : SV_POSITION0;
  float2 texcoord : TEXCOORD0;
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
  o.texcoord = i.v1 + ViewportOffset.xy;
  
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
		
  float2 v1 = i.texcoord;
  float4 v2 = i.o3;
  float4 v3 = i.o4;
  float4 o0 = 0;
  
  r0.xyzw = tex2D(SSSS, v1.xy).xyzw;
  r1.x = cmp(r0.w == 1.000000);
  if (r1.x != 0) {
    o0.xyz = r0.xyz;
    o0.w = 1;
    return o0;
  }
  r1.xyzw = tex2D(SSSS, v2.xy).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(SSSS, v2.zw).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(SSSS, v3.xy).xyzw;
  r2.x = cmp(r0.w < r1.w);
  r0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  r1.xyzw = tex2D(SSSS, v3.zw).xyzw;
  r2.x = cmp(r0.w < r1.w);
  o0.xyzw = r2.xxxx ? r1.xyzw : r0.xyzw;
  return o0;
}

float4 ps_model(vs_out i) : COLOR0
{	
	float4 g_color = SSS_Tone;
	float4 g_texcoord_modifier = float4(0.50, -0.50, 0.50, 0.50);
	float4 g_texel_size = float4(0.00313, 0.00556, 320.00, 180.00);
	
	//GaussianCoef
	float4 g_param = float4(5.00, 0.00, 1.00, 1.00);
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
	  
  float2 frg_texcoord = i.texcoord;
  float4 result;

    //#if U16_DEF
        float4 col = tex2D(g_texture_s, frg_texcoord);
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

            col = tex2D(g_texture_s, stex.xy);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;

            col = tex2D(g_texture_s, stex.zw);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;
            idx++;
        }

        float4 ttex = frg_texcoord.xyxy;
        for (int i = 0; i < count; i++) {
            ttex.y += step_y;
            ttex.w -= step_y;

            col = tex2D(g_texture_s, ttex.xy);
            coeff = g_coef[idx].rgb * col.a;
            sum += col.rgb * coeff;
            sum_coef += coeff;

            col = tex2D(g_texture_s, ttex.zw);
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

                col = tex2D(g_texture_s, stex0.xy);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(g_texture_s, stex0.zw);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(g_texture_s, stex2.xy);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;

                col = tex2D(g_texture_s, stex2.zw);
                coeff = g_coef[idx].rgb * col.a;
                sum += col.rgb * coeff;
                sum_coef += coeff;
                idx++;
            }
        }

        result.rgb = sum * (1.0 / sum_coef) * g_color.rgb;
        result.a = 1.0;
    //#else
    //    result = tex2D(g_texture_s, frg_texcoord);
    //#endif
	return result;
}

float4 ps_aniso(vs_out i) : COLOR0
{	
  float2 v1 = i.texcoord;
  float4 o0 = 0;
  
  float Pi = 6.28318530718; // Pi*2
  
	float Quality = 4.0f; // Blur Quality (Default 4.0)
    float Directions = 12.0f; // Blur Directions (Default 16.0)   
    float2 Radius = (Size * saturate(1-tex2D(DS, v1)/100))/ViewportSize.xy;
    
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = v1.xy;
    // Pixel colour
    float4 Color = tex2D(ExpandAniso, uv);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
			Color += pow(tex2D( ExpandAniso, uv+float2(cos(d),sin(d))*Radius*i), 2.2);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions;
	  return pow(Color, 1/2.2);
}

float4 ps_screen(vs_out i, float2 UV : TEXCOORD0) : COLOR0
{	
  return tex2D(ScnSamp, UV).xyzw;
}
//============================================================================//
//  Technique(s)  : 
technique SSS < string MMDPass = "object";
    string Script = 
		"RenderColorTarget0=ExpandTex;"
		"Pass=Expand;"

		"RenderColorTarget0=g_sss;"
		    "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
		"Pass=Mainx2;"
		
		"RenderColorTarget0=g_aniso;"
		    "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
		"Pass=Anisox2;"
				
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"

        "RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=Screen;"
	;
> {
	pass Mainx2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
	}
	pass Anisox2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_aniso();
	}
	pass Expand < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_expand();
	}
	pass Screen < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
