/*
DOWNLOAD:

scripts/maps/mikk/game_stealth.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/game_stealth"

*/

#include "utils"

namespace game_stealth
{
    CScheduledFunction@ g_Stealth = g_Scheduler.SetTimeout( "CreateMode", 0.0f );

    void CreateMode()
    {
        dictionary g_keyvalues =
        {
            { "m_iszScriptFunctionName", "game_stealth::FindMonsters" },
            { "m_iMode", "2" },
            { "m_flThinkDelta", "0.1" },
            { "targetname", "idkwhythisneedthisthisthis" }
        };
        CBaseEntity@ pScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );
        
        if( pScript !is null )
        {
            pScript.Use( null, null, USE_TOGGLE, 0.0f );
        }
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
                            UTILS::Trigger( string( cast<CBaseMonster@>( pSpotted ).m_iszTriggerTarget ), pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                        }

                        g_EntityFuncs.Remove( pSpotted );
                        UTILS::Trigger( pEnemy.pev.target, pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                    }

                    if( pSpotted.IsPlayer() )
                    {
                        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pEnemy.m_hEnemy.GetEntity() );

                        if( pPlayer !is null )
                        {
                            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
                            UTILS::Trigger( pEnemy.pev.target, pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                        }
                    }

                    pEnemy.m_hEnemy = null;
                }
            }
        }
    }
}// end namespace