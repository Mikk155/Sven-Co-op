#include <extdll.h>
#include <meta_api.h>
#include <vector>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"
#include "register.h"

int SC_SERVER_DECL CPlayer::TakeHealth(CBasePlayer* pThis, SC_SERVER_DUMMYARG float flDamage, int bitsDamageType, int cap)
{
	healthinfo_t heal = {
		pThis,
		flDamage,
		bitsDamageType,
		cap
	};
	CALL_ANGELSCRIPT(pPlayerPreTakeHealth, &heal);
	int result = CALL_ORIGIN_PLAYER(g_hookitems.PlayerTakeHealth, TakeHealth, heal.flHealth, heal.bitsDamageType, heal.health_cap);
	CALL_ANGELSCRIPT(pPlayerPostTakeHealth, &heal, &result);
	return result;
}

int SC_SERVER_DECL CPlayer::TakeArmor(CBasePlayer* pThis, SC_SERVER_DUMMYARG float flDamage, int bitsDamageType, int cap)
{
	healthinfo_t health = {
		pThis,
		flDamage,
		bitsDamageType,
		cap
	};
	CALL_ANGELSCRIPT(pPlayerPreTakeArmor, &health);
	int result = CALL_ORIGIN_PLAYER(g_hookitems.PlayerTakeArmor, TakeArmor, health.flHealth, health.bitsDamageType, health.health_cap);
	CALL_ANGELSCRIPT(pPlayerPostTakeArmor, &health, &result);
	return result;
}

void SC_SERVER_DECL CPlayer::Revive(CBasePlayer* pThis SC_SERVER_DUMMYARG_NOCOMMA)
{
	CALL_ANGELSCRIPT(pPlayerPreRevive, pThis);
	CALL_ORIGIN_NOARG_PLAYER(g_hookitems.PlayerRevive, Revive);
	CALL_ANGELSCRIPT(pPlayerPostRevive, pThis);
}

void CPlayer::Register()
{
	vtable_player_t* vtablePlayer = AddEntityVTablePlayer("player");
	ITEM_HOOK(g_hookitems.PlayerTakeHealth, TakeHealth, vtablePlayer, CPlayer::TakeHealth);
	ITEM_HOOK(g_hookitems.PlayerTakeArmor, TakeArmor, vtablePlayer, CPlayer::TakeArmor);
	ITEM_HOOK(g_hookitems.PlayerRevive, Revive, vtablePlayer, CPlayer::Revive);
}