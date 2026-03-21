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

    meta_api::json::Deserialize( "store/BMLongJump.json", g_Cache );

    g_Hooks.RegisterHook( Hooks::Game::MapChange, MapChangeHook( function( const string&in mapname )
    {
        Shutdown();
        return HOOK_CONTINUE;
    } ));

#if METAMOD_PLUGIN_ASLP
    g_HasMetamod = true;
#endif

#if METAMOD_DEBUG
//    g_HasMetamod = false;
    g_PluginJustLoaded = false;
#endif

    if( !g_HasMetamod )
    {
        @fnPostThink = PlayerPostThinkHook( PostThink );
    }

    MapInit();
}

dictionary g_Cache;
bool g_ShouldWriteCache;

void Shutdown()
{
    if( g_ShouldWriteCache )
    {
        meta_api::json::Serialize( g_Cache, -1, "BMLongJump" );
    }
}

void PluginExit()
{
    Shutdown();
}

CClientCommand g_PlayerCache( "longjump", "ChatRoles", function( const CCommand@ args )
{
    auto player = g_ConCommandSystem.GetCurrentPlayer();

    if( player is null )
        return;

    if( args.ArgC() == 1 )
    {
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "--- Black Mesa Long Jump Module ---\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, ".longjump mode\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "- Toggle the mode to use the longjump module\n" );
        return;
    }

    if( args.ArgC() == 2 )
    {
        string arg = args[1];

        if( arg == "mode" )
        {
            string id = g_EngineFuncs.GetPlayerAuthId(player.edict());
            bool mode = !bool( g_Cache[id] );
            g_Cache[id] = mode;

            string buffer;
            snprintf( buffer, "Updated long jump mode to %1\n", mode ? "crouch + jump" : "double jump tap" );
            g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, buffer );
            g_ShouldWriteCache = true;
        }
    }
} );

bool g_Precached;
bool g_PluginJustLoaded = true;
bool g_HasMetamod;

#if METAMOD_PLUGIN_ASLP
PreMovementHook@ fnPreMovement = PreMovementHook( PreMovement );
#endif

PlayerPostThinkHook@ fnPostThink;
PlayerTakeDamageHook@ fnTakeDamage = PlayerTakeDamageHook( TakeDamage );

int g_Speed = 400;
int g_HeightSpeed = 300;
bool g_HasEffects;
string g_JumpSound;
string g_FallSound;
bool g_ShouldReloadJson = true;
bool g_FallDamage = true;
array<string> g_BlacklistedMaps;

void MapInit()
{
    if( fnPostThink !is null )
    {
        g_Hooks.RemoveHook( Hooks::Player::PlayerPostThink, @fnPostThink );
    }

    g_Hooks.RemoveHook( Hooks::Player::PlayerTakeDamage, @fnTakeDamage );

#if METAMOD_PLUGIN_ASLP
    g_Hooks.RemoveHook( Hooks::aslp::Player::PreMovement, @fnPreMovement );
#endif

    if( g_ShouldReloadJson )
    {
        dictionary data;
        if( meta_api::json::Deserialize( "BMLongJump.json", data ) )
        {
            g_BlacklistedMaps = meta_api::json::ToArray( data[ "map_blacklist" ] );
            g_ShouldReloadJson = bool( data[ "reload" ] );
            data.get( "speed", g_Speed );
            data.get( "jump_sound", g_JumpSound );
            data.get( "fall_sound", g_FallSound );
            data.get( "supress_fall_damage", g_FallDamage );
            data.get( "height_speed", g_HeightSpeed );
            data.get( "jump_effect", g_HasEffects );
        }
    }

    if( Server::IsMapListed( g_BlacklistedMaps, true, g_ShouldReloadJson ) )
        return;

#if METAMOD_PLUGIN_ASLP
    g_Hooks.RegisterHook( Hooks::aslp::Player::PreMovement, @fnPreMovement );
#endif

    if( g_FallDamage )
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @fnTakeDamage );
    }

    if( !g_HasMetamod )
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @fnPostThink );
    }

    // Use without precaching and playing sounds/effects.
    if( g_PluginJustLoaded )
    {
        g_PluginJustLoaded = false;
        return;
    }

    g_Precached = true;

    if( !g_JumpSound.IsEmpty() )
    {
        string buffer;

        snprintf(buffer, "sound/%1", g_JumpSound );
        g_Game.PrecacheGeneric( buffer );
        g_SoundSystem.PrecacheSound( g_JumpSound );
    }

    if( !g_FallSound.IsEmpty() )
    {
        string buffer;

        snprintf(buffer, "sound/%1", g_FallSound );
        g_Game.PrecacheGeneric( buffer );
        g_SoundSystem.PrecacheSound( g_FallSound );
    }

    if( g_HasEffects )
    {
        g_LaserBeam = g_Game.PrecacheModel( "sprites/laserbeam.spr" );
        g_Bubble = g_Game.PrecacheModel( "sprites/bubble.spr" );
    }
}

