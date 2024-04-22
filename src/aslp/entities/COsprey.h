#pragma once

class COsprey
{
public:
	static void SC_SERVER_DECL TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType);
	static void SC_SERVER_DECL Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib);
	static void Register();
};