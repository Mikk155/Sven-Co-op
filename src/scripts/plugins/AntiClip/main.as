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

bool g_Metamod;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk | Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

#if METAMOD_PLUGIN_ASLP
    g_Metamod = true;
    ToggleState(true);
#endif
}

void MapStart()
{
    if( !g_Metamod )
    {
        g_Game.AlertMessage( at_console, "[Error] Plugin AntiClip.as requires metamod aslp.dll to work.\n" );
        g_Game.AlertMessage( at_console, "https://github.com/Mikk155/Sven-Co-op\n" );
    }
}

#if METAMOD_PLUGIN_ASLP

class CAntiClipConfig
{
    // Completelly hide intersecting players
    bool DontDrawPlayers = false;

    // Above 0 is the render settings to set. leave to 0 to not use AddToFullPack hook.
    uint8 RenderMode = 4;
    uint8 RenderAmt = 100;

    bool ShouldPacketFilter {
        get {
            return ( this.DontDrawPlayers || g_Config.RenderMode > 0 );
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

    int numphysent = -1;

    for( int j = numphysent; j < pmove.numphysent; j++ )
    {
        auto physent = pmove.GetPhysEntByIndex(j);

        if( physent is null )
            continue;

        // Is this a player?
        if( physent.player != 0 )
        {
            // Don't skip if we're "Boosting" onto another player.
            if( pmove.origin.z < physent.origin.z + 54 )
                continue;
        }

        pmove.SetPhysEntByIndex( physent, numphysent++ );
    }

    // Set updated list.
    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode PostAddToFullPack( ClientPacket@ packet, META_RES& out meta_result )
{
    if( packet.host is null || packet.entity is null )

    // Skip if the packet is the host
    if( packet.entity is packet.host )
        return HOOK_CONTINUE;

    auto playerHost = g_EntityFuncs.Instance( packet.host );
    auto playerPacket = g_EntityFuncs.Instance( packet.entity );

    if( playerHost is null || playerPacket is null )
        return HOOK_CONTINUE;

    // Skip if the packet is not a player
    if( !playerPacket.IsPlayer() )
        return HOOK_CONTINUE;

    // Is the host intersecting the packet?
    if( playerHost.Intersects( playerPacket ) )
    {
        if( g_Config.DontDrawPlayers )
        {
            packet.state.effects |= EF_NODRAW;
        }
        else if( g_Config.RenderMode > 0 )
        {
            packet.state.rendermode = g_Config.RenderMode;
            packet.state.renderamt = g_Config.RenderAmt;
        }
    }

    return HOOK_CONTINUE;
}
