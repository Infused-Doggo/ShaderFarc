////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow_ObjHeader.fxh : HgShadow �I�u�W�F�N�g�e�`��ɕK�v�Ȋ�{�p�����[�^��`�w�b�_�t�@�C��
//  �����̃p�����[�^���V�F�[�_�G�t�F�N�g�t�@�C���� #include ���Ďg�p���܂��B
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ����p�����[�^
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


// �e�����`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
shared texture2D HgShadow_ViewportMap2 : RENDERCOLORTARGET;
sampler2D HgShadow_ViewportMapSamp = sampler_state {
    texture = <HgShadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// �X�N���[���T�C�Y
float2 HgShadow_ViewportSize : VIEWPORTPIXELSIZE;
static float2 HgShadow_ViewportOffset = (float2(0.5,0.5)/HgShadow_ViewportSize);


// �Z���t�V���h�E�̎Օ��������߂�
float HgShadow_GetSelfShadowRate(float2 FragCoord)
{
    // �X�N���[���̍��W
    float2 texCoord = FragCoord + HgShadow_ViewportOffset;

    // �Օ���
    float comp = 1.0f - tex2Dlod( HgShadow_ViewportMapSamp, float4(texCoord, 0, 0) ).r;

    return (1.0f-(1.0f-comp) * min(HgShadow_Density, 1.0f));
}


