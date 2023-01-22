namespace game_stealth
{
    CScheduledFunction@ g_Stealth = g_Scheduler.SetTimeout( "CreateStealthMode", 0.0f );

    void CreateStealthMode()
    {
        bool Enable = false;

        CBaseEntity@ pMoster = null;

        while( ( @pMoster = g_EntityFuncs.FindEntityByClassname( pMoster, "monster_*" ) ) !is null )
        {
            if( pMoster.IsMonster() && pMoster.GetCustomKeyvalues().GetKeyvalue( "$i_stealth" ).GetInteger() == 1 )
            {
                Enable = true;
            }
        }

        if( Enable )
        {
            dictionary g_keyvalues =
            {
                { "m_iszScriptFunctionName", "game_stealth::FindMonsters" },
                { "m_iMode", "2" },
                { "m_flThinkDelta", "0.1" },
                { "targetname", "game_stealth" }
            };
            CBaseEntity@ pScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );
            
            if( pScript !is null )
            {
                pScript.Use( null, null, USE_TOGGLE, 0.0f );
            }
        }

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_stealth\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mappers to make use of stealth mode in Co-op.\n"
        );
    }

    void FindMonsters( CBaseEntity@ pTriggerScript )
    {
        CBaseEntity@ pMoster = null;

        while( ( @pMoster = g_EntityFuncs.FindEntityByClassname( pMoster, "monster_*" ) ) !is null )
        {
            if( pMoster.IsMonster() && pMoster.GetCustomKeyvalues().GetKeyvalue( "$i_stealth" ).GetInteger() == 1 )
            {
                CBaseMonster@ pEnemy = cast<CBaseMonster@>( pMoster );

                if( pEnemy.m_hEnemy.GetEntity() !is null )
                {
                    CBaseEntity@ pSpotted = cast<CBaseEntity@>( pEnemy.m_hEnemy.GetEntity() );

                    if( pMoster.GetCustomKeyvalues().GetKeyvalue( "$i_stealthmode" ).GetInteger() == 0 )
                    {
                        if( !string( cast<CBaseMonster@>( pSpotted ).m_iszTriggerTarget ).IsEmpty() )
                        {
                            g_EntityFuncs.FireTargets( string( cast<CBaseMonster@>( pSpotted ).m_iszTriggerTarget ), pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                        }

                        g_EntityFuncs.Remove( pSpotted );
                        g_EntityFuncs.FireTargets( pEnemy.pev.target, pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                    }

                    if( pSpotted.IsPlayer() )
                    {
                        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pEnemy.m_hEnemy.GetEntity() );

                        if( pPlayer !is null )
                        {
                            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
                            g_EntityFuncs.FireTargets( pEnemy.pev.target, pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                        }
                    }

                    pEnemy.m_hEnemy = null;
                }
            }
        }
    }
}// end namespace