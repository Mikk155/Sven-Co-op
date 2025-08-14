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

enum OnMapRestartType
{
    SurvivalRoundEnd = 0,
    PlayerLoadSaved = 1,
};

#define [HOOK_RETURNCODE]
return HOOK_CODE;
#end

#define [HOOK_METARES]
// MRES
#end

#define [HOOK_CALL]
bool META_SUPERCEDE = false;
HookReturnCode HOOK_CODE = HOOK_CONTINUE;

for( uint ui = 0; ui < Plugins.length(); ui++ )
{
    IPlugin@ plugin = Plugins[ ui ];

    HookCode result = plugin.<()>;

    if( result == HookCode.Continue )
    {
        continue;
    }

    if( result & HookCode.Supercede != 0 )
    {
        g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" prevented the game's original call for \"<()>\" " );
        META_SUPERCEDE = true;
    }

    if( result & HookCode.Handle != 0 )
    {
        g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" returned HOOK_HANDLED for hook \"<()>\" " );
        HOOK_CODE = HOOK_HANDLED;
    }

    if( result & HookCode.Break != 0 )
    {
        g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" breaked the chain of calls for hook \"<()>\"" );
        break;
    }
}
#end

// This class contains the base logic to call all instances of IPlugin
final class MPManager
{
    private array<IPlugin@> Plugins;

    void NewPluginEntry( IPlugin@ plugin )
    {
        Plugins.insertLast( @plugin );
    }

    void PluginInit()
    {
        GameHooks::PluginInit();

        [HOOK_CALL]
        OnPluginEnable();
        [end]
    }

    void PluginExit()
    {
        [HOOK_CALL]
        OnPluginDisable();
        [end]
    }

    void MapInit()
    {
        [HOOK_CALL]
        OnMapInit();
        [end]
    }

    void MapActivate()
    {
        CBaseEntity@ loadsaved = null;

        while( ( @loadsaved = g_EntityFuncs.FindEntityByClassname( loadsaved, "player_loadsaved" ) ) !is null )
        {
        }

        [HOOK_CALL]
        OnMapActivate();
        [end]
    }

    void MapStart()
    {
        [HOOK_CALL]
        OnMapStart();
        [end]
    }
}

MPManager g_MPManager;

void AddPlugin( IPlugin@ plugin )
{
    g_MPManager.NewPluginEntry( @plugin );
}

namespace GameHooks
{
    void PluginInit()
    {
        g_Hooks.RegisterHook( Hooks::Game::MapChange, @GameHooks::MapChange );
    }

    HookReturnCode MapChange( const string& in szNextMap )
    {
        [HOOK_CALL]
        OnMapChange( szNextMap );
        [end]
        [HOOK_RETURNCODE]
        [end]

        if( g_Engine.mapname == szNextMap )
        {
            // -TODO Get if trigger_changelevel,
            OnMapRestartType type;
PlayerLoadSaved
            if( g_SurvivalMode.IsActive() )
            {
                bool AnoyoneAlive;
                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    auto player = g_PlayerFuncs.FindPlayerByIndex( i );

                    if( player !is null && player.IsAlive() )
                    {
                        AnoyoneAlive = true;
                        break;
                    }
                }

                if( !AnoyoneAlive )
                {
                    type = OnMapRestartType::SurvivalRoundEnd;
                }
            }

            [HOOK_CALL]
            OnMapRestart( type );
            [end]
        }
    }
}
