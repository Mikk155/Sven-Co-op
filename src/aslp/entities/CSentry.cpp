#include <extdll.h>
#include <meta_api.h>
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

int SC_SERVER_DECL CSentry::TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType)
{
	damageinfo_t dmg = {
		pThis,
		GetEntVarsVTable(pevInflictor),
		GetEntVarsVTable(pevAttacker),
		flDamage,
		bitsDamageType
	};

	CALL_ANGELSCRIPT(pMonsterPreTakeDamage, &dmg);
	int result = CALL_ORIGIN(g_hookitems.SentryTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
	CALL_ANGELSCRIPT(pMonsterPostTakeDamage, &dmg, &result);
	return result;
}

void SC_SERVER_DECL CSentry::Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib)
{
	CALL_ANGELSCRIPT(pMonsterPreKilled, pThis, pevAttacker, &iGib)
	CALL_ORIGIN(g_hookitems.SentryKilled, Killed, pevAttacker, iGib);
	CALL_ANGELSCRIPT(pMonsterPostKilled, pevAttacker, iGib)
}

void CSentry::Register()
{
	vtable_base_t* vtableBase = AddEntityVTable("monster_sentry");
	ITEM_HOOK(g_hookitems.SentryTakeDamage, TakeDamage, vtableBase, CSentry::TakeDamage);
	ITEM_HOOK(g_hookitems.SentryKilled, Killed, vtableBase, CSentry::Killed);
}