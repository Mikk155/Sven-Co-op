class CWeaponBase : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;

	void Spawn()
	{

	}

	void Precache()
	{

	}

	bool GetItemInfo( ItemInfo& out info )
	{
		return true;
	}

	bool AddToPlayer(CBasePlayer@ pPlayer)
	{
		return true;
	}

	bool PlayEmptySound()
	{
		return false;
	}

	bool Deploy()
	{
		return bResult;
	}

	void Holster( int skiplocal = 0 )
	{
	}

	void PrimaryAttack()
	{
	}

	void SecondaryAttack()
	{
	}

	void WeaponIdle()
	{
	}

	void Reload()
	{
	}
}
