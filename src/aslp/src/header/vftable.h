#pragma once
//just type def
typedef void CRestore;
typedef void CSave;
typedef void MonsterEvent;
typedef struct{
	int		iSlot;
	int		iPosition;
	const char* pszAmmo1;	// ammo 1 type
	int		iMaxAmmo1;		// max ammo 1
	const char* pszAmmo2;	// ammo 2 type
	int		iMaxAmmo2;		// max ammo 2
	const char* pszName;
	int		iMaxClip;
	int		iId;
	int		iFlags;
	int		iWeight;// this value used to determine this weapon's importance in autoselection.
} ItemInfo;
typedef void CBaseEntity;
typedef void CBaseMonster;
typedef void CCustomEntity;
typedef void CBasePlayerWeapon;
typedef void CSquadMonster;
using Task_t = struct Task_s {
	int iTask;
	float flValue;
};
using Schedule_t = struct Schedule_s {
	Task_t* pTasklist;
	int		cTasks;
	int		iInterruptMask;// a bit mask of conditions that can interrupt this schedule 

	// a more specific mask that indicates which TYPES of sounds will interrupt the schedule in the 
	// event that the schedule is broken by COND_HEAR_SOUND
	int		iSoundMask;
	const	char* pName;
};

//101
using vtable_base_t = struct vtable_base_s {
	void (SC_SERVER_DECL* PreSpawn)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Spawn)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PostSpawn)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Precache)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* KeyValue)(void* pThis, SC_SERVER_DUMMYARG KeyValueData* pkvd) = nullptr;
	double(SC_SERVER_DECL* GetKeyValue)(void* pThis, SC_SERVER_DUMMYARG char* szKey, int entvartype) = nullptr;
	void (SC_SERVER_DECL* OnKeyValueUpdate)(void* pThis, SC_SERVER_DUMMYARG char* szKey) = nullptr;
	void (SC_SERVER_DECL* Save)(void* pThis, SC_SERVER_DUMMYARG CSave* pSave) = nullptr;
	void (SC_SERVER_DECL* Restore)(void* pThis, SC_SERVER_DUMMYARG CRestore* pRestore) = nullptr;
	int (SC_SERVER_DECL* ObjectCaps)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Activate)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SetObjectCollisionBox)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* GetClassification)(void* pThis, SC_SERVER_DUMMYARG int classify) = nullptr;
	void (SC_SERVER_DECL* GetClassificationTag)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetClassificationName)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* SetClassification)(void* pThis, SC_SERVER_DUMMYARG int classify) = nullptr;
	int (SC_SERVER_DECL* SetClassificationSpecial)(void* pThis, SC_SERVER_DUMMYARG int classify, bool over) = nullptr;
	int (SC_SERVER_DECL* IRelationship)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, bool friendly) = nullptr;
	int (SC_SERVER_DECL* Classify)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* DeathNotice)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevChild) = nullptr;
	void (SC_SERVER_DECL* TraceAttack)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, Vector vecDir, TraceResult* ptr, int bitsDamageType) = nullptr;
	int (SC_SERVER_DECL* TakeDamage)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType) = nullptr;
	int (SC_SERVER_DECL* TakeHealth)(void* pThis, SC_SERVER_DUMMYARG float flHealth, int bitsDamageType, int cap) = nullptr;
	int (SC_SERVER_DECL* TakArmor)(void* pThis, SC_SERVER_DUMMYARG float flHealth, int bitsDamageType, int cap) = nullptr;
	void (SC_SERVER_DECL* Killed)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib) = nullptr;
	int (SC_SERVER_DECL* BloodColor)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* TraceBleed)(void* pThis, SC_SERVER_DUMMYARG float flDamage, Vector vecDir, TraceResult* ptr, int bitsDamageType) = nullptr;
	bool (SC_SERVER_DECL* IsTriggered)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator) = nullptr;
	CBaseMonster* (SC_SERVER_DECL* MyMonsterPointer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CSquadMonster* (SC_SERVER_DECL* MySquadMonsterPointer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CCustomEntity* (SC_SERVER_DECL* MyCustomPointer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CBasePlayerItem* (SC_SERVER_DECL* MyItemPointer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;

	// What fuck baseclass u wanna cast to?
	void* (SC_SERVER_DECL* UnknowCaster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	//

	int (SC_SERVER_DECL* GetToggleState)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* AddPoints)(void* pThis, SC_SERVER_DUMMYARG int score, bool bAllowNegativeScore) = nullptr;
	void (SC_SERVER_DECL* AddPointsToTeam)(void* pThis, SC_SERVER_DUMMYARG int score, bool bAllowNegativeScore) = nullptr;
	bool (SC_SERVER_DECL* AddPlayerItem)(void* pThis, SC_SERVER_DUMMYARG CBasePlayerItem* pItem) = nullptr;
	bool (SC_SERVER_DECL* RemovePlayerItem)(void* pThis, SC_SERVER_DUMMYARG CBasePlayerItem* pItem) = nullptr;
	int (SC_SERVER_DECL* GiveAmmo)(void* pThis, SC_SERVER_DUMMYARG int iAmount, const char* szName, int iMax) = nullptr;
	float (SC_SERVER_DECL* GetDelay)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* IsMoving)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* OverrideReset)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* DamageDecal)(void* pThis, SC_SERVER_DUMMYARG int bitsDamageType) = nullptr;
	void (SC_SERVER_DECL* SetToggleState)(void* pThis, SC_SERVER_DUMMYARG int state) = nullptr;
	void (SC_SERVER_DECL* StartSneaking)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* StopSneaking)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* OnControls)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pev) = nullptr;
	bool (SC_SERVER_DECL* IsSneaking)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsAlive)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsBSPModel)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* ReflectGauss)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;

	// What fuck baseclass u wanna check?
	unsigned int (SC_SERVER_DECL* UnknowCheck)(int* param) = nullptr;

	bool (SC_SERVER_DECL* HasTarget)(void* pThis, SC_SERVER_DUMMYARG string_t targetname) = nullptr;
	bool (SC_SERVER_DECL* IsInWorld)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsMonster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsPlayer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsNetClient)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsPointEnt)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsBreakable)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsMachine)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	const char* (SC_SERVER_DECL* TeamID)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CriticalRemove)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CBaseEntity* (SC_SERVER_DECL* GetNextTarget)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Think)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Touch)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther) = nullptr;
	void (SC_SERVER_DECL* Use)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value) = nullptr;
	void (SC_SERVER_DECL* Blocked)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther) = nullptr;
	void (SC_SERVER_DECL* UpdateOnRemove)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CBaseEntity* (SC_SERVER_DECL* Respawn)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SUB_UseTargets)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value) = nullptr;
	void (SC_SERVER_DECL* IsLockedByMaster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* UpdateOwner)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* FBecomeProne)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector* (SC_SERVER_DECL* Center)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector* (SC_SERVER_DECL* EyePosition)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector* (SC_SERVER_DECL* EarPosition)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector* (SC_SERVER_DECL* BodyTarget)(void* pThis, SC_SERVER_DUMMYARG const Vector& posSrc) = nullptr;
	int (SC_SERVER_DECL* Illumination)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* FVisible)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEntity) = nullptr;
	bool (SC_SERVER_DECL* FVisibleVector)(void* pThis, SC_SERVER_DUMMYARG const Vector& vecOrigin) = nullptr;
	bool (SC_SERVER_DECL* FVisibleFromPos)(void* pThis, SC_SERVER_DUMMYARG Vector* pos, Vector* angle) = nullptr;
	bool (SC_SERVER_DECL* IsFacing)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevOther, float dis) = nullptr;
	float (SC_SERVER_DECL* GetPointsForDamage)(void* pThis, SC_SERVER_DUMMYARG float damage) = nullptr;
	void (SC_SERVER_DECL* GetDamagePoints)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, entvars_t* pevInfictor, float damage) = nullptr;
	void (SC_SERVER_DECL* SetPlayerAlly)(void* pThis, SC_SERVER_DUMMYARG bool dunno) = nullptr;
	void (SC_SERVER_DECL* Deconstructor1)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
