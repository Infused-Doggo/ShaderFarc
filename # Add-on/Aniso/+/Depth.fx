////////////////////////////////////////////////////////////// 
//============================================================================//
//Shader "Sekai/Live/Stage/LightMap-Reflection"
//============================================================================//

//float4x4 State_Matrix_Program_7 : WORLD;
float4x4 g_transforms : WORLDVIEWPROJECTION;

float4x4 State_Matrix_Program_6 : WORLD;
float4x4 State_Matrix_Program_7 : WORLD;
float4x4 State_MatrixInv_Program_7 : INVERSEWORLD;
float4x4 State_Matrix_ModelView_0 : WORLDVIEW;
float4x4 State_MatrixInv_Program_5 : WORLDVIEW;
float4x4 UNITY_MATRIX_VP : VIEWPROJECTION;

float4   Camera_Position    : POSITION  < string Object = "Camera"; >;
float4   Camera_Direction  : DIRECTION  < string Object = "Camera"; >;
float4   Light_Direction  : DIRECTION  < string Object = "Light"; >;

//============================================================================//
//  Base Structure  :
struct vs_in
{
  float4 Pos : POSITION0;
};
struct vs_out
{
  float4 Pos : SV_POSITION0;
  float4 Depth : TEXCOORD0;
};
//============================================================================//
//  Vertex Shader(s)  :
vs_out vs_model (vs_in i)
{
    vs_out o = (vs_out)0;

	o.Pos = mul(i.Pos, g_transforms);
	o.Depth = mul(i.Pos, State_Matrix_ModelView_0);
    return o;
}
//============================================================================//
// Fragment Shader(s) :
float4 ps_model(vs_out i, float3 Depth : TEXCOORD0) : COLOR0
{

float aa = length(Depth.xyz);
  return float4(aa.xxx, 1);
}
//============================================================================//
//  Technique(s)  : 
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass Main {
        VertexShader = compile vs_3_0 vs_model();
		PixelShader  = compile ps_3_0 ps_model();
    }
}
technique model_tech <string MMDPASS = "object"; > {
	pass Main {
        VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
    }
}