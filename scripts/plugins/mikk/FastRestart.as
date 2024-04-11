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

#include '../../mikk/shared'

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    Mikk.Hooks.RegisterHook( Hooks::Game::SurvivalEndRound, @SurvivalEndRound );

    pJson.load('plugins/mikk/FastRestart.json');
}

void Restart()
{
    try
    {
        g_EntityFuncs.CreateEntity( 'player_loadsaved', { { 'targetname', 'a' }, { 'loadtime', '1.5' } }, true ).Use( null, null, USE_ON, 0.0f );
    }
    catch
    {
        g_EngineFuncs.ChangeLevel( string( g_Engine.mapname ) );
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


HookReturnCode SurvivalEndRound()
{
    if( pJson[ 'ShouldWaitMedic', false ] )
    {
        CBaseEntity@ pCorpses = null;

        while( ( @pCorpses = g_EntityFuncs.FindEntityByClassname( pCorpses, 'deadplayer' ) ) !is null )
        {
            if( MedicAround( pCorpses.pev.origin ) )
            {
                return HOOK_CONTINUE;
            }
        }

        @pCorpses = null;

        while( ( @pCorpses = g_EntityFuncs.FindEntityByClassname( pCorpses, 'player' ) ) !is null )
        {
            if( pCorpses.pev.health <= 0 )
            {
                if( MedicAround( pCorpses.pev.origin ) )
                {
                    return HOOK_CONTINUE;
                }
            }
        }

        Restart();
    }
    else
    {
        Restart();
    }
    return HOOK_CONTINUE;
}