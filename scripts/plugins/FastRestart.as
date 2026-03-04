#include "../mikk155/meta_api/core"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();
    MapInit();
}

int g_searchRadius;
bool g_shouldWaitForMedic;
float g_reloadTime;
array<string> g_medics;

CScheduledFunction@ g_think;

void MapInit()
{
    if( !g_SurvivalMode.MapSupportEnabled() )
        return;

    dictionary data;
    meta_api::json::Deserialize( "scripts/plugins/FastRestart.json", data );

    if( meta_api::json::IsMapListed( data ) )
    {
        g_Game.AlertMessage( at_console, "FastRestart disabled for this map.\n" );
        return;
    }

    data.get( "medic_radius", g_searchRadius );
    data.get( "wait_medic", g_shouldWaitForMedic );
    data.get( "reload_time", g_reloadTime );

    g_medics = {};

    dictionary medics;
    if( data.get( "medic_entities", medics ) )
    {
        for( uint ui = 0; ui < medics.getSize(); ui++ )
        {
            g_medics.insertLast( string( medics[ ui ] ) );
        }
    }

    if( g_think !is null )
    {
        g_Scheduler.RemoveTimer( g_think );
        @g_think = null;
    }

    @g_think = g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Think()
{
    if( !g_SurvivalMode.IsActive() )
        return;

    if( g_PlayerFuncs.GetNumPlayers() <= 0 )
        return;

    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        auto player = g_PlayerFuncs.FindPlayerByIndex(i);

        if( player !is null && player.IsAlive() )
            return;
    }

    if( g_shouldWaitForMedic )
    {
        CBaseEntity@ corpse = null;

        while( ( @corpse = g_EntityFuncs.FindEntityByClassname( corpse, 'deadplayer' ) ) !is null )
        {
            for( uint ui = 0; ui < g_medics.length(); ui++ )
            {
                CBaseEntity@ medic = null;

                while( ( @medic = g_EntityFuncs.FindEntityInSphere( medic, corpse.pev.origin, g_searchRadius, g_medics[ui] , "classname") ) !is null )
                {
                    auto owner = g_PlayerFuncs.FindPlayerByIndex( int( corpse.pev.renderamt ) );

                    if( owner !is null && owner.IRelationship( medic ) == R_AL )
                        return;
                }
            }
        }

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            auto player = g_PlayerFuncs.FindPlayerByIndex(i);

            if( player !is null && !player.IsAlive() && !player.GetObserver().IsObserver() )
            {
                for( uint ui = 0; ui < g_medics.length(); ui++ )
                {
                    CBaseEntity@ medic = null;

                    while( ( @medic = g_EntityFuncs.FindEntityInSphere( medic, player.pev.origin, g_searchRadius, g_medics[ui] , "classname") ) !is null )
                    {
                        if( player.IRelationship( medic ) == R_AL )
                            return;
                    }
                }
            }
        }
    }

    CBaseEntity@ loadsave = g_EntityFuncs.CreateEntity( "player_loadsaved", null, true );

    loadsave.pev.targetname = "FastRestart";

    g_EntityFuncs.DispatchKeyValue( loadsave.edict(), "loadtime", g_reloadTime );

    loadsave.Use( null, null, USE_ON, 0.0f );
}
