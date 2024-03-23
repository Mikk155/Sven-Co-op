#include <extdll.h>
#include <meta_api.h>	
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

void SC_SERVER_DECL COsprey::TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType)
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
	CALL_ORIGIN(g_hookitems.OspreyTraceAttack, TraceAttack, pevAttacker, trace.flDamage, trace.vecDir, &trace.ptr, trace.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTraceAttack, &trace);
}

void SC_SERVER_DECL COsprey::Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib)
{
	CALL_ANGELSCRIPT(pMonsterPreKilled, pThis, pevAttacker, &iGib);
	CALL_ORIGIN(g_hookitems.OspreyKilled, Killed, pevAttacker, iGib);
	CALL_ANGELSCRIPT(pMonsterPostKilled, pevAttacker, iGib)
}

void COsprey::Register()
{
	vtable_base_t* vtableBase = AddEntityVTable("monster_osprey");
	ITEM_HOOK(g_hookitems.OspreyTraceAttack, TraceAttack, vtableBase, COsprey::TraceAttack);
	ITEM_HOOK(g_hookitems.OspreyKilled, Killed, vtableBase, COsprey::Killed);
}