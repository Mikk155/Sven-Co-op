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

const string SoundToPlay = 'limitlesspotential/cs/restart.wav';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    Mikk.Hooks.RegisterHook( Hooks::Game::SurvivalEndRound, @SurvivalEndRound );
}

HookReturnCode SurvivalEndRound()
{
    CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( 'player_loadsaved', { { 'targetname', 'DDD_ReloadLevel' }, { 'loadtime', '1.5' } }, true );

    try
    {
        pEntity.Use( null, null, USE_ON, 0.0f );
    }
    catch
    {
        g_EngineFuncs.ChangeLevel( string( g_Engine.mapname ) );
    }

    Mikk.PlayerFuncs.ClientCommand( "spk \"sound/" + SoundToPlay + "\"", null, true );

    return HOOK_CONTINUE;
}