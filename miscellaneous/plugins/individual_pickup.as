void MapInit()
{
    g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
}

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult )
{
    if( pPickup !is null && pOther !is null )
    {
        g_EntityFuncs.FireTargets( string( pPickup.pev.classname ).Replace( 'weapon_', 'ammo_' ), pOther, pPickup, USE_TOGGLE, 0.0f );
    }
    return HOOK_CONTINUE;
}







void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
    g_Hooks.RegisterHook( Hooks::PickupObject::Materialize, @Materialize );

    Renders.resize(0);

    while( Renders.length() < uint( g_Engine.maxClients ) )
    {
        dictionary k =
        {
            { 'classname', 'env_render_individual' },
            { 'spawnflags', '73' },
            { 'targetname', 'II_RenderingItems' },
            { 'renderamt', '90' },
            { 'rendermode', '2' }
        };

        CBaseEntity@ pRender = g_EntityFuncs.CreateEntity( 'env_render_individual', k, true );

        if( pRender !is null )
        {
            Renders.insertLast( @pRender );
        }
    }
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

array<EHandle> Renders;

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult )
{
    if( pPickup is null || pOther is null || pPickup.GetCustomKeyvalues().HasKeyvalue( '$s_individual_pickup_not' ) )
        return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId( pOther.edict() );

    if( pPickup.GetCustomKeyvalues().GetKeyvalue( '$s_lp_' + SteamID ).GetInteger() == 1 )
    {
        bResult = false;
        return HOOK_CONTINUE;
    }
    else if( pPickup.GetCustomKeyvalues().GetKeyvalue( '$s_lp_' + SteamID ).GetInteger() == 0 )
    {
        CBaseEntity@ pRender = Renders[ pOther.entindex() ].GetEntity();

        if( pRender !is null )
        {
            if( pPickup.pev.targetname != '' )
            {
                pRender.pev.target = pPickup.pev.targetname;
            }
            else
            {
                pPickup.pev.targetname = 'individual_pickup_' + string( pPickup.entindex() );
                pRender.pev.target = 'individual_pickup_' + string( pPickup.entindex() );
            }
            pRender.Use( pOther, null, USE_ON, 0.0f );
        }

        g_EntityFuncs.DispatchKeyValue( pPickup.edict(), '$s_lp_' + SteamID, 1 );

        g_Scheduler.SetTimeout( 'DelayedSet', 0.0000f, pPickup.entindex(), pOther.entindex(), SteamID );
    }

    return HOOK_CONTINUE;
}

void DelayedSet( int eidx, int pidx, string SteamID )
{
    CBaseEntity@ pPickup = g_EntityFuncs.Instance( eidx );
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( pidx );

	CBasePlayerItem@ pItem = pPlayer.HasNamedPlayerItem( pPickup.pev.classname );

    if( pPickup is null || pPlayer is null || pItem is null )
        return;

    g_EntityFuncs.DispatchKeyValue( pPickup.edict(), '$s_lp_' + SteamID, 2 );
}