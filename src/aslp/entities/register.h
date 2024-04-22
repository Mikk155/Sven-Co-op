#pragma once

#include "../angelscript/vftable.h"
#include "base/hook_items.h"

#define CALL_ANGELSCRIPT(pfn, ...) if (ASEXT_CallHook){(*ASEXT_CallHook)(g_AngelHook.pfn, 0, __VA_ARGS__);}
#define CALL_ORIGIN(item, type, ...) ((decltype(item.pVtable->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG(item, type) ((decltype(item.pVtable->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define CALL_ORIGIN_ANIMATING(item, type, ...) ((decltype(item.pVtableAnimating->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG_ANIMATING(item, type) ((decltype(item.pVtableAnimating->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define CALL_ORIGIN_MONSTER(item, type, ...) ((decltype(item.pVtableMonster->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG_MONSTER(item, type) ((decltype(item.pVtableMonster->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define CALL_ORIGIN_PLAYER(item, type, ...) ((decltype(item.pVtablePlayer->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG_PLAYER(item, type) ((decltype(item.pVtablePlayer->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define CALL_ORIGIN_PLAYERITEM(item, type, ...) ((decltype(item.pVtablePlayerItem->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG_PLAYERITEM(item, type) ((decltype(item.pVtablePlayerItem->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define CALL_ORIGIN_PLAYERWEAPON(item, type, ...) ((decltype(item.pVtablePlayerWeapon->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG __VA_ARGS__)
#define CALL_ORIGIN_NOARG_PLAYERWEAPON(item, type) ((decltype(item.pVtablePlayerWeapon->type))item.pfnOriginalCall)(pThis, SC_SERVER_PASS_DUMMYARG_NOCOMMA)
#define ITEM_HOOK(item, type, table, newfunc) item.pfnOriginalCall=item.pfnCall=(void*)table->type;item.pVtable=table;item.pHook=gpMetaUtilFuncs->pfnInlineHook(item.pfnCall,(void*)newfunc,(void**)&item.pfnOriginalCall,false);g_hooks.push_back(item.pHook)

#include "CPlayer.h"
#include "CSentry.h"
#include "CApache.h"
#include "CBloater.h"
#include "CTurret.h"
#include "COsprey.h"