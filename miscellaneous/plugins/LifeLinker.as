// https://discord.com/channels/170051548284583937/1394037155252142100

bool ShareSuit = true;

CScheduledFunction@ g_Timer = null;

bool g_TakingDamage = false;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );

    g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
}

void MapInit()
{
    g_Scheduler.RemoveTimer( g_Timer );
    @g_Timer = g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Think()
{
    float CurrentMaxHealth = 0, CurrentMaxArmor = 0;

    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        auto player = g_PlayerFuncs.FindPlayerByIndex( i );

        if( player !is null )
        {
            if( ShareSuit )
            {
                if( player.pev.armorvalue > CurrentMaxArmor )
                {
                    CurrentMaxArmor = player.pev.armorvalue;
                }
            }

            if( player.pev.health > CurrentMaxHealth )
            {
                CurrentMaxHealth = player.pev.health;
            }
        }
    }

	if( CurrentMaxHealth + CurrentMaxArmor > 0 )
	{
		for( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			auto player = g_PlayerFuncs.FindPlayerByIndex( i );

			if( player !is null )
			{
				if( CurrentMaxHealth > 0 )
				{
					player.pev.health = CurrentMaxHealth;
				}
                if( CurrentMaxArmor > 0 )
                {
					
                    player.pev.armorvalue = CurrentMaxArmor;
                }
			}
		}
	}
}

HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
	// This is designed for coop only allieds
	if( pDamageInfo.pAttacker !is null and pDamageInfo.pAttacker.IsPlayer() )
	{
        return HOOK_CONTINUE;
	}

    if( g_TakingDamage )
    {
        return HOOK_CONTINUE;
    }

    g_TakingDamage = true;

    if( pDamageInfo.pVictim !is null )
    {
        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            auto player = g_PlayerFuncs.FindPlayerByIndex( i );

            if( player !is null && player !is pDamageInfo.pVictim )
            {
                player.TakeDamage(
                    pDamageInfo.pInflictor !is null ? pDamageInfo.pInflictor.pev : null,
                    pDamageInfo.pAttacker !is null ? pDamageInfo.pAttacker.pev : null,
                    pDamageInfo.flDamage,
                    pDamageInfo.bitsDamageType
                );
            }
        }
    }

    g_TakingDamage = false;

    return HOOK_CONTINUE;
}
