//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../mikk/json"

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load('plugins/mikk/FastRestart.json');
}

CScheduledFunction@ pTimer;

void MapStart()
{
    if( pTimer !is null )
    {
        g_Scheduler.RemoveTimer( pTimer );
    }

    pJson.reload( 'plugins/mikk/FastRestart.json' );

    if( g_SurvivalMode.MapSupportEnabled() && array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) < 1 )
    {
        @pTimer = g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
    }
}

bool MedicAround( Vector VecStart )
{
    CBaseEntity@ pSci = null, pAgr = null;

    while(
        ( ( @pAgr = g_EntityFuncs.FindEntityInSphere( pAgr, VecStart, pJson['SearchRadius', 1024], 'monster_human_medic_ally', 'classname' ) ) !is null
            && pAgr.IsMonster() && cast<CBaseMonster@>(pAgr).IsPlayerAlly() ) ||
                ( ( @pSci = g_EntityFuncs.FindEntityInSphere( pSci, VecStart, pJson['SearchRadius', 1024], 'monster_scientist', 'classname' ) ) !is null
                    && pSci.IsMonster() && cast<CBaseMonster@>(pSci).IsPlayerAlly() ) )
                    { return true;
    }
    return false;
}

void Think()
{
    int iAlivePlayers = 0, iAllPlayers = 0;

    for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );

        if( pPlayer !is null )
        {
            if( pPlayer.IsAlive() )
            {
                ++iAlivePlayers;
            }
            ++iAllPlayers;
        }
    }

    if( g_SurvivalMode.IsActive() && g_PlayerFuncs.GetNumPlayers() > 0 && iAlivePlayers == 0 )
    {
        if( pJson[ 'ShouldWaitMedic', false ] )
        {
            CBaseEntity@ pCorpses = null;

            while( ( @pCorpses = g_EntityFuncs.FindEntityByClassname( pCorpses, 'deadplayer' ) ) !is null )
            {
                if( MedicAround( pCorpses.pev.origin ) )
                {
                    return;
                }
            }

            @pCorpses = null;

            while( ( @pCorpses = g_EntityFuncs.FindEntityByClassname( pCorpses, 'player' ) ) !is null )
            {
                if( pCorpses.pev.health <= 0 )
                {
                    if( MedicAround( pCorpses.pev.origin ) )
                    {
                        return;
                    }
                }
            }
        }

        try
        {
            g_EntityFuncs.CreateEntity( 'player_loadsaved', { { 'targetname', 'a' }, { 'loadtime', '1.5' } }, true ).Use( null, null, USE_ON, 0.0f );
        }
        catch
        {
            g_EngineFuncs.ChangeLevel( string( g_Engine.mapname ) );
        }
    }
}
