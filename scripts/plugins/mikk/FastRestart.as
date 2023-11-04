#include '../../mikk/as_utils'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    mk.Hooks.RegisterHook( Hooks::Game::SurvivalEndRound, @SurvivalEndRound );
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

    mk.PlayerFuncs.ClientCommand( "spk \"sound/limitlesspotential/cs/restart.wav\"" );

    return HOOK_CONTINUE;
}