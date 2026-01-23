#include <vector>
#include <map>

#include <extdll.h>
#include <meta_api.h>


#include "signatures.h"
#include "asext_api.h"

#include "angelscript.h"
#include "utility.h"

#pragma region Function Def
// GrappleGetMonsterType
enum GRAPPLE_RESULT {
	PULL_COME = 1,
	PULL_TO = 2
};
typedef GRAPPLE_RESULT(SC_SERVER_DECL* fnGrappleGetMonsterType)(void* pThis, SC_SERVER_DUMMYARG void* pEntity);
PRIVATE_FUNCTION_EXTERN(GrappleGetMonsterType);
// SendScoreInfo
//typedef void(SC_SERVER_DECL *fnSendScoreInfo)(void* pThis, SC_SERVER_DUMMYARG edict_t* eSendTarget, int iTeamID, char* szTeamName);
//void SC_SERVER_DECL NewSendScoreInfo(void* pThis, SC_SERVER_DUMMYARG edict_t* eSendTarget, int iTeamID, char* szTeamName);
//PRIVATE_FUNCTION_EXTERN(SendScoreInfo);
#pragma endregion

#pragma region SigHooks
/// <summary>
/// Grapple GetMonsterType
/// </summary>
hook_t* g_phook_GrappleGetMonsterType = nullptr;
PRIVATE_FUNCTION_DEFINE(GrappleGetMonsterType);
GRAPPLE_RESULT SC_SERVER_DECL NewGrappleGetMonsterType(void* pThis, SC_SERVER_DUMMYARG void* pEntity) {
	int uiFlag = 0;
	if (ASEXT_CallHook)
		(*ASEXT_CallHook)(g_AngelHook.pGrappleCheckMonsterType, 0, pThis, pEntity, &uiFlag);
	if (uiFlag != 0 && uiFlag <= 2 && uiFlag >= 1)
		return (GRAPPLE_RESULT)uiFlag;
	return g_call_original_GrappleGetMonsterType(pThis, SC_SERVER_PASS_DUMMYARG pEntity);
}
/// <summary>
/// SendScoreInfo
/// </summary>
//hook_t* g_phook_SendScoreInfo = nullptr;
//PRIVATE_FUNCTION_DEFINE(SendScoreInfo);
//void SC_SERVER_DECL NewSendScoreInfo(void* pThis, SC_SERVER_DUMMYARG edict_t* eSendTarget, int iTeamID, char* szTeamName) {
//	int uiFlag = 0;
//	if (ASEXT_CallHook)
//		(*ASEXT_CallHook)(g_AngelHook.pSendScoreInfo, 0, pThis, eSendTarget, iTeamID, szTeamName, &uiFlag);
//	if (uiFlag != 0)
//		return;
//	g_call_original_SendScoreInfo(pThis, SC_SERVER_PASS_DUMMYARG eSendTarget, iTeamID, szTeamName);
//}
bool InstallEngineHook() {
	auto ServerHandle = gpMetaUtilFuncs->pfnGetGameDllHandle();
	auto EngineHandle = gpMetaUtilFuncs->pfnGetEngineHandle();

	auto ServerBase = gpMetaUtilFuncs->pfnGetGameDllBase();
	auto EngineBase = gpMetaUtilFuncs->pfnGetEngineBase();

	auto ServerSize = gpMetaUtilFuncs->pfnGetImageSize(ServerBase);

#ifdef WIN32
#define GrappleGetMonsterType_Signature "\x8B\x44\x24\x04\xB9\x2A\x2A\x2A\x2A\x53\x56\x8B\x70\x04\xA1\x2A\x2A\x2A\x2A\x8B\x90\x98\x00\x00\x00\x03\x16\x8B\xC2\x0F\x1F\x00"
#define SendScoreInfo_Signature "\x53\x8B\x5C\x24\x08\x57\x8B\xF9\x85\xDB\x0F\x84\xBB\x01\x00\x00"
#else
#define GrappleGetMonsterType_Signature "\x55\x57\x56\x53\x83\xEC\x04\x2A\x2A\x2A\x2A\x2A\x81\xC2\x2A\xB5\x83\x00\x8D\x82\x60\x3E\x01\x00\x8B\x08"
#define SendScoreInfo_Signature "_ZN11CBasePlayer26SendScoreInfoToOtherPlayerEP7edict_siPKc"
#endif
	// Fill and Hook
	//FILL_AND_HOOK(Server, GrappleGetMonsterType);
	//FILL_AND_HOOK(Server, SendScoreInfo);
	// Fill and Engine Hook
	return true;
}
void UninstallEngineHook() {
	UNINSTALL_HOOK(GrappleGetMonsterType);
	//UNINSTALL_HOOK(SendScoreInfo);
}
#pragma endregion