#ifndef _WIN32
	void (SC_SERVER_DECL* Deconstructor2)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
#endif // !_WIN32
	void (SC_SERVER_DECL* OnCreate)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* OnDestroy)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* OnSetOriginByMap)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* IsRevivable)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BeginRevive)(void* pThis, SC_SERVER_DUMMYARG float flRespawn) = nullptr;
	void (SC_SERVER_DECL* EndRevive)(void* pThis, SC_SERVER_DUMMYARG float flRespawn) = nullptr;
	int (SC_SERVER_DECL* ShowHUDInfo)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* ShouldDisablePlayerCollisions)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector* (SC_SERVER_DECL* GetAttackVectors)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Teleport)(void* pThis, SC_SERVER_DUMMYARG Vector vecPos, Vector vecAng) = nullptr;
	void (SC_SERVER_DECL* SetTopColor)(void* pThis, SC_SERVER_DUMMYARG int color) = nullptr;
	void (SC_SERVER_DECL* SetBottomColor)(void* pThis, SC_SERVER_DUMMYARG int color) = nullptr;
	void (SC_SERVER_DECL* SetColors)(void* pThis, SC_SERVER_DUMMYARG int topcolor, int bottomcolor) = nullptr;
	int (SC_SERVER_DECL* GetTopColor)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* GetBottomColor)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* UpdateColorMap)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};
