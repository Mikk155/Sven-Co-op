#pragma once
void RegisterAngelScriptMethods();
void RegisterAngelScriptHooks();
void CloseAngelScriptsItem();

typedef struct damageinfo_s{
	void* pVictim;
	void* pInflictor;
	void* pAttacker;
	float flDamage;
	int bitsDamageType;
}damageinfo_t;

typedef struct healthinfo_s {
	void* pEntity;
	float flHealth;
	int bitsDamageType;
	int health_cap;
}healthinfo_t;

typedef struct angelhook_s {
	void* pPlayerUserInfoChanged = nullptr;
	void* pPlayerPostTakeDamage = nullptr;
	void* pPlayerTakeHealth = nullptr;
	void* pPlayerCallMedic = nullptr;
	void* pPlayerCallGrenade = nullptr;

	void* pEntitySpawn = nullptr;
	
	void* pMonsterSpawn = nullptr;
	void* pMonsterTraceAttack = nullptr;
	void* pMonsterPostTakeDamage = nullptr;

	void* pBreakableTraceAttack = nullptr;
	void* pBreakableKilled = nullptr;
	void* pBreakableTakeDamage = nullptr;

	void* pGrappleCheckMonsterType = nullptr;

	//void* pSendScoreInfo = nullptr;

	void* pEntityIRelationship = nullptr;
}angelhook_t;
extern angelhook_t g_AngelHook;