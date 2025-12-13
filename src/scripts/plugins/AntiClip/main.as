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

bool g_State;

void ToggleState( int state )
{
    if( state == g_State )
        return;

    g_State = state;

    if( state )
    {
        g_Hooks.RegisterHook( Hooks::Engine::PM_Move, @PM_Move );
        g_Hooks.RegisterHook( Hooks::Engine::AddToFullPackPost, @AddToFullPackPost );
    }
    else
    {
        g_Hooks.RemoveHook( Hooks::Engine::PM_Move, @PM_Move );
        g_Hooks.RemoveHook( Hooks::Engine::AddToFullPackPost, @AddToFullPackPost );
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

#if METAMOD_PLUGIN_ASLP
HookReturnCode PM_Move(playermove_t@& out pmove, int server, META_RES& out meta_result)
{
    if (pmove.spectator != 0 || pmove.dead != 0 || pmove.deadflag != DEAD_NO)
    {
        meta_result = MRES_IGNORED;
        return HOOK_CONTINUE;
    }

    int numphysent = -1;

    for (int j = numphysent; j < pmove.numphysent; j++)
    {
        if (pmove.GetPhysEntByIndex(j) !is null && pmove.GetPhysEntByIndex(j).player == 0)
        {
            pmove.SetPhysEntByIndex(pmove.GetPhysEntByIndex(j), numphysent++);
        }
    }

    pmove.numphysent = numphysent;

    return HOOK_CONTINUE;
}

HookReturnCode AddToFullPackPost(entity_state_t@& out state, int entindex, edict_t @ent, edict_t@ host, int hostflags, int player, META_RES& out meta_result, int& out result)
{
    if( host is null || ent is null || ent is host )
        return HOOK_CONTINUE;

    auto playerHost = g_EntityFuncs.Instance( host );
    auto playerPacket = g_EntityFuncs.Instance( ent );

    if( host is null || ent is null )
        return HOOK_CONTINUE;

    if( playerHost.Intersects( playerPacket ) )
    {
        state.rendermode = 4;
        state.renderamt = 100;
    }

    return HOOK_CONTINUE;
}
#endif
