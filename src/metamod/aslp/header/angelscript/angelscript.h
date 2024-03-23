#pragma once

#include "vftable.h"
#include "dlldef.h"
#include "utility.h"

typedef struct traceinfo_s
{
	void* pVictim;
	void* pInflictor;
	float flDamage;
	vec3_t vecDir;
	TraceResult ptr;
	int bitsDamageType;
}traceinfo_t;

typedef struct damageinfo_s
{
	void* pVictim;
	void* pInflictor;
	void* pAttacker;
	float flDamage;
	int bitsDamageType;
}damageinfo_t;

typedef struct healthinfo_s
{
	void* pEntity;
	float flHealth;
	int bitsDamageType;
	int health_cap;
}healthinfo_t;

typedef struct angelhook_s
{
	/*Function Table*/
	void* pThink = nullptr;
	void* pTouch = nullptr;
	void* pBlocked = nullptr;
	void* pKeyValue = nullptr;
	void* pClientCommand = nullptr;
	void* pPM_Move = nullptr;
	void* pAddToFullPack = nullptr;

	/*Function Table Post*/
	void* pThink_Post = nullptr;
	void* pAddToFullPack_Post = nullptr;

	/*New DLL Function Table*/
	void* pShouldCollide = nullptr;

	/*Player*/
	void* pPlayerPreTakeHealth = nullptr;
	void* pPlayerPostTakeHealth = nullptr;
	void* pPlayerPreTakeArmor = nullptr;
	void* pPlayerPostTakeArmor = nullptr;
	void* pPlayerPreRevive = nullptr;
	void* pPlayerPostRevive = nullptr;
	void* pPlayerPreDropWeapon = nullptr;
	void* pPlayerPostDropWeapon = nullptr;
	void* pPlayerGetItemInfo = nullptr;

	/*Monsters*/
	void* pMonsterPreTakeDamage = nullptr;
	void* pMonsterPostTakeDamage = nullptr;
	void* pMonsterPreTraceAttack = nullptr;
	void* pMonsterPostTraceAttack = nullptr;
	void* pMonsterPreKilled = nullptr;
	void* pMonsterPostKilled = nullptr;
	void* pMonsterPreUse = nullptr;
	void* pMonsterPostUse = nullptr;
	void* pMonsterPreRevive = nullptr;
	void* pMonsterPostRevive = nullptr;
	void* pMonsterPrePlaySentence = nullptr;
	void* pMonsterPostPlaySentence = nullptr;
	void* pMonsterPreCheckEnemy = nullptr;
	void* pMonsterPostCheckEnemy = nullptr;

}angelhook_t;

extern angelhook_t g_AngelHook;
