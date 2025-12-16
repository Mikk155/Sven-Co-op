#pragma once
void RegisterAngelScriptMethods();
void RegisterAngelScriptHooks();
void CloseAngelScriptsItem();

typedef struct addtofullpack_s{
	entity_state_s* state;
	int entityIndex;
	edict_t* entity;
	edict_t* host;
	int hostFlags;
	int playerIndex;
	bool Result;
}addtofullpack_t;

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
	void* pCientCommandHook = nullptr;
	void* pPlayerUserInfoChanged = nullptr;
	void* pPreMovement = nullptr;
	void* pPostMovement = nullptr;
	void* pPreAddToFullPack = nullptr;
	void* pPostAddToFullPack = nullptr;
	void* pPostEntitySpawn = nullptr;
	void* pShouldCollide = nullptr;

	void* pPlayerPostTakeDamage = nullptr;
	void* pPlayerTakeHealth = nullptr;
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