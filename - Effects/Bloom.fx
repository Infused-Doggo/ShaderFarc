
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

sampler2D g_texture_s = sampler_state {
	texture = <ScnMap>;
	MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

#define TEXFORMAT "A16B16G16R16F"
#define LINEAR_FILTER_MODE	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
#define ADDRESSING_MODE		AddressU = CLAMP; AddressV = CLAMP;

#define RT( Tex, Sample, Size) \
	texture2D Tex : RENDERCOLORTARGET < \
		bool AntiAlias = true; \
		int MipLevels = 1; \
		float2 ViewportRatio = {1.0/(Size)-1, 1.0/(Size)-1}; \
		string Format = TEXFORMAT; \
	>; \
	sampler2D Sample = sampler_state { \
		texture = <Tex>; \
		LINEAR_FILTER_MODE	ADDRESSING_MODE \
	}; \

RT( g_reduce_1, g_reduce_1_s, 1.01)
RT( g_reduce_2, g_reduce_2_s, 2)
RT( g_reduce_3, g_reduce_3_s, 4)
RT( g_reduce_4, g_reduce_4_s, 8)
RT( g_reduce_5, g_reduce_5_s, 16)
RT( g_reduce_6, g_reduce_6_s, 32)

RT( g_gauss_1, g_gauss_1_s, 4)
RT( g_gauss_2, g_gauss_2_s, 8)
RT( g_gauss_3, g_gauss_3_s, 16)
RT( g_gauss_4, g_gauss_4_s, 4)
RT( g_gauss_5, g_gauss_5_s, 8)
RT( g_gauss_6, g_gauss_6_s, 16)
RT( g_gauss_7, g_gauss_7_s, 2)

// レンダリングターゲットのクリア値
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize.xy);
static float2 SampleStep = (float2(2.0,2.0) / ViewportSize.xy);

	float R_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_R +";>;
	float R_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_R -";>;
	float G_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_G +";>;
	float G_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_G -";>;
	float B_IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_B +";>;
	float B_IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity_B -";>;
	float R_RadioA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_R +";>;
	float R_RadioB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_R -";>;
	float G_RadioA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_G +";>;
	float G_RadioB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_G -";>;
	float B_RadioA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_B +";>;
	float B_RadioB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio_B -";>;
	float IntensityA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity +";>;
	float IntensityB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Intensity -";>;
	float RadioA : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio +";>;
	float RadioB : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Radio -";>;
	float Override : CONTROLOBJECT <string name="Bloom_Controller.pmx"; string item="Override";>;
	
	float set(float A, float B) {
		return lerp(1 + (A * 3) * 0.5 - B, A, (int)Override);
	}
	
	float3 gaussian_kernel[20];
static float4 g_color = float4(1.1, 1.1, 1.1, 0);
static float4 g_intensity = float4(set(R_IntensityA, R_IntensityB), set(G_IntensityA, G_IntensityB), set(B_IntensityA, B_IntensityB), 1);
static float4 g_radius = float4(set(R_RadioA, R_RadioB), set(G_RadioA, G_RadioB), set(B_RadioA, B_RadioB), 1);
	const float4 to_ybr = float4(0.35, 0.45, 0.2, 1.0);
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
  float4 UV  : TEXCOORD3;
  float4 texcoord0 : TEXCOORD0;
  float4 texcoord1 : TEXCOORD1;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i, uniform float2 size)
{
    vs_out o = (vs_out)0;
		
	o.Pos = i.Pos;
	o.UV = i.TX0 + ViewportOffset.xyxy * 1;
  
	float4 g_texcoord_modifier = float4(0.5, -0.5, 0.5025, 0.5025);
	float4 g_texel_size = size.xyxy * SampleStep.xyxy;
  
	float2 tex = i.Pos * g_texcoord_modifier.xy + g_texcoord_modifier.zw;
    o.texcoord0 = tex.xyxy + float4(-1.0, -1.0, 1.0, -1.0) * g_texel_size.xyxy;
    o.texcoord1 = tex.xyxy + float4(-1.0,  1.0, 1.0,  1.0) * g_texel_size.xyxy;
  
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
    result.rgb = max(max(max(col0, col1),  max(col2, col3)) - g_color.rgb, (0.0));
    result.a = 1;
	return result;
}

