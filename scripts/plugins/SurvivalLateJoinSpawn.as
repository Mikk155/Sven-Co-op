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
#include "../mikk155/Player/GetUniqueID"
#include "../mikk155/Server/IsMapListed"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
    meta_api::NoticeInstallation();
}

ClientPutInServerHook@ fnClientPutInServer = ClientPutInServerHook( ClientPutInServer );
ClientDisconnectHook@ fnClientDisconnect = ClientDisconnectHook( ClientDisconnect );

bool g_Loaded;
dictionary g_SpawnedPlayers;
bool g_ActivateNow;
array<string> g_BlacklistedMaps;

void MapActivate()
{
    if( !g_Loaded )
    {
        dictionary data;
        if( meta_api::json::Deserialize( "scripts/plugins/SurvivalLateJoinSpawn.json", data ) )
        {
            g_BlacklistedMaps = meta_api::json::ToArray( cast<dictionary>( data[ "map_blacklist" ] ) );

            data.get( "activate_survival", g_ActivateNow );

            if( bool( data[ "reload" ] ) )
            {
                g_Loaded = true;
            }
        }
    }

    g_SpawnedPlayers.deleteAll();

    g_Hooks.RemoveHook( Hooks::Player::ClientPutInServer, @fnClientPutInServer );
    g_Hooks.RemoveHook( Hooks::Player::ClientDisconnect, @fnClientDisconnect );

    if( Server::IsMapListed( g_BlacklistedMaps ) )
    {
        return;
    }

    if( g_SurvivalMode.MapSupportEnabled() )
    {
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @fnClientPutInServer );
        g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @fnClientDisconnect );

        if( g_ActivateNow && g_SurvivalMode.GetStartOn() ) // Some maps like they hunger may want to enable it later on in the map.
        {
            g_SurvivalMode.SetDelayBeforeStart( 0.0f );
            g_SurvivalMode.Activate( true );
        }
    }
}

HookReturnCode ClientDisconnect( CBasePlayer@ player )
{
    if( player.IsAlive() )
    {
        string authID = Player::GetUniqueID( player );
        g_SpawnedPlayers[ authID ] = false;
    }
    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ player )
{
    if( player !is null )
    {
        string authID = Player::GetUniqueID( player );
        bool hasSpawned = bool( g_SpawnedPlayers[ authID ] );

        if( !hasSpawned && g_SurvivalMode.IsActive() )
        {
            player.Revive();
            g_PlayerFuncs.RespawnPlayer( player, false, true );
        }

        g_SpawnedPlayers[ authID ] = true;
    }
    return HOOK_CONTINUE;
}
