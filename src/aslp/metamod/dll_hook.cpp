#include <map>
#include <vector>
#include <string>

#include <extdll.h>
#include <meta_api.h>

#include "asext_api.h"
#include "aslp.h"
#include "vftable.h"

#include "utility.h"

#pragma region GMR
std::map<std::string, std::string> g_dicGMRmap;
void LoadGMRFromCFG() {
	g_dicGMRmap.clear();
	char mappath[MAX_PATH];
	const char* mapname = STRING(gpGlobals->mapname);
	sprintf_s(mappath, "maps/%s.cfg", mapname);
	int filesize = 0;
	byte* membuf = g_engfuncs.pfnLoadFileForMe(mappath, &filesize);
	if (!membuf)
		return;
	std::string gmrpath;
	const char* delim = "\n";
	char* tokstarter = reinterpret_cast<char*>(membuf);
	char* next_line = strtok(tokstarter, delim);
	while (next_line != nullptr) {
		if (!strncmp(next_line, "globalmodellist", 15)) {
			next_line += 15;
			while (isspace(*next_line) || *next_line == '\"') {
				next_line++;
			}
			if (*next_line == '\0')
				return;
			char* end = next_line + strlen(next_line) - 1;
			while (end > next_line && (isspace(*end) || *end == '\"')) {
				end--;
			}
			*(end + 1) = '\0';
			gmrpath = next_line;
			break;
		}
		next_line = strtok(nullptr, delim);
	}
	g_engfuncs.pfnFreeFile(membuf);

	//read gmr
	if (gmrpath.size() == 0)
		return;
	gmrpath = "models/" + std::string(mapname) + "/" + gmrpath;
	byte* gmrbuf = g_engfuncs.pfnLoadFileForMe(const_cast<char*>(gmrpath.c_str()), &filesize);
	if (!gmrbuf)
		return;
	std::string key;
	std::string value;
	tokstarter = reinterpret_cast<char*>(gmrbuf);
	next_line = strtok(tokstarter, delim);
	while (next_line != nullptr) {
		key.clear();
		value.clear();

		bool has_quote = false;
		if (*next_line == '\"') {
			next_line++;
			has_quote = true;
		}
		if (has_quote) {
			while (*next_line != '\"') {
				key += *next_line;
				next_line++;
			}
		}
		else {
			while (!isspace(*next_line)) {
				key += *next_line;
				next_line++;
			}
		}
		while (isspace(*next_line) || *next_line == '\"') {
			next_line++;
		}
		char* end = next_line + strlen(next_line) - 1;
		while (end > next_line && (isspace(*end) || *end == '\"')) {
			end--;
		}
		*(end + 1) = '\0';
		value = next_line;
		if (key.size() > 0 && value.size() > 0)
			g_dicGMRmap.insert(std::make_pair(key, value));
		next_line = strtok(nullptr, delim);
	}
	g_engfuncs.pfnFreeFile(gmrbuf);
}

#pragma endregion

typedef struct hookitem_s {
	hook_t* pHook;
	void* pfnCall;
	void* pfnOriginalCall;
	vtable_base_t* pVtable;
}hookitem_t;
struct {
	hookitem_t BaseMonsterTraceAttack;
	hookitem_t BaseMonsterTakeDamage;

	hookitem_t ApacheTraceAttack;
	hookitem_t OspreyTraceAttack;
	hookitem_t TurretTraceAttack;
	hookitem_t BreakableTraceAttack;

	hookitem_t PlayerPostTakeDamage;
	hookitem_t PlayerTakeHealth;

	hookitem_t BreakableKilled;
	hookitem_t BreakableTakeDamage;

	hookitem_t IRelationship;
} gHookItems;
static std::vector<hook_t*> gHooks;

