#include <extdll.h>
#include <meta_api.h>
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

int SC_SERVER_DECL CBloater::TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType)
{
	damageinfo_t dmg = {
		pThis,
		GetEntVarsVTable(pevInflictor),
		GetEntVarsVTable(pevAttacker),
		flDamage,
		bitsDamageType
	};

	CALL_ANGELSCRIPT(pMonsterPreTakeDamage, &dmg);
	int result = CALL_ORIGIN(g_hookitems.BaseMonsterTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTakeDamage, &dmg, &result);
	return result;
}

void SC_SERVER_DECL CBloater::TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType)
{
	traceinfo_t trace = {
		pThis,
		GetEntVarsVTable(pevAttacker),
		flDamage,
		vecDir,
		*ptr,
		bitsDamageType
	};

	CALL_ANGELSCRIPT(pMonsterPreTraceAttack, &trace);
	CALL_ORIGIN(g_hookitems.BaseMonsterTraceAttack, TraceAttack, pevAttacker, trace.flDamage, trace.vecDir, &trace.ptr, trace.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTraceAttack, &trace);
}

void SC_SERVER_DECL CBloater::Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib)
{
	CALL_ANGELSCRIPT(pMonsterPreKilled, pThis, pevAttacker, &iGib)
	CALL_ORIGIN(g_hookitems.BaseMonsterKilled, Killed, pevAttacker, iGib);
	CALL_ANGELSCRIPT(pMonsterPostKilled, pevAttacker, iGib)
}

void SC_SERVER_DECL CBloater::Use(CBaseMonster* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value)
{
	CALL_ANGELSCRIPT(pMonsterPreUse, pThis, pActivator, pCaller, &useType, &value);
	CALL_ORIGIN(g_hookitems.BaseMonsterUse, Use, pActivator, pCaller, useType, value);
	CALL_ANGELSCRIPT(pMonsterPostUse, pThis, pActivator, pCaller, useType, value);
}

void SC_SERVER_DECL CBloater::Revive(CBaseMonster* pThis SC_SERVER_DUMMYARG_NOCOMMA)
{
	CALL_ANGELSCRIPT(pMonsterPreRevive, pThis);
	CALL_ORIGIN_NOARG_MONSTER(g_hookitems.BaseMonsterRevive, Revive);
	CALL_ANGELSCRIPT(pMonsterPostRevive, pThis);
}

void SC_SERVER_DECL CBloater::PlaySentence(CBaseMonster* pThis, SC_SERVER_DUMMYARG char* szSentence, float duration, float volume, float attenuation)
{
	CString strMessage = { 0 };
	strMessage.assign(szSentence, strlen(szSentence));

	CALL_ANGELSCRIPT(pMonsterPrePlaySentence, pThis, &strMessage, duration, volume, attenuation);
	CALL_ORIGIN_MONSTER(g_hookitems.BaseMonsterPlaySentence, PlaySentence, szSentence, duration, volume, attenuation);
	CALL_ANGELSCRIPT(pMonsterPostPlaySentence, pThis, &strMessage, duration, volume, attenuation);
}

void SC_SERVER_DECL CBloater::CheckEnemy(CBaseMonster* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEnemy)
{
	CALL_ANGELSCRIPT(pMonsterPreCheckEnemy, pThis, pEnemy);
	CALL_ORIGIN_MONSTER(g_hookitems.BaseMonsterCheckEnemy, CheckEnemy, pEnemy);
	CALL_ANGELSCRIPT(pMonsterPostCheckEnemy, pThis, pEnemy);
}

void CBloater::Register()
{
	vtable_base_t* vtableBase = AddEntityVTable("monster_bloater");
	ITEM_HOOK(g_hookitems.BaseMonsterTraceAttack, TraceAttack, vtableBase, CBloater::TraceAttack);
	ITEM_HOOK(g_hookitems.BaseMonsterKilled, Killed, vtableBase, CBloater::Killed);
	ITEM_HOOK(g_hookitems.BaseMonsterUse, Use, vtableBase, CBloater::Use);
	vtableBase = AddEntityVTable("monster_ichthyosaur");
	ITEM_HOOK(g_hookitems.BaseMonsterTakeDamage, TakeDamage, vtableBase, CBloater::TakeDamage);
	vtable_monster_t* vtableMonster = AddEntityVTableMonster("monster_bloater");
	ITEM_HOOK(g_hookitems.BaseMonsterRevive, Revive, vtableMonster, CBloater::Revive);
	ITEM_HOOK(g_hookitems.BaseMonsterCheckEnemy, CheckEnemy, vtableMonster, CBloater::CheckEnemy);
	vtableMonster = AddEntityVTableMonster("monster_scientist");
	ITEM_HOOK(g_hookitems.BaseMonsterPlaySentence, PlaySentence, vtableMonster, CBloater::PlaySentence);
}
