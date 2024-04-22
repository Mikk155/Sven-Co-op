#pragma once

class CTurret
{
public:
	static int SC_SERVER_DECL TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType);
	static void SC_SERVER_DECL TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType);
	static void Register();
};