#include <extdll.h>
#include <meta_api.h>	
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

void SC_SERVER_DECL CApache::TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType)
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
	CALL_ORIGIN(g_hookitems.ApacheTraceAttack, TraceAttack, pevAttacker, trace.flDamage, trace.vecDir, &trace.ptr, trace.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTraceAttack, &trace);
}

int SC_SERVER_DECL CApache::TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType)
{
	damageinfo_t dmg = {
			pThis,
			GetEntVarsVTable(pevInflictor),
			GetEntVarsVTable(pevAttacker),
			flDamage,
			bitsDamageType
	};

	CALL_ANGELSCRIPT(pMonsterPreTakeDamage, &dmg);
	int result = CALL_ORIGIN(g_hookitems.ApacheTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTakeDamage, &dmg, &result);
	return result;
}

void SC_SERVER_DECL CApache::Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib)
{
	CALL_ANGELSCRIPT(pMonsterPreKilled, pevAttacker, &iGib)
	CALL_ORIGIN(g_hookitems.ApacheKilled, Killed, pevAttacker, iGib);
	CALL_ANGELSCRIPT(pMonsterPostKilled, pevAttacker, iGib)
}

void CApache::Register()
{
	vtable_base_t* vtableBase = AddEntityVTable("monster_apache");
	ITEM_HOOK(g_hookitems.ApacheTraceAttack, TraceAttack, vtableBase, CApache::TraceAttack);
	ITEM_HOOK(g_hookitems.ApacheTakeDamage, TakeDamage, vtableBase, CApache::TakeDamage);
	ITEM_HOOK(g_hookitems.ApacheKilled, Killed, vtableBase, CApache::Killed);
}