//102
using vtable_delay_t = struct vtable_delay_s : vtable_base_s {
	void (SC_SERVER_DECL* DelayThink)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};
//103
using vtable_animating_t = struct vtable_animating_s : vtable_delay_s {
	void (SC_SERVER_DECL* HandleAnimEvent)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA, MonsterEvent* pEvent) = nullptr;
};
using vtable_monster_t = struct vtable_monster_s : vtable_animating_s {
	void (SC_SERVER_DECL* SUB_DoNothing)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Look)(void* pThis, SC_SERVER_DUMMYARG int iDistance) = nullptr;
	void (SC_SERVER_DECL* RunAI)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* IsGibbed)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* ShouldFadeOnDeath)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ChangeYaw)(void* pThis, SC_SERVER_DUMMYARG int yaw) = nullptr;
	void (SC_SERVER_DECL* SetupFriendly)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* MonsterThink)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* MonsterInit)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* MonsterInitDead)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BecomeDead)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Revive)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* StartMonster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BestVisibleEnemy)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* FInViewCone)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther) = nullptr;
	void (SC_SERVER_DECL* FInViewConeVector)(void* pThis, SC_SERVER_DUMMYARG Vector vecPos) = nullptr;
	void (SC_SERVER_DECL* CheckLocalMove)(void* pThis, SC_SERVER_DUMMYARG Vector vecStart, Vector vecEnd, CBaseEntity* pTarget, float* flDist, Vector* param_5, bool param_6) = nullptr;
	void (SC_SERVER_DECL* Move)(void* pThis, SC_SERVER_DUMMYARG float flDist) = nullptr;
	void (SC_SERVER_DECL* MoveExecute)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pTarget, Vector vecEnd, float flDist) = nullptr;
	int (SC_SERVER_DECL* ShouldAdvanceRoute)(void* pThis, SC_SERVER_DUMMYARG float flDist) = nullptr;
	int (SC_SERVER_DECL* GetStoppedActivity)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Stop)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* CheckRangeAttack1)(void* pThis, SC_SERVER_DUMMYARG float flDot, float flDist) = nullptr;
	bool (SC_SERVER_DECL* CheckRangeAttack1_Move)(void* pThis, SC_SERVER_DUMMYARG float flDot, float flDist) = nullptr;
	bool (SC_SERVER_DECL* CheckRangeAttack2)(void* pThis, SC_SERVER_DUMMYARG float flDot, float flDist) = nullptr;
	bool (SC_SERVER_DECL* CheckRangeAttack2_Move)(void* pThis, SC_SERVER_DUMMYARG float flDot, float flDist) = nullptr;
	bool (SC_SERVER_DECL* CheckMeleeAttack1)(void* pThis, SC_SERVER_DUMMYARG float flDot, float flDist) = nullptr;
	bool (SC_SERVER_DECL* CheckMeleeAttack1_Move)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* CheckMeleeAttack2)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* CheckMeleeAttack2_Move)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckTankUsage)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ScheduleFromName)(void* pThis, SC_SERVER_DUMMYARG char* name) = nullptr;
	void (SC_SERVER_DECL* StartTask)(void* pThis, SC_SERVER_DUMMYARG Task_t* name) = nullptr;
	void (SC_SERVER_DECL* RunTask)(void* pThis, SC_SERVER_DUMMYARG int iTask) = nullptr;
	Schedule_t* (SC_SERVER_DECL* GetScheduleOfType)(void* pThis, SC_SERVER_DUMMYARG int type) = nullptr;
	void (SC_SERVER_DECL* GetSchedule)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ScheduleChange)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* CanPlaySequence)(void* pThis, SC_SERVER_DUMMYARG bool bDisregardState, int iInterruptLevel) = nullptr;
	bool (SC_SERVER_DECL* CanPlaySentence)(void* pThis, SC_SERVER_DUMMYARG bool bDisregardState) = nullptr;
	void (SC_SERVER_DECL* PlaySentence)(void* pThis, SC_SERVER_DUMMYARG char* szSentence, float duration, float volume, float attenuation) = nullptr;
	void (SC_SERVER_DECL* PlayScriptedSentence)(void* pThis, SC_SERVER_DUMMYARG char* szSentence, float duration, float volume, float attenuation, bool bConcurrent, CBaseEntity* pListener) = nullptr;
	void (SC_SERVER_DECL* SentenceStop)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetIdealState)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SetActivity)(void* pThis, SC_SERVER_DUMMYARG int iActivity) = nullptr;
	void (SC_SERVER_DECL* SetGaitActivity)(void* pThis, SC_SERVER_DUMMYARG int iActivity) = nullptr;
	void (SC_SERVER_DECL* ReportAIState)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckEnemy)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEnemy) = nullptr;
	void (SC_SERVER_DECL* FTriangulate)(void* pThis, SC_SERVER_DUMMYARG Vector vecStart, Vector vecEnd, float flDist, CBaseEntity* pTargetEnt, Vector* pApex, Vector* param_6, bool param_7) = nullptr;
	void (SC_SERVER_DECL* FTriangulateExtension)(void* pThis, SC_SERVER_DUMMYARG Vector vecStart, Vector vecEnd, float flDist, CBaseEntity* pTargetEnt, Vector* pApex) = nullptr;
	void (SC_SERVER_DECL* SetYawSpeed)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BuildNearestRoute)(void* pThis, SC_SERVER_DUMMYARG Vector vecThreat, Vector vecViewOffset, float flMinDist, float flMaxDist) = nullptr;
	void (SC_SERVER_DECL* FindCover)(void* pThis, SC_SERVER_DUMMYARG Vector vecThreat, Vector vecViewOffset, float flMinDist, float flMaxDis) = nullptr;
	void (SC_SERVER_DECL* FindCoverGrenade)(void* pThis, SC_SERVER_DUMMYARG Vector vecThreat, Vector vecViewOffset, float flMinDist, float flMaxDis) = nullptr;
	void (SC_SERVER_DECL* FindCoverDistance)(void* pThis, SC_SERVER_DUMMYARG Vector vecThreat, Vector vecViewOffset, float flMinDist, float flMaxDis) = nullptr;
	void (SC_SERVER_DECL* FindAttackPoint)(void* pThis, SC_SERVER_DUMMYARG Vector vecThreat, Vector vecViewOffset, float flMinDist, float flMaxDis) = nullptr;
	void (SC_SERVER_DECL* FValidateCover)(void* pThis, SC_SERVER_DUMMYARG Vector vecCoverPos) = nullptr;
	float (SC_SERVER_DECL* CoverRadius)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* FCanCheckAttacks)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckAttacker)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pAttacker) = nullptr;
	void (SC_SERVER_DECL* CheckAmmo)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* IgnoreConditions)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* FValidateHintType)(void* pThis, SC_SERVER_DUMMYARG short shint) = nullptr;
	int (SC_SERVER_DECL* FCanActiveIdle)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* ISoundMask)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PBestSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PBestScent)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	float (SC_SERVER_DECL* HearingSensitivity)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BarnacleVictimBitten)(void* pThis, SC_SERVER_DUMMYARG entvars_t* pevVictim, float flDamage) = nullptr;
	void (SC_SERVER_DECL* BarnacleVictimReleased)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* NoFriendlyFire)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* NoFriendlyFireVector)(void* pThis, SC_SERVER_DUMMYARG Vector vecPos) = nullptr;
	void (SC_SERVER_DECL* NoFriendlyFireVectorEntity)(void* pThis, SC_SERVER_DUMMYARG Vector vecPos, CBaseEntity* pEntity) = nullptr;
	void (SC_SERVER_DECL* NoFriendlyFireToPos)(void* pThis, SC_SERVER_DUMMYARG Vector vecPos) = nullptr;
	void (SC_SERVER_DECL* FVisibleGunPos)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEntity, Vector vecPos) = nullptr;
	void (SC_SERVER_DECL* FInBulletCone)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pEntity, Vector vecPos) = nullptr;
	void (SC_SERVER_DECL* PrescheduleThink)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetDeathActivity)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GibMonster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CallGibMonster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* HasHumanGibs)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* HasAlienGibs)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* FadeMonster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	Vector(SC_SERVER_DECL* GetGunPosition)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckTimeBasedDamage)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ClearTimeBasedDamage)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* DeathSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* AlertSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* IdleSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PainSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* FollowerPlayerUse)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float flValue) = nullptr;
	int (SC_SERVER_DECL* IsPlayerFollowing)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* CanPlayerFollow)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* ShouldStopPlayerFollow)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* LimitFollowers)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pFollow, int maxfollow) = nullptr;
	void (SC_SERVER_DECL* StartPlayerFollowing)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pLeader, bool bFlag) = nullptr;
	void (SC_SERVER_DECL* StopPlayerFollowing)(void* pThis, SC_SERVER_DUMMYARG bool bClearSchedule, bool bFlag) = nullptr;
	void (SC_SERVER_DECL* DeclineFollowing)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* UseSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* UnUseSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* RideMonster)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pRider) = nullptr;
	void (SC_SERVER_DECL* CheckAndApplyGenericAttacks)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* CheckScared)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckCreatureDanger)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckFallDamage)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CheckRevival)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* HandleStep)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PlayStepSound)(void* pThis, SC_SERVER_DUMMYARG int iStep, float volumn) = nullptr;
	void (SC_SERVER_DECL* MedicCallSound)(void* pThis, SC_SERVER_DUMMYARG float flKeep) = nullptr;
};
using vtable_player_t = struct vtable_player_s : vtable_monster_s {
	void (SC_SERVER_DECL* SpecialSpawn)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Jump)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Duck)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PreThink)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PostThink)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* EnteredObserver)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* LeftObserver)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsObserver)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	bool (SC_SERVER_DECL* IsConnected)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* UpdateClientData)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ImpulseCommands)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* IsValidInfoEntity)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther) = nullptr;
	void (SC_SERVER_DECL* LevelEnd)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* VoteStarted)(void* pThis, SC_SERVER_DUMMYARG int votetype) = nullptr;
	bool (SC_SERVER_DECL* CanStartNextVote)(void* pThis, SC_SERVER_DUMMYARG int votetype) = nullptr;
	void (SC_SERVER_DECL* Vote)(void* pThis, SC_SERVER_DUMMYARG int votetype, char* decription) = nullptr;
	bool (SC_SERVER_DECL* HasVoted)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ResetVote)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void* (SC_SERVER_DECL* LastVoteInput)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* InitVote)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* TimeToStartNextVote)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ResetView)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetLogFrequency)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* LogPlayerStats)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};
