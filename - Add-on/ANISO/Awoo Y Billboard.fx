////////////////////////////////////////////////////////////////////////////////////////////////
//
//  basic.fx ver2.0
//  作成: 舞力介入P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

// 座法変換行列
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// マテリアル色
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
// ライト色
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool use_texture;  //テクスチャの有無
bool use_toon;     //トゥーンの有無

bool     parthf;   // パースペクティブフラグ
bool     transp;   // 半透明フラグ
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// オブジェクトのテクスチャ
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

#define Controller "#ShaderFarc_Controller.pmx"
#define IBLDirection "IBL Direction"
float4x4 IBL_Controller : CONTROLOBJECT < string name = Controller; string item = IBLDirection ; >;
static float3 IBL_Dir = IBL_Controller._31_32_33;

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

float3x3 NormalTransform(float3 Light_Direction, float3 IBL_dir)
{	
	float3x3 CUBETransform;;
	float leng = length(IBL_dir.xyz);
    if (leng >= 0.00000f) {
        float3 ibl_direction = IBL_dir.xyz * (1.0f / leng);

		float3 ibl_position = Light_Direction * float3(1, 1, -1);
        leng = length(ibl_position.xyz);
        if (leng >= 0.00000f) {
            float3 position = ibl_position * (1.0f / leng);
		
			float3 axis = cross(ibl_direction, position);
            leng = length(axis.xyz);

            float v52 = dot(ibl_direction, position);
            float angle = abs(atan2(leng, v52));
			
			if (angle >= 0.00000f && angle <= 3.131592653589793f) {
                if (leng != 0.0f)
                    axis *= 1.0f / leng;
				
			CUBETransform = Rotation(axis, sin(-angle), cos(-angle));
	
	float3 RotationAngles = radians(float3(-45, -45, 0));
	float3x3 rotationX = {
    1, 0, 0,
    0, cos(RotationAngles.x), sin(RotationAngles.x),
    0, -sin(RotationAngles.x), cos(RotationAngles.x)};

	float3x3 rotationY = {
    cos(RotationAngles.y), 0, -sin(RotationAngles.y),
    0, 1, 0,
    sin(RotationAngles.y), 0, cos(RotationAngles.y)};

	float3x3 rotationZ = {
    cos(RotationAngles.z), sin(RotationAngles.z), 0,
    -sin(RotationAngles.z), cos(RotationAngles.z), 0,
    0, 0, 1};

	CUBETransform = mul(CUBETransform, rotationX);
	CUBETransform = mul(CUBETransform, rotationY);
	CUBETransform = mul(CUBETransform, rotationZ);
	
	float3x3 Scale = {
	1.00, 0.00, 0.00,
	0.00, 1.00, 0.00,
	0.00, 0.00, 1.00};
	
	CUBETransform = mul(CUBETransform, Scale);	} } }
	return CUBETransform;
}

static float3x3 g_normal_tangent_transforms = NormalTransform(LightDirection, -IBL_Dir);

float4x4 CTF(float3 frg_position, float3 frg_normal, float2 frg_texcoord) {
	float4x4 Out;
	frg_position = frg_position * float3(1, 1, -1);
	float3 p_dx = ddx(frg_position.xyz);
	float3 p_dy = ddy(frg_position.xyz);
	float2 tc_dx = ddx(frg_texcoord.xy);
	float2 tc_dy = ddy(frg_texcoord.xy);
	float3 t = normalize( tc_dy.y * p_dx - tc_dx.y * p_dy );
	float3 b = normalize( tc_dy.x * p_dx - tc_dx.x * p_dy );
	float3 n = normalize(frg_normal * float3(1, 1, -1));
	float3 x = cross(n, t);
	t = cross(x, n);
	t = normalize(t);
	x = cross(b, n);
	b = cross(n, x);
	b = normalize(b);
	
	Out[0].xyz = t;
	Out[1].xyz = b;
	Out[2].xyz = frg_normal;
	return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画（セルフシャドウOFF）

// トゥーンマップのサンプラ。"register(s0)"なのはMMDがs0を使っているから
sampler ToonTexSampler : register(s0);

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // 射影変換座標
    float2 Tex        : TEXCOORD1;   // テクスチャ
    float3 Normal     : TEXCOORD2;   // 法線
    float3 Eye        : TEXCOORD3;   // カメラとの相対位置
	float3 Vertcoord  : TEXCOORD4;   // ###########
    float4 Color      : COLOR0;      // ディフューズ色
    float3 Specular   : COLOR1;      // スペキュラ色
};

// 頂点シェーダ
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // カメラ視点のワールドビュー射影変換
    Out.Pos = mul( Pos, WorldViewProjMatrix );
	
	float3 worldPos = mul(WorldMatrix, float4(0, 0, 0, 1)).xyz;
    float3 dist = CameraPosition - worldPos;
    float angle = atan2(dist.x, dist.z);
 
    float3x3 rotMatrix;
    float cosinus = cos(angle);
    float sinus = sin(angle);
       
    rotMatrix[0].xyz = float3(cosinus, 0, sinus);
    rotMatrix[1].xyz = float3(0, 1, 0);
    rotMatrix[2].xyz = float3(- sinus, 0, cosinus);
 
    float4 newPos = float4(mul(rotMatrix, Pos * float4(-1, 1, -1, 0)), 1);
    Out.Pos = mul(mul(WorldMatrix, newPos), WorldViewProjMatrix);
				
	Out.Vertcoord = mul( Pos, WorldMatrix );
    
    // カメラとの相対位置
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // 頂点法線
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // ディフューズ色＋アンビエント色 計算
    Out.Color.rgb = saturate( max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb + AmbientColor );
    Out.Color.a = DiffuseColor.a;
    
    // テクスチャ座標
    Out.Tex = Tex;
    
    // スペキュラ色計算
    float3 HalfVector = normalize( normalize(Out.Eye) + -LightDirection );
    Out.Specular = pow( max(0,dot( HalfVector, Out.Normal )), SpecularPower ) * SpecularColor;

    return Out;
}

// ピクセルシェーダ
float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    float4 Color = IN.Color;
    if ( use_texture ) {  //※このif文は非効率的
        // テクスチャ適用
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
	
	float4x4 Frame = CTF(IN.Vertcoord, IN.Normal, IN.Tex);
	float2 frg_texcoord = IN.Tex;
	float3 frg_normal = Frame[2].xyz;
	float3 frg_eye = normalize(IN.Eye);
	float3 frg_tangent = Frame[0].xyz;
	float3 frg_binormal = Frame[1].xyz;	
	
    Color.rgb = mul(frg_tangent, (float3x3)g_normal_tangent_transforms);
    return Color;
}

// オブジェクト描画用テクニック
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

// オブジェクト描画用テクニック
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
