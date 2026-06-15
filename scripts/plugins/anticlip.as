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
#include "../mikk155/meta_api/json/v2/fmt/ToArray"
#include "../mikk155/meta_api/json/v2/schema"
#include "../mikk155/meta_api/json/v2"
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
PlayerPreMovementHook@ fnPreMovement = PlayerPreMovementHook( PreMovement );
ShouldCollideHook@ fnShouldCollide = ShouldCollideHook( ShouldCollide );
Server::Framerate::FrameRateCallback@ fnCheckFramerate = Server::Framerate::FrameRateCallback( CheckFramerate );
#endif

bool g_AllowMonsters = false;
bool g_AllowProjectiles = false;
bool g_AllowBoosting = true;
bool g_InvisibleColliders = false;
bool g_ClientPrediction = true;
int g_RenderMode = kRenderTransTexture;
int g_RenderAmt = 100;

void Shutdown()
{
#if METAMOD_PLUGIN_ASLP
    g_Hooks.RemoveHook( Hooks::aslp::PlayerPreMovement, @fnPreMovement );
    g_Hooks.RemoveHook( Hooks::aslp::PostAddToFullPack, @fnPostAddToFullPack );
    g_Hooks.RemoveHook( Hooks::aslp::ShouldCollide, @fnShouldCollide );
    Server::Framerate::RemoveCallback( @fnCheckFramerate );
#endif
}

void MapActivate()
{
    if( g_ShouldReloadJson )
    {
        meta_api::json::v2::json@ data;

        bool failedLoad = false;
        meta_api::json::Error err = meta_api::json::Error::OK;

        if( !meta_api::json::v2::Deserialize( "store/anticlip.json", data, err ) )
        {
            @data = meta_api::json::v2::json();
            if( err == meta_api::json::Error::FILE_NOT_FOUND )
            {
                failedLoad = true;
            }
            else
            {
                g_Game.AlertMessage( at_console, "Anti-Clip JSON parsing failed with error code: %1. Config file preserved.\n", int(err) );
            }
        }

        auto@ Schema = meta_api::json::v2::json();

        Schema.Load( """{
"$schema": "https://json-schema.org/draft/2020-12/schema",
"type":"object",
"unevaluatedProperties":false,
"properties":
{
    "$schema":
    {
        "type":"string",
        "default":"anticlip_schema.json"
    }
    "npc_clip":
    {
        "type":"boolean",
        "default":false,
        "description":"Whatever players should collide with allied npcs."
    },
    "player_boost":
    {
        "type":"boolean",
        "default":true,
        "description":"Whatever to allow boosting by jumping over a player / npc"
    },
    "projectiles_clip":
    {
        "type":"boolean",
        "default":false,
        "description":"Whatever projectiles (rockets, spores, bolts etc) can clip to allies"
    },
    "client_prediction":
    {
        "type":"object",
        "default":{}
        "unevaluatedProperties":false,
        "properties":
        {
            "active":
            {
                "type":"boolean",
                "default":true,
                "description":"set to false and will considerably improve performance."
            },
            "invisible":
            {
                "type":"boolean",
                "default":false,
                "description":"Completelly hide intersecting entities. (ignore render settings)"
            },
            "rendermode":
            {
                "type":"integer",
                "default":4,
                "description":"rendermode var for intersecting entities.",
                "minimum":0,
                "maximum":4
            },
            "renderamt":
            {
                "type":"integer",
                "default":100,
                "description":"renderamt var for intersecting entities.",
                "minimum":0,
                "maximum":255
            }
        }
    }
    "reload":
    {
        "type":"boolean",
        "default":false,
        "description":"Should this json file be parsed every map change?"
    },
    "map_blacklist":
    {
        "type":"array",
        "description":"List of maps that this plugin should be disabled.",
        "default": []
    }
}
}""" );

        meta_api::json::v2::schema::Validate( data, Schema, false );

        if( failedLoad )
        {
            meta_api::json::v2::Serialize( data, "store/anticlip.json",
                meta_api::json::parser::Indentation::OneTabSpace,
                meta_api::json::parser::Style::AllMan
            );
            meta_api::json::v2::Serialize( Schema, "store/anticlip_schema.json",
                meta_api::json::parser::Indentation::OneTabSpace,
                meta_api::json::parser::Style::AllMan
            );
            g_Game.AlertMessage( at_console, "Anti-Clip wroted a template json config at scripts/plugins/store/anticlip.\n" );
        }

        meta_api::json::v2::fmt::ToArray( data.ValueOrDefault( "map_blacklist" ), g_BlacklistedMaps );
        g_ShouldReloadJson = data.ValueOrDefault( "reload", false );
        data.Get( "npc_clip", g_AllowMonsters );
        data.Get( "player_boost", g_AllowBoosting );
        data.Get( "projectiles_clip", g_AllowProjectiles );

        auto client_prediction = data.ValueOrDefault( "client_prediction" );

        if( client_prediction.Get( "active", g_ClientPrediction ) && g_ClientPrediction )
        {
            client_prediction.Get( "invisible", g_InvisibleColliders );
            client_prediction.Get( "rendermode", g_RenderMode );
            client_prediction.Get( "renderamt", g_RenderAmt );
        }
    }

    Shutdown();

    if( Server::IsMapListed( g_BlacklistedMaps ) )
    {
        g_Game.AlertMessage( at_console, "Anti-Clip disabled for this map.\n" );
        return;
    }

#if METAMOD_PLUGIN_ASLP
    g_Hooks.RegisterHook( Hooks::aslp::PlayerPreMovement, @fnPreMovement );

    if( g_ClientPrediction )
    {
        g_Hooks.RegisterHook( Hooks::aslp::PostAddToFullPack, @fnPostAddToFullPack );
        Server::Framerate::SetCallback( @fnCheckFramerate );
    }

    if( !g_AllowProjectiles )
    {
        g_Hooks.RegisterHook( Hooks::aslp::ShouldCollide, @fnShouldCollide );
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
        g_Hooks.RemoveHook( Hooks::aslp::PostAddToFullPack, @fnPostAddToFullPack );
    }

    // If your server usually lags a lot you can decrease this multiplier 0.85 to something lower to not spam the hook de-activation
    if( g_ServerLagged && g_LastAverage > g_BestServerFrames * 0.85f )
    {
        g_ServerLagged = false;
        g_LagSpikes = 0;
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Anti-Clip] Server recovered. Re-enabling prediction.\n" );
        g_Hooks.RegisterHook( Hooks::aslp::PostAddToFullPack, @fnPostAddToFullPack );
    }
}

