CScheduledFunction@ g_Think = null;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    if( g_Think !is null )
    {
        g_Scheduler.RemoveTimer( g_Think );
    }

    @g_Think = g_Scheduler.SetInterval( "Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Think()
{
    CBaseEntity@ pGrenade = null;

    while( ( @pGrenade = g_EntityFuncs.FindEntityByClassname( pGrenade, 'grenade' ) ) !is null )
    {
        if( pGrenade.IsRevivable() )
        {
            g_EntityFuncs.DispatchKeyValue( pGrenade.edict(), 'is_not_revivable', 1 );
        }
    }
}