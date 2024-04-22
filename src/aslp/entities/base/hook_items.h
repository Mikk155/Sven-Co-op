#pragma once

extern struct g_hookitems_t
{
	/*Player*/
	hookitem_t PlayerTakeHealth;
	hookitem_t PlayerTakeArmor;
	hookitem_t PlayerRevive;
	hookitem_t PlayerDropWeapon;
	hookitem_t PlayerGetItemInfo;

	/*Apache*/
	hookitem_t ApacheTraceAttack;
	hookitem_t ApacheTakeDamage;
	hookitem_t ApacheKilled;

	/*Osprey*/
	hookitem_t OspreyTraceAttack;
	hookitem_t OspreyKilled;

	/*Sentry*/
	hookitem_t SentryTakeDamage;
	hookitem_t SentryTraceAttack;
	hookitem_t SentryKilled;

	/*Turret*/
	hookitem_t TurretTakeDamage;
	hookitem_t TurretTraceAttack;

	/*Monsters*/
	hookitem_t BaseMonsterTakeDamage;
	hookitem_t BaseMonsterTraceAttack;
	hookitem_t BaseMonsterKilled;
	hookitem_t BaseMonsterUse;
	hookitem_t BaseMonsterRevive;
	hookitem_t BaseMonsterPlaySentence;
	hookitem_t BaseMonsterCheckEnemy;
} g_hookitems;

extern std::vector<hook_t*> g_hooks;