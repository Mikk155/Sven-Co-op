
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
}

PlayerSpawnHook@ fnPlayerSpawn = PlayerSpawnHook( PlayerSpawn );

void MapActivate()
{
    g_Hooks.RemoveHook( Hooks::Player::PlayerSpawn, @fnPlayerSpawn );

    if( g_Map.HasForcedPlayerModels() )
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @fnPlayerSpawn );
    }
}

HookReturnCode PlayerSpawn( CBasePlayer@ player )
{
    if( player !is null )
        player.SetOverriddenPlayerModel( String::EMPTY_STRING );
    return HOOK_CONTINUE;
}
