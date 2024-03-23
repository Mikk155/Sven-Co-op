#pragma once

template <typename T>
class CBasePlayerWeaponTemplate : public CBasePlayerItemTemplate<T>
{
public:
	void SC_SERVER_DECL ExtractAmmoFromItem(T* pThis, SC_SERVER_DUMMYARG CBasePlayerItem* pItem);
	void SC_SERVER_DECL ExtractAmmo(T* pThis, SC_SERVER_DUMMYARG CBasePlayerWeapon* pOtherWeapon);
	int SC_SERVER_DECL ExtractClipAmmo(T* pThis, SC_SERVER_DUMMYARG CBasePlayerWeapon* pOtherWeapon);
	int SC_SERVER_DECL AddWeapon(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL GetAmmo1Drop(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL GetAmmo2Drop(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL PlayEmptySound(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ResetEmptySound(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL SendWeaponAnim(T* pThis, SC_SERVER_DUMMYARG int index, int skiplocal, int body);
	void SC_SERVER_DECL BulletAccuracy(T* pThis, SC_SERVER_DUMMYARG Vector vecMoving, Vector vecStanding, Vector vecCrouched);
	int SC_SERVER_DECL IsUseable(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL PrimaryAttack(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL SecondaryAttack(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL TertiaryAttack(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL Reload(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL FinishReload(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL ShouldReload(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL WeaponIdle(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL RetireWeapon(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL ShouldWeaponIdle(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL UseDecrement(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL BurstSupplement(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL GetP_Model(T* pThis, SC_SERVER_DUMMYARG char* szOut);
	void SC_SERVER_DECL GetW_Model(T* pThis, SC_SERVER_DUMMYARG char* szOut);
	void SC_SERVER_DECL GetV_Model(T* pThis, SC_SERVER_DUMMYARG char* szOut);
	void SC_SERVER_DECL PrecacheCustomModels(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL GetWeaponData(T* pThis, SC_SERVER_DUMMYARG weapon_data_s* pData);
	void SC_SERVER_DECL SetWeaponData(T* pThis, SC_SERVER_DUMMYARG weapon_data_s* pData);
	void SC_SERVER_DECL IsMultiplayer(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	int SC_SERVER_DECL FRunfuncs(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL SetFOV(T* pThis, SC_SERVER_DUMMYARG int iFOV);
	int SC_SERVER_DECL FRunfuncs2(T* pThis SC_SERVER_DUMMYARG_NOCOMMA);
	void SC_SERVER_DECL CustomDecrement(T* pThis, SC_SERVER_DUMMYARG float flDecrement);
	void SC_SERVER_DECL SetV_Model(T* pThis, SC_SERVER_DUMMYARG char* szModel);
	void SC_SERVER_DECL SetP_Model(T* pThis, SC_SERVER_DUMMYARG char* szModel);
	void SC_SERVER_DECL ChangeWeaponSkin(T* pThis, SC_SERVER_DUMMYARG short iskin);
};