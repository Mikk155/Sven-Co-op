int currentdiffy = 0;
namespace DDD_PLAYERKILLED
{
    array<string> EnumMonsters = 
    {
        "zombie",
        "headcrab",
        "houndeye",
        "tentacle",
        "handgrenade",
        "hwgrunt",
        "shockroach",
        "zombie_barney",
        "zombie_soldier"
    };

    void PLAYERKILLED( int iDifficulty )
    {
		currentdiffy = iDifficulty;
	}

	HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@, int iGib )
	{
		CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pPlayer.pev.dmg_inflictor );

        for( uint i = 0; i < EnumMonsters.length(); i++ )
        {
			if( pInflictor.GetClassname() == "monster_" + EnumMonsters[i]  )
			{
				iGib = GIB_ALWAYS
			}
		}

		return HOOK_CONTINUE;
	}
}