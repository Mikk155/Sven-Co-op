#pragma once

template <typename T>
class CBasePlayerItemTemplate : public CBasePickupObjectTemplate<T>
{
public:
	int SC_SERVER_DECL AddToPlayer(T* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer);
	int SC_SERVER_DECL AddDuplicate(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL AddAmmoFromItem(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	char* SC_SERVER_DECL GetPickupSound(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL GetItemInfo(T* pThis, SC_SERVER_DUMMYARG  ItemInfo* pItemInfo);
	int SC_SERVER_DECL CanDeploy(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL Deploy(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL CanHolster(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL Holster(T* pThis, SC_SERVER_DUMMYARG int skiplocal);
	void SC_SERVER_DECL UpdateItemInfo(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ItemPreFrame(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ItemPostFrame(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL InactiveItemPreFrame(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL InactiveItemPostFrame(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL AttachToPlayer(T* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer);
	void SC_SERVER_DECL DetachFromPlayer(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL PrimaryAmmoIndex(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL SecondaryAmmoIndex(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL UpdateClientData(T* pThis, SC_SERVER_DUMMYARG CBasePlayer* pPlayer);
	CBasePlayerWeapon* SC_SERVER_DECL GetWeaponPtr(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL iItemSlot(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	float SC_SERVER_DECL GetRespawnTime(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	CBasePlayerItem* SC_SERVER_DECL DropItem(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL CanHaveDuplicates(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
};