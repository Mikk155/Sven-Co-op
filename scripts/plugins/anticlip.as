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
#include "../mikk155/Server/Framerate"
#include "../mikk155/Server/IsMapListed"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();

    MapActivate();
}

bool g_ShouldReloadJson = true;
array<string> g_BlacklistedMaps;

#if METAMOD_PLUGIN_ASLP
PostAddToFullPackHook@ fnPostAddToFullPack = PostAddToFullPackHook( PostAddToFullPack );
PreMovementHook@ fnPreMovement = PreMovementHook( PreMovement );
ShouldCollideHook@ fnShouldCollide = ShouldCollideHook( ShouldCollide );
auto fnCheckFramerate = Server::Framerate::FrameRateCallback( CheckFramerate );
#endif

bool g_AllowMonsters = false;
bool g_AllowProjectiles = false;
bool g_AllowBoosting = true;
bool g_InvisibleColliders = false;
bool g_ClientPrediction = true;
int g_RenderMode = kRenderTransTexture;
int g_RenderAmt = 100;

void MapActivate()
{
    if( g_ShouldReloadJson )
    {
        dictionary data;
        if( meta_api::json::Deserialize( "scripts/plugins/anticlip.json", data ) )
        {
            g_BlacklistedMaps = meta_api::json::ToArray( data[ "map_blacklist" ] );
            g_ShouldReloadJson = bool( data[ "reload" ] );
            data.get( "npc_clip", g_AllowMonsters );
            data.get( "player_boost", g_AllowBoosting );
            data.get( "projectiles_clip", g_AllowProjectiles );

            dictionary client_prediction = cast<dictionary>( data[ "client_prediction" ] );

            if( client_prediction.get( "active", g_ClientPrediction ) && g_ClientPrediction )
            {
                client_prediction.get( "invisible", g_InvisibleColliders );
                client_prediction.get( "rendermode", g_RenderMode );
                client_prediction.get( "renderamt", g_RenderAmt );
            }
        }
    }

#if METAMOD_PLUGIN_ASLP
    g_Hooks.RemoveHook( Hooks::aslp::Player::PreMovement, @fnPreMovement );
    g_Hooks.RemoveHook( Hooks::aslp::Player::PostAddToFullPack, @fnPostAddToFullPack );
    g_Hooks.RemoveHook( Hooks::aslp::Entity::ShouldCollide, @fnShouldCollide );
    Server::Framerate::RemoveCallback( @fnCheckFramerate );
#endif

    if( Server::IsMapListed( g_BlacklistedMaps ) )
    {
        g_Game.AlertMessage( at_console, "Anti-Clip disabled for this map.\n" );
        return;
    }

#if METAMOD_PLUGIN_ASLP
    g_Hooks.RegisterHook( Hooks::aslp::Player::PreMovement, @fnPreMovement );

    if( g_ClientPrediction )
    {
        g_Hooks.RegisterHook( Hooks::aslp::Player::PostAddToFullPack, @fnPostAddToFullPack );
        Server::Framerate::SetCallback( @fnCheckFramerate );
    }

    if( !g_AllowProjectiles )
    {
        g_Hooks.RegisterHook( Hooks::aslp::Entity::ShouldCollide, @fnShouldCollide );
    }
#endif
}

void MapInit()
{
#if METAMOD_DEBUG // Testing allied npcs cliping
    g_Game.PrecacheOther( "monster_barney" );
#endif
}

#if METAMOD_PLUGIN_ASLP
int g_BestServerFrames = 0;

int g_LagSpikes = 0;
bool g_ServerLagged = false;

int g_AvgAccumulator = 0;
int g_AvgSamples = 0;
int g_LastAverage = 0;

void CheckFramerate( const ServerFramerate@ data )
{
    if( !data.LastFrame )
        return;

    g_AvgAccumulator += data.Frames;
    g_AvgSamples++;

    if( g_AvgSamples < 10 )
        return;

    g_LastAverage = g_AvgAccumulator / g_AvgSamples;
    g_AvgAccumulator = 0;
    g_AvgSamples = 0;

    if( g_LastAverage > g_BestServerFrames )
    {
        g_BestServerFrames = g_LastAverage;
    }
    else
    {
        g_BestServerFrames = int( g_BestServerFrames * 0.98f + g_LastAverage * 0.02f );
    }

    // Are we lagging?
    if( g_LastAverage < g_BestServerFrames * 0.75f )
    {
        g_LagSpikes++;
    }
    else
    {
        g_LagSpikes = Math.max( 0, g_LagSpikes - 1 );
    }

//    g_Game.AlertMessage( at_console, "spikes: %1 | best: %2 | avg: %3\n", g_LagSpikes, g_BestServerFrames, g_LastAverage );

    if( !g_ServerLagged && g_LagSpikes >= 4 )
    {
        g_ServerLagged = true;
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Anti-Clip] The Server is experiencing slow frame rates. Disabling client prediction...\n" );
        g_Hooks.RemoveHook( Hooks::aslp::Player::PostAddToFullPack, @fnPostAddToFullPack );
    }

    // If your server usually lags a lot you can decrease this multiplier 0.85 to something lower to not spam the hook de-activation
    if( g_ServerLagged && g_LastAverage > g_BestServerFrames * 0.85f )
    {
        g_ServerLagged = false;
        g_LagSpikes = 0;
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Anti-Clip] Server recovered. Re-enabling prediction.\n" );
        g_Hooks.RegisterHook( Hooks::aslp::Player::PostAddToFullPack, @fnPostAddToFullPack );
    }
}

