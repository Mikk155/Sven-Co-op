#pragma once

class CSentry
{
public:
	static int SC_SERVER_DECL TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType);
	static void SC_SERVER_DECL Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib);
	static void Register();
};