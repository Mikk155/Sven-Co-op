#pragma once

typedef struct hookitem_s 
{
	hook_t* pHook;
	void* pfnCall;
	void* pfnOriginalCall;
	vtable_base_t* pVtable;
	vtable_delay_t* pVtableDelay;
	vtable_animating_t* pVtableAnimating;
	vtable_monster_t* pVtableMonster;
	vtable_player_t* pVtablePlayer;
	vtable_physicsobject_t* pVtablPhysicsObject;
	vtable_pickupobject_t* pVtablPickupObject;
	vtable_playeritem_t* pVtablePlayerItem;
	vtable_playerweapon_t* pVtablePlayerWeapon;
}hookitem_t;