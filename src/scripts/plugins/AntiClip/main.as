/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

namespace utils
{
    // True if ASLP is installed in the server.
    const bool HasMetamod = __CheckMetamod__();

    bool __CheckMetamod__()
    {
#if METAMOD_PLUGIN_ASLP
        if( true ) // Fix Unreachable code error
            return true;
#endif
        string buffer;
        snprintf( buffer, "[Error] %1 requires metamod plugin \"ASLP\" to work.\n", g_Module.GetModuleName() );
        g_EngineFuncs.ServerPrint( buffer );
        g_EngineFuncs.ServerPrint( "Some features may work poorly or not work at all.\n" );
        g_EngineFuncs.ServerPrint( "Install metamod at: https://github.com/Mikk155/Sven-Co-op\n" );
        return false;
    }
}
void MapInit()
{
    g_Game.PrecacheOther( "monster_barney" );
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

#if METAMOD_PLUGIN_ASLP
    ToggleState(true);
#endif
}

#if METAMOD_PLUGIN_ASLP
class CAntiClipConfig
{
    // Set to false to disallow ally npcs clipping
    bool NPCClipping = false;

    // Allow boosting by jumping over a player
    bool AllowBoosting = true;

    // Completelly hide intersecting players
    bool DontDrawPlayers = false;

    // Above 0 is the render settings to set. leave to 0 to not use AddToFullPack hook.
    uint8 RenderMode = kRenderTransTexture;
    uint8 RenderAmt = 100;

    bool ShouldPacketFilter {
        get {
            return ( this.DontDrawPlayers || this.RenderMode > kRenderNormal  );
        }
    }
}

CAntiClipConfig g_Config;

bool g_State;

void ToggleState( bool state )
{
    if( state == g_State )
        return;

    g_State = state;

    if( state )
    {
        if( g_Config.ShouldPacketFilter )
        {
            g_Hooks.RegisterHook( Hooks::aslp::Engine::PostAddToFullPack, @PostAddToFullPack );
        }

        g_Hooks.RegisterHook( Hooks::aslp::Engine::PreMovement, @PreMovement );
    }
    else
    {
        g_Hooks.RemoveHook( Hooks::aslp::Engine::PreMovement, @PreMovement );
        g_Hooks.RemoveHook( Hooks::aslp::Engine::PostAddToFullPack, @PostAddToFullPack );
    }
}

void Command( const CCommand@ args )
{
    CBasePlayer@ player = g_ConCommandSystem.GetCurrentPlayer();

    if( player is null )
        return;

    if( atoi( args[1] ) == 1 || args[1] == "on" || args[1] == "true" )
    {
        if( !g_State )
        {
            ToggleState(true);
        }
    }
    else if( g_State )
    {
        ToggleState(false);
    }
}

CClientCommand CMD( "anticlip", "Toggle AntiClip, on/off | 1/0", @Command, ConCommandFlag::AdminOnly );

HookReturnCode PreMovement( playermove_t@& out pmove, META_RES& out meta_result )
{
    if( pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO )
    {
        return HOOK_CONTINUE;
    }

    // 0 is worldspawn so increase one
    CBasePlayer@ player = g_PlayerFuncs.FindPlayerByIndex( pmove.player_index + 1 );

    int numphysent = -1;

    for( int j = numphysent; j <= pmove.numphysent; j++ )
    {
        physent_t@ physent = pmove.GetPhysEntByIndex(j);

        if( physent is null )
            continue;

        // This is a player
        if( physent.player != 0 )
        {
            // No boosting? Skip immediatelly
            if( !g_Config.AllowBoosting )
                continue;

            if( ( player.pev.button & IN_DUCK ) != 0 )
                continue;

            CBasePlayer@ other = g_PlayerFuncs.FindPlayerByIndex( physent.info );

            if( other is null )
                continue;

            // Standing player
            if( ( other.pev.button & IN_DUCK ) == 0 && pmove.origin.z < physent.origin.z + 72 )
                continue;

            // Crouching player
            if( pmove.origin.z < physent.origin.z + 54 )
                continue;
        }
        else if( !g_Config.NPCClipping )
        {
            CBaseEntity@ entity = g_EntityFuncs.Instance( physent.info );

            if( entity !is null )
            {
                // Do not clip on ally monsters
                if( player.IRelationship( entity ) == R_AL )
                {
#if BAD_OFFSET_LAZY
                    if( !g_Config.AllowBoosting )
                        continue;

                    if( pmove.origin.z < physent.origin.z + physent.maxs.z )
#endif
                        continue;
                }
            }
        }

        pmove.SetPhysEntByIndex( physent, numphysent++ );
    }

    // Set updated list.
    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode PostAddToFullPack( ClientPacket@ packet, META_RES& out meta_result )
{
    // If npc is clipping then we don't care about non-player entities.
    if( g_Config.NPCClipping && packet.playerIndex == 0 )
        return HOOK_CONTINUE;

    if( packet.host is null || packet.entity is null )
        return HOOK_CONTINUE;

    // Skip if the packet is the host
    if( packet.entity is packet.host )
        return HOOK_CONTINUE;

    auto playerHost = g_EntityFuncs.Instance( packet.host );
    auto entityPacket = g_EntityFuncs.Instance( packet.entity );

    if( playerHost is null || entityPacket is null )
        return HOOK_CONTINUE;

    // Skip if the packet is not a player and we're not checking for NPCs
    if( g_Config.NPCClipping && !entityPacket.IsPlayer() )
        return HOOK_CONTINUE;

    // Is the host intersecting the packet?
    if( playerHost.IRelationship( entityPacket ) == R_AL && playerHost.Intersects( entityPacket ) )
    {
        if( g_Config.DontDrawPlayers )
        {
            packet.state.effects |= EF_NODRAW;
        }
        else
        {
            packet.state.rendermode = g_Config.RenderMode;
            packet.state.renderamt = g_Config.RenderAmt;
        }
    }

    return HOOK_CONTINUE;
}