float4 pp_gauss_usual(vs_out i, uniform sampler2D g_texture) : COLOR0
{	
	float4 frg_texcoord = i.UV;
	
	float start = 1.0f;  float step = 1.0f;  int kernel_size = 7;  float radius_scale = 0.8f;  float intensity_scale = 1.0f;
	float3 radius = g_radius.xyz;  int stride = 3;  int offset = 0;


			float first_val = (start - step * 0.5f) * 2.0f;
			for (int i = 0; i < kernel_size; i++)
                gaussian_kernel[i * stride + offset] = 0.0f;
				
			float3 temp_gaussian_kernel[20];
            float3 s = radius * radius_scale;
            s = 1.0f / (2.0f * s * s);
			
			float3 sum = first_val;
            temp_gaussian_kernel[0] = first_val;
            float val = start;
			
			for (int i = 1; i < kernel_size; i++) {
                sum += temp_gaussian_kernel[i] = float3(exp(-(val * val * s.x)), exp(-(val * val * s.y)), exp(-(val * val * s.z))) * step;
                val += step;
            }

            sum = 1.0f / sum;
            for (int i = 0; i < kernel_size; i++)
                gaussian_kernel[i * stride + offset] = (float3)(temp_gaussian_kernel[i] * sum);

        float3 intensity = g_intensity * (intensity_scale * 0.5f);
		
		float4 g_coef[8];
        for (int i = 0; i < kernel_size && i < 8; i++) {
            g_coef[i].xyz = gaussian_kernel[i] * intensity;
            g_coef[i].w = 0.0f;
        }

    float4 sum_ps = tex2D(g_texture, frg_texcoord);
    sum_ps.rgb *= g_coef[0].rgb;

    float2 s_ps = 0.001;
    float2 stex1 = s_ps;
    float2 stex2 = s_ps * 2.0;
    float2 stex3 = s_ps * 3.0;
    float2 stex4 = s_ps * 4.0;
    float2 stex5 = s_ps * 5.0;
    float2 stex6 = s_ps * 6.0;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex1).rgb * g_coef[1].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex1).rgb * g_coef[1].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex2).rgb * g_coef[2].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex2).rgb * g_coef[2].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex3).rgb * g_coef[3].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex3).rgb * g_coef[3].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex4).rgb * g_coef[4].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex4).rgb * g_coef[4].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex5).rgb * g_coef[5].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex5).rgb * g_coef[5].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord + stex6).rgb * g_coef[6].rgb;
    sum_ps.rgb += tex2D(g_texture, frg_texcoord - stex6).rgb * g_coef[6].rgb;
    return sum_ps;
}

float4 pp_gauss_cone(vs_out i) : COLOR0
{	
	float4 frg_texcoord0 = i.texcoord0;
	float4 frg_texcoord1 = i.texcoord1;

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
	float4 frg_texcoord2 = i.UV;
	float4 result;
	
	g_color = float4(0.15, 0.25, 0.25, 0.25);
	
    float4 col0 = tex2D(g_gauss_7_s, frg_texcoord2);
    float4 col1 = tex2D(g_gauss_4_s, frg_texcoord2);
    float4 col2 = tex2D(g_gauss_5_s, frg_texcoord2);
    float3 sum = tex2D(g_gauss_6_s, frg_texcoord0.xy).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord0.zw).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord1.xy).rgb;
    sum += tex2D(g_gauss_6_s, frg_texcoord1.zw).rgb;
    sum *= 0.25 * g_color.w;
    sum += col0.rgb * g_color.x;
    sum += col1.rgb * g_color.y;
    sum += col2.rgb * g_color.z;
    result.rgb = sum;
    result.a = col0.a;
	return result+ tex2D(ScnSamp, frg_texcoord2).xyzw;
}

float4 ps_screen(vs_out i, float2 UV : TEXCOORD3) : COLOR0
{	
  return tex2D(g_gauss_7_s, UV).xyzw;
}
//============================================================================//
//  Technique(s)  : 
technique Bloom <
	string Script = 
		"RenderColorTarget0=g_reduce_1;"
		"Pass=Reduce_1;"
		
		"RenderColorTarget0=g_reduce_2;"
		"Pass=Reduce_2;"
		
		"RenderColorTarget0=g_reduce_3;"
		"Pass=Reduce_3;"
		
		"RenderColorTarget0=g_reduce_4;"
		"Pass=Reduce_4;"
		
		"RenderColorTarget0=g_reduce_5;"
		"Pass=Reduce_5;"
		
		"RenderColorTarget0=g_reduce_6;"
		"Pass=Reduce_6;"
		
		"RenderColorTarget0=g_gauss_1;"
		"Pass=Gauss_1;"
		
		"RenderColorTarget0=g_gauss_2;"
		"Pass=Gauss_2;"

		"RenderColorTarget0=g_gauss_3;"
		"Pass=Gauss_3;"
		
		"RenderColorTarget0=g_gauss_4;"
		"Pass=Gauss_4;"
		
		"RenderColorTarget0=g_gauss_5;"
		"Pass=Gauss_5;"

		"RenderColorTarget0=g_gauss_6;"
		"Pass=Gauss_6;"
		
		"RenderColorTarget0=g_gauss_7;"
		"Pass=Gauss_7;"

		"RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
		"ScriptExternal=Color;"
			
		"RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Composite;"
	;
> {
	pass Reduce_1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(2, 2) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_texture_s);
	}
	pass Reduce_2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(2, 2) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4_extract();
	}
	pass Reduce_3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(4, 4) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_2_s);
	}
	pass Reduce_4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(8, 8) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_3_s);
	}
	pass Reduce_5 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(16, 16) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_4_s);
	}
	pass Reduce_6 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(32, 32) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_4(g_reduce_5_s);
	}
	pass Gauss_1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(8, 8) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_3_s);
	}
	pass Gauss_2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(16, 16) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_4_s);
	}
	pass Gauss_3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(32, 32) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_reduce_5_s);
	}
	pass Gauss_4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(8, 8) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_1_s);
	}
	pass Gauss_5 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(16, 16) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_2_s);
	}
	pass Gauss_6 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(32, 32) );
        PixelShader = compile ps_3_0 pp_gauss_usual(g_gauss_3_s);
	}
	pass Gauss_7 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(4, 4) );
        PixelShader = compile ps_3_0 pp_gauss_cone();
	}
	pass Composite < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(4, 4) );
        PixelShader = compile ps_3_0 reduce_tex_reduce_composite_4();
	}
	pass Screen < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 vs_model( float2(1, 1) );
        PixelShader = compile ps_3_0 ps_screen();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
