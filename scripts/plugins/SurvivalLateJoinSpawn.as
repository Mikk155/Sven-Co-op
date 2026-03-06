#include "../mikk155/Player/GetUniqueID"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
}

ClientPutInServerHook@ fnClientPutInServer = ClientPutInServerHook( ClientPutInServer );

dictionary g_SpawnedPlayers;

void MapActivate()
{
    g_SpawnedPlayers.deleteAll();

    g_Hooks.RemoveHook( Hooks::Player::ClientPutInServer, @fnClientPutInServer );

    if( g_SurvivalMode.MapSupportEnabled() )
    {
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @fnClientPutInServer );

        if( g_SurvivalMode.GetStartOn() ) // Some maps like they hunger may want to enable it later on in the map.
        {
            g_SurvivalMode.SetDelayBeforeStart( 0.0f );
            g_SurvivalMode.Activate( true );
        }
    }
}

HookReturnCode ClientPutInServer( CBasePlayer@ player )
{
    if( player !is null )
    {
        string authID = Player::GetUniqueID( player );

        if( !g_SpawnedPlayers.exists( authID ) && g_SurvivalMode.IsActive() )
        {
            g_PlayerFuncs.RespawnPlayer( player, false, true );
        }

        g_SpawnedPlayers[ authID ] = true;
    }
    return HOOK_CONTINUE;
}