#pragma region New Functions
#define CALL_ANGELSCRIPT(pfn, ...) if (ASEXT_CallHook){(*ASEXT_CallHook)(g_AngelHook.pfn, 0, __VA_ARGS__);}
#define CALL_ORIGIN(item, type, ...) ((decltype(item.pVtable->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG(item, type) ((decltype(item.pVtable->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
static int SC_SERVER_DECL BaseMonsterTakeDamage(CBaseEntity* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType) {
	int ret = CALL_ORIGIN(gHookItems.BaseMonsterTakeDamage, TakeDamage, pevInflictor, pevAttacker, flDamage, bitsDamageType);
	damageinfo_t dmg = {
			pThis,
			GetEntVarsVTable(pevInflictor),
			GetEntVarsVTable(pevAttacker),
			flDamage,
			bitsDamageType
	};
	CALL_ANGELSCRIPT(pMonsterPostTakeDamage, &dmg)
		return ret;
}
static void SC_SERVER_DECL BaseMonsterTraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType) {
	edict_t* ent = PrivateToEdict(pThis);
	if (ent) {
		entvars_t* var = &ent->v;
		if (var->flags & FL_MONSTER)
			CALL_ANGELSCRIPT(pMonsterTraceAttack, pThis, pevAttacker, flDamage, &vecDir, ptr, bitsDamageType);
	}
	CALL_ORIGIN(gHookItems.BaseMonsterTraceAttack, TraceAttack, pevAttacker, flDamage, vecDir, ptr, bitsDamageType);
}
static void SC_SERVER_DECL ApacheTraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType) {
	CALL_ANGELSCRIPT(pMonsterTraceAttack, pThis, pevAttacker, flDamage, &vecDir, ptr, bitsDamageType);
	CALL_ORIGIN(gHookItems.ApacheTraceAttack, TraceAttack, pevAttacker, flDamage, vecDir, ptr, bitsDamageType);
}
static void SC_SERVER_DECL OspreyTraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType) {
	CALL_ANGELSCRIPT(pMonsterTraceAttack, pThis, pevAttacker, flDamage, &vecDir, ptr, bitsDamageType);
	CALL_ORIGIN(gHookItems.OspreyTraceAttack, TraceAttack, pevAttacker, flDamage, vecDir, ptr, bitsDamageType);
}
static void SC_SERVER_DECL TurretTraceAttack(CBaseMonster* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType) {
	CALL_ANGELSCRIPT(pMonsterTraceAttack, pThis, pevAttacker, flDamage, &vecDir, ptr, bitsDamageType);
	CALL_ORIGIN(gHookItems.TurretTraceAttack, TraceAttack, pevAttacker, flDamage, vecDir, ptr, bitsDamageType);
}
static void SC_SERVER_DECL BreakableTraceAttack(CBaseEntity* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, float flDamage, vec3_t vecDir, TraceResult* ptr, int bitsDamageType) {
	CALL_ANGELSCRIPT(pBreakableTraceAttack, pThis, pevAttacker, flDamage, &vecDir, ptr, bitsDamageType);
	CALL_ORIGIN(gHookItems.BreakableTraceAttack, TraceAttack, pevAttacker, flDamage, vecDir, ptr, bitsDamageType);
}
static void SC_SERVER_DECL BreakableKilled(CBaseEntity* pThis, SC_SERVER_DUMMYARG entvars_t* pevAttacker, int iGib) {
	CALL_ANGELSCRIPT(pBreakableKilled, pThis, pevAttacker, iGib);
	CALL_ORIGIN(gHookItems.BreakableKilled, Killed, pevAttacker, iGib);
}
static int SC_SERVER_DECL BreakableTakeDamage(CBaseEntity* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType) {
	damageinfo_t dmg = {
			pThis,
			GetEntVarsVTable(pevInflictor),
			GetEntVarsVTable(pevAttacker),
			flDamage,
			bitsDamageType
	};
	CALL_ANGELSCRIPT(pBreakableTakeDamage, &dmg)
		return CALL_ORIGIN(gHookItems.BreakableTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
}
static int SC_SERVER_DECL PlayerPostTakeDamage(CBasePlayer* pThis, SC_SERVER_DUMMYARG entvars_t* pevInflictor, entvars_t* pevAttacker, float flDamage, int bitsDamageType) {
	damageinfo_t dmg = {
			pThis,
			GetEntVarsVTable(pevInflictor),
			GetEntVarsVTable(pevAttacker),
			flDamage,
			bitsDamageType
	};
	int result = CALL_ORIGIN(gHookItems.PlayerPostTakeDamage, TakeDamage, pevInflictor, pevAttacker, dmg.flDamage, dmg.bitsDamageType);
	CALL_ANGELSCRIPT(pPlayerPostTakeDamage, &dmg);
	return result;
}
static int SC_SERVER_DECL PlayerTakeHealth(CBasePlayer* pThis, SC_SERVER_DUMMYARG float flDamage, int bitsDamageType, int cap) {
	healthinfo_t dmg = {
		pThis,
		flDamage,
		bitsDamageType,
		cap
	};
	CALL_ANGELSCRIPT(pPlayerTakeHealth, &dmg);
	return CALL_ORIGIN(gHookItems.PlayerTakeHealth, TakeHealth, dmg.flHealth, dmg.bitsDamageType, dmg.health_cap);
}
static int SC_SERVER_DECL IRelationship(CBasePlayer* pThis, SC_SERVER_DUMMYARG CBaseEntity* pOther, bool param_2) {
	int iNewReturn = 114514;
	CALL_ANGELSCRIPT(pEntityIRelationship, pThis, pOther, param_2, &iNewReturn);
	return iNewReturn == 114514 ? CALL_ORIGIN(gHookItems.IRelationship, IRelationship, pOther, param_2) : iNewReturn;
}
#pragma endregion

#pragma region VTableHooks
void VTableHook() {
#define ITEM_HOOK(item, type, table, newfunc) item.pfnOriginalCall=item.pfnCall=(void*)table->type;item.pVtable=table;item.pHook=gpMetaUtilFuncs->pfnInlineHook(item.pfnCall,(void*)newfunc,(void**)&item.pfnOriginalCall,false);gHooks.push_back(item.pHook)
	vtable_base_t* vtable = AddEntityVTable("monster_apache");
	ITEM_HOOK(gHookItems.ApacheTraceAttack, TraceAttack, vtable, ApacheTraceAttack);
	vtable = AddEntityVTable("monster_osprey");
	ITEM_HOOK(gHookItems.OspreyTraceAttack, TraceAttack, vtable, OspreyTraceAttack);
	vtable = AddEntityVTable("monster_turret");
	ITEM_HOOK(gHookItems.TurretTraceAttack, TraceAttack, vtable, TurretTraceAttack);
	vtable = AddEntityVTable("func_breakable");
	ITEM_HOOK(gHookItems.BreakableTraceAttack, TraceAttack, vtable, BreakableTraceAttack);
	ITEM_HOOK(gHookItems.BreakableTakeDamage, TakeDamage, vtable, BreakableTakeDamage);
	ITEM_HOOK(gHookItems.BreakableKilled, Killed, vtable, BreakableKilled);
	vtable = AddEntityVTable("monster_bloater");
	ITEM_HOOK(gHookItems.BaseMonsterTraceAttack, TraceAttack, vtable, BaseMonsterTraceAttack);
	vtable = AddEntityVTable("player");
	ITEM_HOOK(gHookItems.PlayerPostTakeDamage, TakeDamage, vtable, PlayerPostTakeDamage);
	ITEM_HOOK(gHookItems.PlayerTakeHealth, TakeHealth, vtable, PlayerTakeHealth);
	ITEM_HOOK(gHookItems.IRelationship, IRelationship, vtable, IRelationship);
}

void VtableUnhook() {
	for (auto iter = gHooks.begin(); iter != gHooks.end(); iter++) {
		if (*iter) {
			gpMetaUtilFuncs->pfnUnHook(*iter);
			*iter = nullptr;
		}
	}
	gHooks.clear();
}
#pragma endregion