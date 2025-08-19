#include <map>

#include <extdll.h>
#include <meta_api.h>
#include "asext_api.h"
#include "vftable.h"

std::map<const char*, vtable_base_t*> g_vtableMap;

vtable_base_t* GetEntityVTable(const char* szClassName) {
	if (g_vtableMap.count(szClassName))
		return g_vtableMap[szClassName];
	return nullptr;
}
vtable_base_t* AddEntityVTable(const char* szClassName) {
	if (g_vtableMap.count(szClassName))
		return g_vtableMap[szClassName];
	edict_t* tentEntity = CREATE_ENTITY();
	CALL_GAME_ENTITY(PLID, szClassName, &tentEntity->v);
	if (tentEntity->pvPrivateData == NULL){
		REMOVE_ENTITY(tentEntity);
		LOG_ERROR(PLID, "Entity %s is null! can not get vtable!", szClassName);
		return nullptr;
	}
	vtable_base_t* table = *(vtable_base_t**)tentEntity->pvPrivateData;
	g_vtableMap[szClassName] = table;
	REMOVE_ENTITY(tentEntity);
	return table;
}