HookReturnCode PreMovement( playermove_t@& out pmove, MetaResult &out meta_result )
{
    if( pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO )
    {
        return HOOK_CONTINUE;
    }

    CBasePlayer@ player = g_PlayerFuncs.FindPlayerByIndex( pmove.player );

    int numphysent = 0;

    for( int j = numphysent; j < pmove.numphysent; j++ )
    {
        physent_t@ physent = pmove.GetPhysEntByIndex(j);

        if( physent is null )
        {
            continue;
        }

        if( physent.name == "player" )
        {
            // No boosting? Skip immediatelly
            if( !g_AllowBoosting )
            {
                continue;
            }

            CBasePlayer@ other = g_PlayerFuncs.FindPlayerByIndex( physent.info );

            if( other is null )
            {
                continue;
            }

            if( ( player.pev.button & IN_DUCK ) != 0 )
            {
                continue;
            }

            // Standing player
            if( ( other.pev.button & IN_DUCK ) == 0 && pmove.origin.z < physent.origin.z + 72 )
            {
                continue;
            }

            // Crouching player
            if( pmove.origin.z < physent.origin.z + 54 )
            {
                continue;
            }
        }
        else if( !g_AllowMonsters )
        {
            CBaseEntity@ entity = g_EntityFuncs.Instance( physent.info );

            if( entity !is null && entity.IsMonster() && entity.GetClassname() != "monster_tripmine" )
            {
                if( !entity.IsAlive() )
                {
                    continue;
                }

                // Do not clip on ally monsters
                if( player.IRelationship( entity ) == R_AL )
                {
                    if( !g_AllowBoosting )
                    {
                        continue;
                    }

                    if( ( player.pev.button & IN_DUCK ) != 0 )
                    {
                        if( pmove.origin.z - pmove.view_ofs.z < physent.origin.z + physent.maxs.z + pmove.view_ofs.z )
                            continue;
                    }
                    else if( pmove.origin.z < physent.origin.z + physent.maxs.z + 36 )
                    {
                        continue;
                    }
                }
            }
        }

        pmove.SetPhysEntByIndex( physent, numphysent++ );
    }

    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode PostAddToFullPack( ClientPacket@ packet, MetaResult &out meta_result )
{
    // If npc is clipping then we don't care about non-player entities.
    if( g_AllowMonsters && packet.playerIndex == 0 )
    {
        return HOOK_CONTINUE;
    }

    if( packet.host is null || packet.entity is null )
    {
        return HOOK_CONTINUE;
    }

    // Skip if the packet is the host
    if( packet.entity is packet.host )
    {
        return HOOK_CONTINUE;
    }

    auto playerHost = g_EntityFuncs.Instance( packet.host );
    auto entityPacket = g_EntityFuncs.Instance( packet.entity );

    if( playerHost is null || entityPacket is null )
    {
        return HOOK_CONTINUE;
    }

    string classname = entityPacket.GetClassname();

    if( classname == "monster_tripmine" )
    {
        return HOOK_CONTINUE;
    }

    if( !entityPacket.IsPlayer() )
    {
        if( g_AllowMonsters || !entityPacket.IsMonster() )
        {
            return HOOK_CONTINUE;
        }
    }

    // Is the host intersecting the packet?
    if( entityPacket.IsAlive() && playerHost.IRelationship( entityPacket ) == R_AL && playerHost.Intersects( entityPacket ) )
    {
        if( g_InvisibleColliders )
        {
            packet.state.effects |= EF_NODRAW;
        }
        else
        {
            packet.state.rendermode = g_RenderMode;
            packet.state.renderamt = g_RenderAmt;
        }
    }

    packet.state.solid = SOLID_NOT;

    return HOOK_CONTINUE;
}

HookReturnCode ShouldCollide( CBaseEntity@ toucher, CBaseEntity@ other, MetaResult &out meta_resut, bool&out Collide )
{
    if( toucher is null || other is null )
    {
        return HOOK_CONTINUE;
    }

    string classname = other.GetClassname();

    if( classname == "grappletongue" || ( classname == "monster_tripmine" || toucher.pev.classname == "monster_tripmine" ) )
    {
        return HOOK_CONTINUE;
    }

    // Player can melee while inside another player and hit something else
    if( toucher.IsPlayer() && other.IsPlayer() )
    {
        if( other.Intersects( toucher ) )
        {
            Collide = false;
            meta_resut = MetaResult::Supercede;
        }
        return HOOK_HANDLED;
    }

    auto owner = g_EntityFuncs.Instance( other.pev.owner );

    // Don't touch allied projectiles
    if( owner !is null && toucher.IRelationship( owner ) == R_AL )
    {
        Collide = false;
        meta_resut = MetaResult::Supercede;
        return HOOK_HANDLED;
    }

    return HOOK_CONTINUE;
}
#endif