int g_LaserBeam;
int g_Bubble;

void CreateFX( CBasePlayer@ player, bool isLanding )
{
    if( !g_Precached )
        return;

    if( player is null )
        return;

    if( isLanding )
    {
        if( !g_FallSound.IsEmpty() )
        {
            g_SoundSystem.PlaySound( player.edict(), CHAN_STATIC, g_FallSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
    }
    else
    {
        if( !g_JumpSound.IsEmpty() )
        {
            g_SoundSystem.PlaySound( player.edict(), CHAN_STATIC, g_JumpSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }
    }

    if( !g_HasEffects )
        return;

    TraceResult tr;
    g_Utility.TraceLine( player.pev.origin, player.pev.origin + Vector( 0, 0, -90 ), ignore_monsters, player.edict(), tr );

    {
        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
            m.WriteByte( TE_BEAMDISK);
            m.WriteCoord( tr.vecEndPos.x );
            m.WriteCoord( tr.vecEndPos.y );
            m.WriteCoord( tr.vecEndPos.z );
            m.WriteCoord( tr.vecEndPos.x );
            m.WriteCoord( tr.vecEndPos.y );
            m.WriteCoord( tr.vecEndPos.z + 128 );
            m.WriteShort( g_LaserBeam );
            m.WriteByte( 0 ); // startFrame
            m.WriteByte( 0 ); // frameRate
            m.WriteByte( 8 ); // life
            m.WriteByte( 1 ); // "width" - has no effect
            m.WriteByte( 0 ); // "noise" - has no effect
            m.WriteByte( 100 );
            m.WriteByte( 100 );
            m.WriteByte( 100 );
            m.WriteByte( 50 );
            m.WriteByte( 0 ); // scrollSpeed
        m.End();
    }
    {
        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
            m.WriteByte( TE_BUBBLES );
            m.WriteCoord( player.pev.absmin.x );
            m.WriteCoord( player.pev.absmin.y );
            m.WriteCoord( player.pev.absmin.z );
            m.WriteCoord( player.pev.absmax.x );
            m.WriteCoord( player.pev.absmax.y );
            m.WriteCoord( player.pev.absmax.z );
            m.WriteCoord(40 );
            m.WriteShort( g_Bubble );
            m.WriteByte( 70 );
            m.WriteCoord( 50 );
        m.End();
    }
    {
        NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
            m.WriteByte(TE_BEAMTORUS);
            m.WriteCoord( tr.vecEndPos.x );
            m.WriteCoord( tr.vecEndPos.y );
            m.WriteCoord( tr.vecEndPos.z);
            m.WriteCoord( tr.vecEndPos.x );
            m.WriteCoord( tr.vecEndPos.y );
            m.WriteCoord( tr.vecEndPos.z + 128 );
            m.WriteShort( g_LaserBeam );
            m.WriteByte( 0 ); // frame
            m.WriteByte( 0 ); // framerate
            m.WriteByte( 5 ); // life
            m.WriteByte( 16 ); // width
            m.WriteByte( 0 ); // noise
            m.WriteByte( 255 ); // R
            m.WriteByte( 255 ); // G
            m.WriteByte( 255 ); // B
            m.WriteByte( 30 ); // A
            m.WriteByte( 0 ); // scrollspeed
        m.End();
    }
}

enum JumpState
{
    None = 0,
    JustJumped,
    JumpReleased,
    JumpTwice
};

array<JumpState> g_PlayerData(g_Engine.maxClients);

bool CanPlayerSuperLongjump( CBasePlayer@ player )
{
    if( player is null || !player.m_fLongJump || player.pev.waterlevel > WATERLEVEL_FEET || !player.IsAlive() || player.pev.movetype == MOVETYPE_NOCLIP )
        return false;

    return true;
}

bool ShouldPreventFall( CBasePlayer@ player )
{
    if( ( player.pev.flags & FL_ONGROUND ) == 0 && player.m_flFallVelocity >= 450 && player.pev.waterlevel == WATERLEVEL_DRY )
    {
        TraceResult tr;
        g_Utility.TraceLine( player.pev.origin, player.pev.origin + Vector( 0, 0, -256 ), dont_ignore_monsters, player.edict(), tr );

        if( tr.vecEndPos[2] + 128 >= player.pev.origin[2] )
        {
            CreateFX( player, true );

            return true;
        }
    }

    return false;
}

bool ShouldPlayerSuperJump( CBasePlayer@ player, Vector&out direction )
{
    int index = player.entindex() - 1;

    if( ( player.pev.flags & FL_ONGROUND ) != 0 )
    {
        g_PlayerData[index] = JumpState::None;
        return false;
    }

    JumpState state = g_PlayerData[index];

    bool mode = bool( g_Cache[ g_EngineFuncs.GetPlayerAuthId( player.edict() ) ] );

    if( !mode )
    {
    }

    switch( state )
    {
        case JumpState::JumpTwice:
        {
            return false;
        }
        case JumpState::JumpReleased:
        {
            if( ( player.pev.button & IN_JUMP ) != 0 )
            {
                g_PlayerData[index] = JumpState::JumpTwice;

                if( ( player.pev.button & IN_FORWARD ) != 0 )
                {
                    direction = g_Engine.v_forward * ( g_Speed * 1.6f );
                }
                else if( ( player.pev.button & IN_BACK ) != 0 )
                {
                    direction = -g_Engine.v_forward * ( g_Speed * 1.6f );
                }
                else if( ( player.pev.button & IN_MOVERIGHT ) != 0 )
                {
                    direction = g_Engine.v_right * ( g_Speed * 1.6f );
                }
                else if( ( player.pev.button & IN_MOVELEFT ) != 0 )
                {
                    direction = -g_Engine.v_right * ( g_Speed * 1.6f );
                }
                else
                {
                    return false;
                }

                direction.z = g_HeightSpeed;

                player.SetAnimation( PLAYER_SUPERJUMP, 1 );

                CreateFX( player, false );

                return true;
            }
            return false;
        }
        case JumpState::JustJumped:
        {
            if( ( player.pev.button & IN_JUMP ) == 0 )
            {
                g_PlayerData[index] = JumpState::JumpReleased;
            }
            return false;
        }
        case JumpState::None:
        default:
        {
            if( ( player.pev.flags & FL_ONGROUND ) == 0 )
            {
                g_PlayerData[index] = JumpState::JustJumped;
            }
            return false;
        }
    }
}

#if METAMOD_PLUGIN_ASLP
HookReturnCode PreMovement( aslp::playermove_t@& out pmove, aslp::MetaResult &out meta_result )
{
    if( pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO )
        return HOOK_CONTINUE;

    auto player = g_PlayerFuncs.FindPlayerByIndex( pmove.player );

    if( !CanPlayerSuperLongjump( player ) )
        return HOOK_CONTINUE;

    Vector direction; // For some reason Vector&out on player.pev.velocity sets it to g_vecZero
    if( ShouldPlayerSuperJump( player, direction ) )
    {
        pmove.velocity = direction;
    }
    else if( g_FallDamage && ShouldPreventFall( player ) )
    {
        pmove.flFallVelocity = pmove.velocity.z = 0;
    }

    return HOOK_CONTINUE;
}
#endif

HookReturnCode PostThink( CBasePlayer@ player )
{
    if( player is null || !player.m_fLongJump || !player.IsAlive() )
        return HOOK_CONTINUE;

    if( !CanPlayerSuperLongjump( player ) )
        return HOOK_CONTINUE;

    Vector direction; // For some reason Vector&out on player.pev.velocity sets it to g_vecZero
    if( ShouldPlayerSuperJump( player, direction ) )
    {
        player.pev.velocity = direction;
    }
    else if( g_FallDamage && ShouldPreventFall( player ) )
    {
        player.m_flFallVelocity = player.pev.velocity.z = 0;
    }

    return HOOK_CONTINUE;
}

HookReturnCode TakeDamage( DamageInfo@ pDamageInfo )
{
    if( pDamageInfo.pVictim is null )
        return HOOK_CONTINUE;

    CBasePlayer@ player = cast<CBasePlayer@>( pDamageInfo.pVictim );

    if( player is null )
        return HOOK_CONTINUE;

    if( ( pDamageInfo.bitsDamageType & DMG_FALL ) != 0 && player.m_fLongJump )
    {
        CreateFX( player, true );

        pDamageInfo.flDamage = 0;
        player.pev.velocity.z = 0;
    }

    return HOOK_CONTINUE;
}
