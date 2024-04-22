#include <extdll.h>
#include <meta_api.h>
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

int SC_SERVER_DECL CTurret::TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType)
{
	damageinfo_t dmg = {
		pThis,
		GetEntVarsVTable(pevInflictor),
		GetEntVarsVTable(pevAttacker),
		flDamage,
		bitsDamageType
	};

	CALL_ANGELSCRIPT(pMonsterPreTakeDamage, &dmg);
	int result = CALL_ORIGIN(g_hookitems.TurretTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTakeDamage, &dmg, &result);
	return result;
}

void SC_SERVER_DECL CTurret::TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType)
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
	CALL_ORIGIN(g_hookitems.TurretTraceAttack, TraceAttack, pevAttacker, trace.flDamage, trace.vecDir, &trace.ptr, trace.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTraceAttack, &trace);
}

void CTurret::Register()
{
	vtable_base_s* vtableBase = AddEntityVTable("monster_turret");
	ITEM_HOOK(g_hookitems.TurretTraceAttack, TraceAttack, vtableBase, CTurret::TraceAttack);
	ITEM_HOOK(g_hookitems.TurretTakeDamage, TakeDamage, vtableBase, CTurret::TakeDamage);
}