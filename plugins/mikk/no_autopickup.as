void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::PickupObject::Materialize, @Materialize );
}

HookReturnCode Materialize( CBaseEntity@ pPickup )
{
    if( pPickup !is null )
    {
        if( !pPickup.pev.SpawnFlagBitSet( 128) && !pPickup.pev.SpawnFlagBitSet( 256 ) )
        {
            pPickup.pev.spawnflags += 256;
        }
    }
    return HOOK_CONTINUE;
}