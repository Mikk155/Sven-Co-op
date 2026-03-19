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
        if( meta_api::json::Deserialize( "scripts/plugins/BMLongJump.json", data ) )
        {
            g_BlacklistedMaps = meta_api::json::ToArray( data[ "map_blacklist" ] );
            g_ShouldReloadJson = bool( data[ "reload" ] );
            data.get( "speed", g_Speed );
            data.get( "jump_sound", g_JumpSound );
            data.get( "fall_sound", g_FallSound );
            data.get( "supress_fall_damage", g_FallDamage );
            data.get( "height_speed", g_HeightSpeed );
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
    if( ( player.pev.flags & FL_ONGROUND ) == 0 && -player.pev.velocity.z >= 350 && player.pev.waterlevel == WATERLEVEL_DRY )
    {
        TraceResult tr;
        g_Utility.TraceLine( player.pev.origin, player.pev.origin + Vector( 0, 0, -256 ), dont_ignore_monsters, player.edict(), tr );

        if( tr.vecEndPos[2] + 128 >= player.pev.origin[2] )
        {
            if( g_Precached && !g_FallSound.IsEmpty() )
            {
                g_SoundSystem.PlaySound( player.edict(), CHAN_STATIC, g_FallSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
            }

            DoEffect( player );

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

                if( g_Precached && !g_JumpSound.IsEmpty() )
                {
                    g_SoundSystem.PlaySound( player.edict(), CHAN_STATIC, g_JumpSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
                }

                DoEffect( player );

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
HookReturnCode PreMovement( playermove_t@& out pmove, MetaResult &out meta_result )
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

void DoEffect( CBasePlayer@ player )
{
    if( g_PluginJustLoaded )
        return;

    TraceResult tr;
    g_Utility.TraceLine( player.pev.origin, player.pev.origin + Vector( 0, 0, -90 ), ignore_monsters, player.edict(), tr );

    NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
        msg.WriteByte(TE_BEAMTORUS);
        msg.WriteCoord( tr.vecEndPos.x );
        msg.WriteCoord( tr.vecEndPos.y );
        msg.WriteCoord( tr.vecEndPos.z);
        msg.WriteCoord( tr.vecEndPos.x );
        msg.WriteCoord( tr.vecEndPos.y );
        msg.WriteCoord( tr.vecEndPos.z + 128 );
        msg.WriteShort( g_EngineFuncs.ModelIndex( "sprites/laserbeam.spr" ) );
        msg.WriteByte( 0 ); // frame
        msg.WriteByte( 0 ); // framerate
        msg.WriteByte( 5 ); // life
        msg.WriteByte( 16 ); // width
        msg.WriteByte( 0 ); // noise
        msg.WriteByte( 255 ); // R
        msg.WriteByte( 255 ); // G
        msg.WriteByte( 255 ); // B
        msg.WriteByte( 60 ); // A
        msg.WriteByte( 0 ); // scrollspeed
    msg.End();
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
        if( g_Precached && !g_FallSound.IsEmpty() )
        {
            g_SoundSystem.PlaySound( player.edict(), CHAN_STATIC, g_FallSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        }

        DoEffect( player );

        pDamageInfo.flDamage = 0;
        player.pev.velocity.z = 0;
    }

    return HOOK_CONTINUE;
}