HookReturnCode PreMovement( aslp::PlayerMovement@ &out pmove, aslp::MetaResult &out meta_result )
{
    if( pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO )
    {
        return HOOK_CONTINUE;
    }

    uint currentPhysents = pmove.get_numphysent();
    uint newPhysents = 0;

    for( uint j = newPhysents; j < currentPhysents; j++ )
    {
        aslp::PhysicalEntity@ physent = pmove.get_physents(j);

        if( physent is null )
        {
            continue;
        }

        if( physent.IsPlayer() )
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

            auto player = g_PlayerFuncs.FindPlayerByIndex( pmove.player );

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

                auto player = g_PlayerFuncs.FindPlayerByIndex( pmove.player );

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

        pmove.set_physents( physent, newPhysents++ );
    }

    pmove.set_numphysent( newPhysents );

    return HOOK_CONTINUE;
}

HookReturnCode PostAddToFullPack( aslp::ClientPacket@ packet, aslp::MetaResult &out meta_result )
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

    aslp::EntityState@ state = packet.state;

    // Is the host intersecting the packet?
    if( entityPacket.IsAlive() && playerHost.IRelationship( entityPacket ) == R_AL && playerHost.Intersects( entityPacket ) )
    {
        if( g_InvisibleColliders )
        {
            state.effects |= EF_NODRAW;
        }
        else
        {
            state.rendermode = g_RenderMode;
            state.renderamt = g_RenderAmt;
        }
    }

    state.solid = SOLID_NOT;

    return HOOK_CONTINUE;
}

HookReturnCode ShouldCollide( CBaseEntity@ toucher, CBaseEntity@ other, aslp::MetaResult &out meta_resut, bool&out Collide )
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

    // Player can melee while inside an ally and hit something else
    if( other.IRelationship( toucher ) == R_AL && ( toucher.IsPlayer() || other.IsPlayer() ) )
    {
        if( other.Intersects( toucher ) )
        {
            Collide = false;
            meta_resut = aslp::MetaResult::Supercede;
        }
        return HOOK_HANDLED;
    }

    auto owner = g_EntityFuncs.Instance( other.pev.owner );

    // Don't touch allied projectiles
    if( owner !is null && toucher.IRelationship( owner ) == R_AL )
    {
        Collide = false;
        meta_resut = aslp::MetaResult::Supercede;
        return HOOK_HANDLED;
    }

    return HOOK_CONTINUE;
}
#endif
