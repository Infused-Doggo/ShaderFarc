
//==============================//
float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;
//==============================//

// オリジナルの描画結果を記録するためのレンダーターゲット
//=== SSS ===//
texture SSS_SF : OFFSCREENRENDERTARGET
<   string Description = "SSS Material Array";
    float2 ViewPortRatio = {1.0f, 1.0f};
    float4 ClearColor = {0.0f, 0.0f, 0.0f, 0.0f};
    float ClearDepth = 1.0f;
	bool AntiAlias = true;
	int Miplevels = 0;
	string Format = "A16B16G16R16F";
	string DefaultEffect = 
        "self = hide;"
        "*=SSS_Base.fx;";
>;

texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewportRatio = {1,1};
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

//  Textures / Samplers  :


shared texture2D g_sss : RENDERCOLORTARGET <
	bool AntiAlias = false;
	int Miplevels = 0;
	string Format = "A16B16G16R16F";
	float2 ViewPortRatio = {1.0f, 1.0f};
>;
sampler2D g_sss_sampler = sampler_state {
	texture = <g_sss>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

texture2D ExpandTex : RENDERCOLORTARGET <
	bool AntiAlias = false;
	int Miplevels = 0;
	float2 ViewPortRatio = {1.0f, 1.0f};
	string Format = "A16B16G16R16F";
>;
sampler2D g_expand_s = sampler_state {
	texture = <SSS_SF>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

sampler2D SSSS = sampler_state {
    texture = <SSS_SF>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

// レンダリングターゲットのクリア値
float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;
#define cmp

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
		
  float4 v1 = i.o1;
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
	float4 r0 = 1;
	float4 r1 = 1;
	float4 r2 = 1;
	float4 r3 = 1;
	float4 r4 = 1;
	float4 r5 = 1;
	float4 r6 = 1;
	float4 r7 = 1;
	float4 r8 = 1;
	float4 r9 = 1;
	float4 r10 = 1;
	float4 r11 = 1;
	float4 r12 = 1;
	float4 r13 = 1;
		
	float4 g_texcoord_modifier = float4(0.50, -0.50, 0.50, 0.50);
	float4 g_texel_size = float4(0.00313, 0.00556, 320.00, 180.00);
	float4 g_color = float4(1.00, 0.96, 1.00, 0.00);
	float4 g_param = float4(5.00, 0.00, 1.00, 1.00);
	float4 g_coef[64] = {
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
	float4(0.00566, 3.73915E-07, 0.00034, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
    float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00),
	float4(0.00, 0.00, 0.00, 0.00)};
	  
  float4 v1 = i.o1;
  float4 o0 = 0;
  
  r0.xyzw = tex2Dlod(g_expand_s, float4(v1.xy, 0, 0)).xyzw;
  r1.x = cmp(r0.w < 0.5);
  if (r1.x != 0) {
    o0.xyzw = r0.xyzw;
    return o0;
  }
  r1.xy = g_param.zw * g_texel_size.xy;
  r0.xyz = r0.xyz * g_coef[0].xyz + float3(9.99999975e-06,9.99999975e-06,9.99999975e-06);
  r2.xyz = g_coef[0].xyz + float3(9.99999975e-06,9.99999975e-06,9.99999975e-06);
  r1.z = 0;
  r3.xy = v1.xy + r1.xz;
  r4.xy = v1.xy + -r1.xz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r3.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[1].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[1].xyz * r5.www + r2.xyz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r4.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[1].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[1].xyz * r5.www + r2.xyz;
  r3.z = v1.y;
  r3.xy = r3.xz + r1.xz;
  r4.xy = r4.xy + -r1.xz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r3.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[2].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[2].xyz * r5.www + r2.xyz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r4.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[2].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[2].xyz * r5.www + r2.xyz;
  r3.z = v1.y;
  r3.xy = r3.xz + r1.xz;
  r4.xy = r4.xy + -r1.xz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r3.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[3].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[3].xyz * r5.www + r2.xyz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r4.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[3].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[3].xyz * r5.www + r2.xyz;
  r3.z = v1.y;
  r3.xy = r3.xz + r1.xz;
  r4.xy = r4.xy + -r1.xz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r3.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[4].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[4].xyz * r5.www + r2.xyz;
  r5.xyzw = tex2Dlod(g_expand_s, float4(r4.xy, 0, 0)).xyzw;
  r6.xyz = g_coef[4].xyz * r5.www;
  r0.xyz = r5.xyz * r6.xyz + r0.xyz;
  r2.xyz = g_coef[4].xyz * r5.www + r2.xyz;
  r3.z = v1.y;
  r3.xy = r3.xz + r1.xz;
  r3.zw = r4.xy + -r1.xz;
  r4.xyzw = tex2Dlod(g_expand_s, float4(r3.xy, 0, 0)).xyzw;
  r5.xyz = g_coef[5].xyz * r4.www;
  r0.xyz = r4.xyz * r5.xyz + r0.xyz;
  r2.xyz = g_coef[5].xyz * r4.www + r2.xyz;
  r3.xyzw = tex2Dlod(g_expand_s, float4(r3.zw, 0, 0)).xyzw;
  r4.xyz = g_coef[5].xyz * r3.www;
  r0.xyz = r3.xyz * r4.xyz + r0.xyz;
  r2.xyz = g_coef[5].xyz * r3.www + r2.xyz;
  r3.xyz = r0.xyz;
  r4.xyz = r2.xyz;
  r5.xyzw = v1.xyxy;
  r0.w = 6;
  r1.w = 0;
  while (true) {
    r2.w = cmp((int)r1.w >= 5);
    if (r2.w != 0) break;
    r5.xy = r5.xy + r1.zy;
    r5.zw = r5.zw + -r1.zy;
    r6.xyzw = tex2Dlod(g_expand_s, float4(r5.xy, 0, 0)).xyzw;
    r7.xyz = g_coef[r0.w].xyz * r6.www;
    r6.xyz = r6.xyz * r7.xyz + r3.xyz;
    r7.xyz = g_coef[r0.w].xyz * r6.www + r4.xyz;
    r8.xyzw = tex2Dlod(g_expand_s, float4(r5.zw, 0, 0)).xyzw;
    r9.xyz = g_coef[r0.w].xyz * r8.www;
    r6.xyz = r8.xyz * r9.xyz + r6.xyz;
    r7.xyz = g_coef[r0.w].xyz * r8.www + r7.xyz;
    r2.w = (int)r0.w + 1;
    r3.xyz = r6.xyz;
    r4.xyz = r7.xyz;
    r8.xyzw = r5.xyxy;
    r9.xyzw = r5.zwzw;
    r0.w = r2.w;
    r3.w = 0;
    while (true) {
      r4.w = cmp((int)r3.w >= 5);
      if (r4.w != 0) break;
      r8.xy = r8.xy + r1.xz;
      r8.zw = r8.zw + -r1.xz;
      r9.xy = r9.xy + r1.xz;
      r9.zw = r9.zw + -r1.xz;
      r10.xyzw = tex2Dlod(g_expand_s, float4(r8.xy, 0, 0)).xyzw;
      r11.xyz = g_coef[r0.w].xyz * r10.www;
      r10.xyz = r10.xyz * r11.xyz + r3.xyz;
      r11.xyz = g_coef[r0.w].xyz * r10.www + r4.xyz;
      r12.xyzw = tex2Dlod(g_expand_s, float4(r8.zw, 0, 0)).xyzw;
      r13.xyz = g_coef[r0.w].xyz * r12.www;
      r10.xyz = r12.xyz * r13.xyz + r10.xyz;
      r11.xyz = g_coef[r0.w].xyz * r12.www + r11.xyz;
      r12.xyzw = tex2Dlod(g_expand_s, float4(r9.xy, 0, 0)).xyzw;
      r13.xyz = g_coef[r0.w].xyz * r12.www;
      r10.xyz = r12.xyz * r13.xyz + r10.xyz;
      r11.xyz = g_coef[r0.w].xyz * r12.www + r11.xyz;
      r12.xyzw = tex2Dlod(g_expand_s, float4(r9.zw, 0, 0)).xyzw;
      r13.xyz = g_coef[r0.w].xyz * r12.www;
      r3.xyz = r12.xyz * r13.xyz + r10.xyz;
      r4.xyz = g_coef[r0.w].xyz * r12.www + r11.xyz;
      r0.w = (int)r0.w + 1;
      r3.w = (int)r3.w + 1;
    }
    r1.w = (int)r1.w + 1;
  }
  r0.xyz = rcp(r4.xyz);
  r0.xyz = r3.xyz * r0.xyz;
  o0.xyz = g_color.xyz * r0.xyz;
  o0.w = 1;
  return o0;
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
		"Pass=Main;"
		
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
	pass Screen < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
