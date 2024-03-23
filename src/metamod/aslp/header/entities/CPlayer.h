#pragma once

class CPlayer
{
public:
	static int SC_SERVER_DECL TakeHealth(CBasePlayer* pThis, SC_SERVER_DUMMYARG float flDamage, int bitsDamageType, int cap);
	static int SC_SERVER_DECL TakeArmor(CBasePlayer* pThis, SC_SERVER_DUMMYARG float flDamage, int bitsDamageType, int cap);
	static void SC_SERVER_DECL Revive(CBasePlayer* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	static void Register();
};