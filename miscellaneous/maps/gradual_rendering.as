/*
Born has a competition with Sparks :D

    netname
        - Name of the entity you want to render, use semicolon for multiple targets. i.e "mysprite;myothersprite"
    renderamt
        - Renderamt to fade TO from the original entity's renderamt
    health
        - Distance to start fading TO
    max_health
        - Distance to stop fadding TO

    frags
        - 0/1 disable/enable distance debugging
*/

void gradual_rendering( CBaseEntity@ ts )
{
    if( string( ts.pev.netname ). IsEmpty() )
    {
        g_Game.AlertMessage( at_console, "WARNING! No netname set on trigger_script" + ( ts.GetClassname() != '' ? ts.GetClassname() : '' ) + "\n" );
        return;
    }

    array<string> szEntities = string( ts.pev.netname ).Split( ";" );

    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
    {
        string szDebug = '';

        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if( pPlayer is null || !pPlayer.IsConnected() )
            continue;

        for( uint ui = 0; ui < szEntities.length(); ui++ )
        {
            CBaseEntity@ pEntity = null;

            while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, szEntities[ui] ) ) !is null )
            {
                int MaxRange = int( ts.pev.max_health );
                int MinRange = int( ts.pev.health );

                CBaseEntity@ RenderSettings = pRender( pPlayer );
                RenderSettings.pev.target = pEntity.pev.targetname;

                if( ( pEntity.pev.origin - pPlayer.pev.origin ).Length() <= MinRange )
                {
                    RenderSettings.Use( pPlayer, ts, USE_OFF, 0 );

                    if( int( ts.pev.frags ) == 1 )
                        szDebug += ( pEntity.GetTargetname() != '' ? pEntity.GetTargetname() : '' ) + ' Within range, render to ' + string( pEntity.pev.renderamt ) + '.\n';
                }
                else if( ( pEntity.pev.origin - pPlayer.pev.origin ).Length() <= MaxRange )
                {
                    int distance = int( (pEntity.pev.origin - pPlayer.pev.origin).Length() );

                    int value = int( pEntity.pev.renderamt )
                        - ( distance - MinRange )
                            * ( int( pEntity.pev.renderamt )
                                - int( ts.pev.renderamt ) )
                                    / ( MaxRange - MinRange );

                    value = Math.max( int( ts.pev.renderamt ), Math.min( int( pEntity.pev.renderamt ), value ) );

                    RenderSettings.pev.renderamt = float(value);
                    RenderSettings.Use( pPlayer, ts, USE_ON, 0 );

                    if( int( ts.pev.frags ) == 1 )
                    {
                        szDebug += ( pEntity.GetTargetname() != '' ? pEntity.GetTargetname() : '' ) + ' D'
                            + string( ( pEntity.pev.origin - pPlayer.pev.origin ).Length() ) + " A:" + string( value ) + "\n";
                    }
                }
                else
                {
                    RenderSettings.pev.renderamt = ts.pev.renderamt;
                    RenderSettings.Use( pPlayer, ts, USE_ON, 0 );

                    if( int( ts.pev.frags ) == 1 )
                    {
                        szDebug += ( pEntity.GetTargetname() != '' ? pEntity.GetTargetname() : '' ) + ' Outside range, clamp to ' + string( ts.pev.renderamt ) + '.\n';
                    }
                }
            }
        }

        if( int( ts.pev.frags ) == 1 )
        {
            HUDTextParams textParams;
            textParams.x = 0.0;
            textParams.effect = 0;
            textParams.r1 = 0;
            textParams.g1 = 255;
            textParams.b1 = 0;
            textParams.fadeinTime = 0;
            textParams.fadeoutTime = 0;
            textParams.holdTime =1;

            textParams.x = -1;
            textParams.y = -1;
            textParams.channel = 1;
            g_PlayerFuncs.HudMessage( pPlayer, textParams, szDebug );
        }
    }
}

CBaseEntity@ pRender( CBasePlayer@ pPlayer )
{
    CBaseEntity@ pRenderEnt = g_EntityFuncs.FindEntityByTargetname( null, "gradual_rendering::"+g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );

    if( pRenderEnt is null )
    {
        @pRenderEnt = g_EntityFuncs.Create( "env_render_individual", g_vecZero, g_vecZero, false, pPlayer.edict() );
        g_EntityFuncs.DispatchKeyValue( pRenderEnt.edict(), "targetname", "gradual_rendering::" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );
        pRenderEnt.pev.spawnflags |= 1; // No Renderfx
        pRenderEnt.pev.spawnflags |= 4; // No Rendermode
        pRenderEnt.pev.spawnflags |= 8; // No Rendercolor
        pRenderEnt.pev.spawnflags |= 64; // Affect Activator (ignore netname)
    }
    return ( pRenderEnt !is null ? @pRenderEnt : null );
}
