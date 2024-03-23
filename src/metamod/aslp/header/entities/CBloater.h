#pragma once

class CBloater
{
public:
	static int SC_SERVER_DECL TakeDamage(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType);
	static void SC_SERVER_DECL TraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType);
	static void SC_SERVER_DECL Killed(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib);
	static void SC_SERVER_DECL Use(CBaseMonster* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value);
	static void SC_SERVER_DECL Revive(CBaseMonster* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	static void SC_SERVER_DECL PlaySentence(CBaseMonster* pThis, SC_SERVER_DUMMYARG char* szSentence, float duration, float volume, float attenuation);
	static void SC_SERVER_DECL CheckEnemy(CBaseMonster* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEnemy);
	static void Register();
};