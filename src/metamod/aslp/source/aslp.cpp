#include <extdll.h>
#include <meta_api.h>	

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"

angelhook_t g_AngelHook;

#define CREATE_AS_HOOK(item, des, tag, name, arg) g_AngelHook.item=ASEXT_RegisterHook(des,StopMode_CALL_ALL,2,ASFlag_MapScript|ASFlag_Plugin,tag,name,arg)
#define REGISTER_AS_HOOK(base_name, des, tag, arg) CREATE_AS_HOOK(base_name, des, tag, (#base_name + 1), arg)
//#define REGISTER_AS_HOOK_INFO(base_name, des, tag, name, arg) CREATE_AS_HOOK(base_name, des, tag, name, arg)
void RegisterAngelScriptHooks()
{
	/*Function Table*/
	REGISTER_AS_HOOK(pThink, "Pre call of gEntityInterface.pfnThink", "ASLP::Engine", "CBaseEntity@ pOther, META_RES& out meta_result");
	REGISTER_AS_HOOK(pTouch, "Pre call of gEntityInterface.pfnTouch", "ASLP::Engine", "CBaseEntity@ pTouched, CBaseEntity@ pOther, META_RES& out meta_result");
	REGISTER_AS_HOOK(pBlocked, "Pre call of gEntityInterface.pfnBlocked", "ASLP::Engine", "CBaseEntity@ pBlocked, CBaseEntity@ pOther, META_RES & out meta_result");
	REGISTER_AS_HOOK(pKeyValue, "Pre call of gEntityInterface.pfnKeyValue", "ASLP::Engine", "CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result");
	REGISTER_AS_HOOK(pClientCommand, "Pre call of gEntityInterface.pfnClientCommand", "ASLP::Engine", "CBasePlayer@ pPlayer, const string& in command, META_RES& out meta_result");
	REGISTER_AS_HOOK(pPM_Move, "Pre call of gEntityInterface.pfnPM_Move", "ASLP::Engine", "playermove_t@& out pmove, int server, META_RES& out meta_result");
	REGISTER_AS_HOOK(pAddToFullPack, "Pre call of gEntityInterface.pfnAddToFullPack", "ASLP::Engine", "entity_state_t@& out state, int entindex, edict_t @ent, edict_t@ host, int hostflags, int player, META_RES& out meta_result, int& out result");

	/*Function Table Post*/
	REGISTER_AS_HOOK(pThink_Post, "Post call of gEntityInterface.pfnThink_Post", "ASLP::Engine", "CBaseEntity@ pOther, META_RES& out meta_result");
	REGISTER_AS_HOOK(pAddToFullPack_Post, "Post call of gEntityInterface.pfnAddToFullPack_Post", "ASLP::Engine", "entity_state_t@& out state, int entindex, edict_t @ent, edict_t@ host, int hostflags, int player, META_RES& out meta_result, int& out result");

	/*New DLL Function Table*/
	REGISTER_AS_HOOK(pShouldCollide, "Pre call of gEntityInterface.pfnShouldCollide", "ASLP::Engine", "CBaseEntity@ pTouched, CBaseEntity@ pOther, META_RES& out meta_result, int& out result");

	/*Player*/
	REGISTER_AS_HOOK(pPlayerPreTakeHealth, "Pre call before a player will receive health", "ASLP::Player", "HealthInfo@ pInfo");
	REGISTER_AS_HOOK(pPlayerPostTakeHealth, "Post call after a player will recive health", "ASLP::Player", "HealthInfo@ pInfo, int& out result");
	REGISTER_AS_HOOK(pPlayerPreTakeArmor, "Pre call before a player will recive armor", "ASLP::Player", "HealthInfo@ pInfo");
	REGISTER_AS_HOOK(pPlayerPostTakeArmor, "Post call after a player will recive armor", "ASLP::Player", "HealthInfo@ pInfo, int& out result");
	REGISTER_AS_HOOK(pPlayerPreRevive, "Pre call before a player will revive", "ASLP::Player", "CBasePlayer@ pPlayer");
	REGISTER_AS_HOOK(pPlayerPostRevive, "Post call after a player will revive", "ASLP::Player", "CBasePlayer@ pPlayer");

	/*Monsters*/
	REGISTER_AS_HOOK(pMonsterPreTakeDamage, "Pre call before a monster will recived damage", "ASLP::Monster", "DamageInfo@ pInfo");
	REGISTER_AS_HOOK(pMonsterPostTakeDamage, "Post call after a monster recive damage", "ASLP::Monster", "DamageInfo@ pInfo, int& out result");
	REGISTER_AS_HOOK(pMonsterPreTraceAttack, "Pre call before a monster is get traced attack", "ASLP::Monster", "TraceInfo@ pInfo");
	REGISTER_AS_HOOK(pMonsterPostTraceAttack, "Post call after a monster is get traced attack", "ASLP::Monster", "TraceInfo@ pInfo");
	REGISTER_AS_HOOK(pMonsterPreKilled, "Pre call before a monster is killed", "ASLP::Monster", "CBaseMonster@ pMonster, entvars_t@ pevAttacker, int& out iGib");
	REGISTER_AS_HOOK(pMonsterPostKilled, "Post call after a monster was killed", "ASLP::Monster", "CBaseMonster@ pMonster, entvars_t@ pevAttacker, int iGib");
	REGISTER_AS_HOOK(pMonsterPreUse, "Pre call before a monster is used", "ASLP::Monster",  "CBaseMonster@ pMonster, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int& out useType, float& out value" );
	REGISTER_AS_HOOK(pMonsterPostUse, "Post call after a monster was used", "ASLP::Monster", "CBaseMonster@ pMonster, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int useType, float value" );
	REGISTER_AS_HOOK(pMonsterPreRevive, "Pre call before a monster is revived", "ASLP::Monster", "CBaseMonster@ pMonster");
	REGISTER_AS_HOOK(pMonsterPostRevive, "Post call after a monster was revived", "ASLP::Monster", "CBaseMonster@ pMonster");
	REGISTER_AS_HOOK(pMonsterPrePlaySentence, "Pre call before a monster will play a sentence", "ASLP::Monster", "CBaseMonster@ pMonster, const string& in szSentence, float duration, float volume, float attenuation");
	REGISTER_AS_HOOK(pMonsterPostPlaySentence, "Post call after a monster played a sentence", "ASLP::Monster", "CBaseMonster@ pMonster, const string& in szSentence, float duration, float volume, float attenuation");
	REGISTER_AS_HOOK(pMonsterPreCheckEnemy, "Pre call before a monster check his enemy", "ASLP::Monster", "CBaseMonster@ pMonster, CBaseEntity@ pEnemy");
	REGISTER_AS_HOOK(pMonsterPostCheckEnemy, "Pre call before a monster check his enemy", "ASLP::Monster", "CBaseMonster@ pMonster, CBaseEntity@ pEnemy");
}
#undef CREATE_AS_HOOK
#undef REGISTER_AS_HOOK
//#undef REGISTER_AS_HOOK_INFO

cvar_t init_ignore_tracer_player = {(char*)"mp_ignore_tracer_player", (char*)"0", FCVAR_EXTDLL, 0, NULL };
cvar_t* mp_ignore_tracer_player = NULL;
cvar_t* mp_allowmonsterinfo = NULL;

void RegisterAngelScriptCvar()
{
	CVAR_REGISTER(&init_ignore_tracer_player);
	mp_ignore_tracer_player = CVAR_GET_POINTER("mp_ignore_tracer_player");
	mp_allowmonsterinfo = CVAR_GET_POINTER("mp_allowmonsterinfo");
}