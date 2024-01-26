////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow_ObjHeader.fxh : HgShadow オブジェクト影描画に必要な基本パラメータ定義ヘッダファイル
//  ここのパラメータをシェーダエフェクトファイルで #include して使用します。
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

// 制御パラメータ
#define HgShadow_CTRLFILENAME  "HgShadow.x"
bool HgShadow_Valid  : CONTROLOBJECT < string name = HgShadow_CTRLFILENAME; >;

float HgShadow_DensityUp   : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen+"; >;
float HgShadow_DensityDown : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen-"; >;

#ifndef MIKUMIKUMOVING

float HgShadow_AcsRx : CONTROLOBJECT < string name = HgShadow_CTRLFILENAME; string item = "Rx"; >;
float HgShadow_ObjTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float HgShadow_Density = max((degrees(HgShadow_AcsRx) + 5.0f*HgShadow_DensityUp + 1.0f)*(1.0f - HgShadow_DensityDown), 0.0f);

#else

shared float HgShadow_MMM_Density;
static float HgShadow_Density = max((HgShadow_MMM_Density + 5.0f*HgShadow_DensityUp)*(1.0f - HgShadow_DensityDown), 0.0f);

#endif


// 影生成描画結果を記録するためのレンダーターゲット
shared texture2D HgShadow_ViewportMap2 : RENDERCOLORTARGET;
sampler2D HgShadow_ViewportMapSamp = sampler_state {
    texture = <HgShadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// スクリーンサイズ
float2 HgShadow_ViewportSize : VIEWPORTPIXELSIZE;
static float2 HgShadow_ViewportOffset = (float2(0.5,0.5)/HgShadow_ViewportSize);


// セルフシャドウの遮蔽率を求める
float HgShadow_GetSelfShadowRate(float2 FragCoord)
{
    // スクリーンの座標
    float2 texCoord = FragCoord + HgShadow_ViewportOffset;

    // 遮蔽率
    float comp = 1.0f - tex2Dlod( HgShadow_ViewportMapSamp, float4(texCoord, 0, 0) ).r;

    return (1.0f-(1.0f-comp) * min(HgShadow_Density, 1.0f));
}