//109
using vtable_physicsobject_t = struct vtable_physicsobject_s : vtable_animating_s {
	void (SC_SERVER_DECL* WorldInit)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Materialize)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* TouchedWorld)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA, bool touch) = nullptr;
	void (SC_SERVER_DECL* Kill)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetBounceSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* FallInit)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};
//115
using vtable_pickupobject_t = struct vtable_pickupobject_s : vtable_physicsobject_s {
	void (SC_SERVER_DECL* CanCollect)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, int iCollectType) = nullptr;
	void (*__purecall)() = nullptr;
	void (SC_SERVER_DECL* Collected)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, int iCollectTyp) = nullptr;
	void (SC_SERVER_DECL* DefaultUse)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pActivator, CBaseEntity* pCaller, int useType, float value) = nullptr;
	void (SC_SERVER_DECL* Dropped)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA, CBasePlayerItem* pNewEntity) = nullptr;
	float (SC_SERVER_DECL* GetFadeDelay)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};

using vtable_playerammo_t = struct vtable_playerammo_s : vtable_pickupobject_s {
	bool (SC_SERVER_DECL* AddAmmo)(void* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther) = nullptr;
};
//139
using vtable_playeritem_t = struct vtable_playeritem_s : vtable_pickupobject_s {
	int (SC_SERVER_DECL* AddToPlayer)(void* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer) = nullptr;
	int (SC_SERVER_DECL* AddDuplicate)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* AddAmmoFromItem)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	char* (SC_SERVER_DECL* GetPickupSound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* GetItemInfo)(void* pThis, SC_SERVER_DUMMYARG  ItemInfo* pItemInfo) = nullptr;
	int (SC_SERVER_DECL* CanDeploy)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* Deploy)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* CanHolster)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Holster)(void* pThis, SC_SERVER_DUMMYARG int skiplocal) = nullptr;
	void (SC_SERVER_DECL* UpdateItemInfo)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ItemPreFrame)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ItemPostFrame)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* InactiveItemPreFrame)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* InactiveItemPostFrame)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* AttachToPlayer)(void* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer) = nullptr;
	void (SC_SERVER_DECL* DetachFromPlayer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* PrimaryAmmoIndex)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* SecondaryAmmoIndex)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* UpdateClientData)(void* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer) = nullptr;
	CBasePlayerWeapon* (SC_SERVER_DECL* GetWeaponPtr)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* iItemSlot)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	float (SC_SERVER_DECL* GetRespawnTime)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	CBasePlayerItem* (SC_SERVER_DECL* DropItem)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* CanHaveDuplicates)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
};
//175
using vtable_playerweapon_t = struct vtable_playerweapon_s : vtable_playeritem_s {
	void (SC_SERVER_DECL* ExtractAmmoFromItem)(void* pThis, SC_SERVER_DUMMYARG CBasePlayerItem* pItem) = nullptr;
	void (SC_SERVER_DECL* ExtractAmmo)(void* pThis, SC_SERVER_DUMMYARG CBasePlayerWeapon* pOtherWeapon) = nullptr;
	int (SC_SERVER_DECL* ExtractClipAmmo)(void* pThis, SC_SERVER_DUMMYARG CBasePlayerWeapon* pOtherWeapon) = nullptr;
	int (SC_SERVER_DECL* AddWeapon)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* GetAmmo1Drop)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* GetAmmo2Drop)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PlayEmptySound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ResetEmptySound)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SendWeaponAnim)(void* pThis, SC_SERVER_DUMMYARG int index, int skiplocal, int body) = nullptr;
	void (SC_SERVER_DECL* BulletAccuracy)(void* pThis, SC_SERVER_DUMMYARG Vector vecMoving, Vector vecStanding, Vector vecCrouched) = nullptr;
	int (SC_SERVER_DECL* IsUseable)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* PrimaryAttack)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SecondaryAttack)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* TertiaryAttack)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* Reload)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* FinishReload)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* ShouldReload)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* WeaponIdle)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* RetireWeapon)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* ShouldWeaponIdle)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* UseDecrement)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* BurstSupplement)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetP_Model)(void* pThis, SC_SERVER_DUMMYARG char* szOut) = nullptr;
	void (SC_SERVER_DECL* GetW_Model)(void* pThis, SC_SERVER_DUMMYARG char* szOut) = nullptr;
	void (SC_SERVER_DECL* GetV_Model)(void* pThis, SC_SERVER_DUMMYARG char* szOut) = nullptr;
	void (SC_SERVER_DECL* PrecacheCustomModels)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* GetWeaponData)(void* pThis, SC_SERVER_DUMMYARG weapon_data_s* pData) = nullptr;
	void (SC_SERVER_DECL* SetWeaponData)(void* pThis, SC_SERVER_DUMMYARG weapon_data_s* pData) = nullptr;
	void (SC_SERVER_DECL* IsMultiplayer)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	int (SC_SERVER_DECL* FRunfuncs)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* SetFOV)(void* pThis, SC_SERVER_DUMMYARG int iFOV) = nullptr;
	int (SC_SERVER_DECL* FRunfuncs2)(void* pThis SC_SERVER_DUMMYARG_NOCOMMA) = nullptr;
	void (SC_SERVER_DECL* CustomDecrement)(void* pThis, SC_SERVER_DUMMYARG float flDecrement) = nullptr;
	void (SC_SERVER_DECL* SetV_Model)(void* pThis, SC_SERVER_DUMMYARG char* szModel) = nullptr;
	void (SC_SERVER_DECL* SetP_Model)(void* pThis, SC_SERVER_DUMMYARG char* szModel) = nullptr;
	void (SC_SERVER_DECL* ChangeWeaponSkin)(void* pThis, SC_SERVER_DUMMYARG short iskin) = nullptr;
};

vtable_base_t* GetEntityVTable(const char* szClassName);
vtable_base_s* AddEntityVTable(const char* szClassName);