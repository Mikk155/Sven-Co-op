/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

#include "../mikk155/meta_api"
#include "../mikk155/meta_api/json"
#include "../mikk155/Server/IsMapListed"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();
    MapActivate();
}

int g_searchRadius;
bool g_shouldWaitForMedic;
float g_reloadTime;
array<string> g_medics;
bool g_ShouldReloadJson = true;
array<string> g_BlacklistedMaps;

CScheduledFunction@ g_think;

void MapActivate()
{
    if( g_think !is null )
    {
        g_Scheduler.RemoveTimer( g_think );
        @g_think = null;
    }

    if( g_ShouldReloadJson )
    {
        dictionary data;
        if( meta_api::json::Deserialize( "scripts/plugins/FastRestart.json", data ) )
        {
            g_BlacklistedMaps = meta_api::json::ToArray( data[ "map_blacklist" ] );
            g_medics = meta_api::json::ToArray( data[ "medic_entities" ] );
            g_ShouldReloadJson = bool( data[ "reload" ] );
            data.get( "medic_radius", g_searchRadius );
            data.get( "wait_medic", g_shouldWaitForMedic );
            data.get( "reload_time", g_reloadTime );
        }
    }

    if( !g_SurvivalMode.MapSupportEnabled() || Server::IsMapListed( g_BlacklistedMaps ) )
        return;

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
