// dlltest.cpp : DLL �A�v���P�[�V�����p�ɃG�N�X�|�[�g�����֐����`���܂��B
//
#include "stdafx.h"
#include <stdio.h>

// �ȉ��� ifdef �u���b�N�� DLL ����̃G�N�X�|�[�g��e�Ղɂ���}�N�����쐬���邽�߂̈�ʓI�ȕ��@�ł��B
// ���� DLL ���̂��ׂẴt�@�C���́A�R�}���h ���C���Œ�`���ꂽ 
//  WIN32PROJECT2_EXPORTS �V���{��
// ���g�p���ăR���p�C������܂��B
// ���̃V���{���́A���� DLL ���g�p����v���W�F�N�g�ł͒�`�ł��܂���B
// �\�[�X�t�@�C�������̃t�@�C�����܂�ł��鑼�̃v���W�F�N�g�́A 
// WIN32PROJECT2_API �֐��� DLL ����C���|�[�g���ꂽ�ƌ��Ȃ��̂ɑ΂��A���� DLL �́A���̃}�N���Œ�`���ꂽ
// �V���{�����G�N�X�|�[�g���ꂽ�ƌ��Ȃ��܂��B
#ifdef DLLTEST_EXPORTS
#define DLLTEST_API extern "C" __declspec(dllexport)
#else
#define DLLTEST_API extern "C" __declspec(dllimport)
#endif
 
DLLTEST_API int hello(void);
 
DLLTEST_API int hello(void) {
	printf("hello world\n");
	return 0;
}

DLLTEST_API int hello2(char *p) {
	printf("%s\n",p);
	return 0;
}

