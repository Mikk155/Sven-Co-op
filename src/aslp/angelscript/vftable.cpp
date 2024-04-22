#include <extdll.h>
#include <meta_api.h>
#include <map>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"

std::map<const char*, vtable_base_t*> g_vtableMap;
std::map<const char*, vtable_animating_t*> g_vtableAnimatingMap;
std::map<const char*, vtable_monster_t*> g_vtableMonsterMap;
std::map<const char*, vtable_player_t*> g_vtablePlayerMap;
std::map<const char*, vtable_playeritem_t*> g_vtablePlayerItemMap;
std::map<const char*, vtable_playerweapon_t*> g_vtablePlayerWeaponMap;

template<typename T>
T* GetEntityVTable(const char* szClassName, std::map<const char*, T*>& vtableMap)
{
    if (vtableMap.count(szClassName))
        return vtableMap[szClassName];
    return nullptr;
}

template<typename T>
T* AddEntityVTable(const char* szClassName, std::map<const char*, T*>& vtableMap)
{
    if (vtableMap.count(szClassName))
        return vtableMap[szClassName];

    edict_t* tentEntity = CREATE_ENTITY();
    CALL_GAME_ENTITY(PLID, szClassName, &tentEntity->v);

    if (tentEntity->pvPrivateData == nullptr) {
        REMOVE_ENTITY(tentEntity);
        LOG_ERROR(PLID, "Entity %s is null! can not get vtable!", szClassName);
        return nullptr;
    }

    T* table = *(T**)tentEntity->pvPrivateData;
    vtableMap[szClassName] = table;
    REMOVE_ENTITY(tentEntity);
    return table;
}

/*
* GetEntity
*/
vtable_base_t* GetEntityVTable(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtableMap);
}

vtable_animating_t* GetEntityVTableAnimating(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtableAnimatingMap);
}

vtable_monster_t* GetEntityVTableMonster(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtableMonsterMap);
}

vtable_player_t* GetEntityVTablePlayer(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtablePlayerMap);
}

vtable_playeritem_t* GetEntityVTablePlayerItem(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtablePlayerItemMap);
}

vtable_playerweapon_t* GetEntityVTablePlayerWeapon(const char* szClassName) {
    return GetEntityVTable(szClassName, g_vtablePlayerWeaponMap);
}

/*
* AddEntity
*/
vtable_base_t* AddEntityVTable(const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtableMap);
}

vtable_animating_t* AddEntityVTableAnimating(const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtableAnimatingMap);
}

vtable_monster_t* AddEntityVTableMonster (const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtableMonsterMap);
}

vtable_player_t* AddEntityVTablePlayer(const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtablePlayerMap);
}

vtable_playeritem_t* AddEntityVTablePlayerItem(const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtablePlayerItemMap);
}

vtable_playerweapon_t* AddEntityVTablePlayerWeapon(const char* szClassName) {
    return AddEntityVTable(szClassName, g_vtablePlayerWeaponMap);
}