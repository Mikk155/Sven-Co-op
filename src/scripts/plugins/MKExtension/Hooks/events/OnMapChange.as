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

namespace Hooks
{
    enum MapChangeType
    {
        Unknown = 0,
        SurvivalRoundEnd,
        TriggerChangelevel,
        PlayerLoadSaved,
        GameEnd,
        MapCycleTimeOut,
        FragsLimitReached,
        MKExtensionHandled
    };

    class IMapChange : IHookInfo
    {
        private string __NextMap__;

        string NextMap {
            get const { return this.__NextMap__; }
        }

        MapChangeType Type {
            get const { return OnMapChange::g_MapChangeType; }
        }

        IMapChange( const string &in _NextMap )
        {
            this.__NextMap__ = _NextMap;
        }
    }

    namespace OnMapChange
    {
        bool IsEnabled = false;

        void MapInit()
        {
            if( IsEnabled )
            {
                g_CustomEntityFuncs.RegisterCustomEntity( "Hooks::OnMapChange::OnMapChangeEntity", "mke_hook_onmapchange" );
            }
        }

        void CreateWatchers( const string &in classname, MapChangeType Type )
        {
            CBaseEntity@ entity = null;

            while( ( @entity = g_EntityFuncs.FindEntityByClassname( @entity, classname ) ) !is null )
            {
                CBaseEntity@ watcher = g_EntityFuncs.CreateEntity( "mke_hook_onmapchange", null, true );
                watcher.pev.targetname = entity.pev.targetname;
                watcher.pev.max_health = float(int(Type));

                if( classname == "trigger_changelevel"
                && !string( entity.pev.targetname ).IsEmpty()
                && ( entity.pev.spawnflags & 2 ) == 0 // Use-only
                )
                {
                    watcher.pev.model = entity.pev.model;
                    watcher.pev.solid = SOLID_TRIGGER;
                    g_EntityFuncs.SetModel( watcher, string( watcher.pev.model ) );
                    g_EntityFuncs.SetOrigin( watcher, entity.pev.origin );
                    g_EntityFuncs.SetSize( watcher.pev, entity.pev.mins, entity.pev.maxs );
                }
            }
        }

        void MapActivate()
        {
            if( !IsEnabled )
                return;

            CreateWatchers( "trigger_changelevel", MapChangeType::TriggerChangelevel );
            CreateWatchers( "game_end", MapChangeType::GameEnd );
            CreateWatchers( "player_loadsaved", MapChangeType::PlayerLoadSaved );

            CBaseEntity@ entity = g_EntityFuncs.CreateEntity( "mke_hook_onmapchange", null, true );
            entity.Use( null, null, USE_SET, 0.0f );
        }

        MapChangeType g_MapChangeType;

        class HookMapChange : Hook
        {
            HookMapChange( const string &in name )
            {
                super(name);
            }

            void Register()
            {
                IsEnabled = true;
                g_Hooks.RegisterHook( Hooks::Game::MapChange, @Hooks::OnMapChange::MapChange );
                Hook::Register();
            }
        }

        void Register()
        {
            g_MKExtensionManager.RegisterHook( @HookMapChange( "OnMapChange" ) );
        }

        // Stupid ass game
        float FIX_FUCKING_LISTEN_SERVERS;

        HookReturnCode MapChange( const string& in szNextMap )
        {
            if( !g_EngineFuncs.IsDedicatedServer() )
            {
                // could be longer, idk another way to avoid this shit
                if( FIX_FUCKING_LISTEN_SERVERS + 5.0f > g_Engine.time )
                {
                    return HOOK_CONTINUE;
                }
            }

            Hooks::IMapChange@ info = Hooks::IMapChange(szNextMap);
            g_MKExtensionManager.CallHook( "OnMapChange", @info );

            g_MapChangeType = MapChangeType::Unknown;

            if( info.code & HookCode::Handle != 0 )
                return HOOK_HANDLED;

            return HOOK_CONTINUE;
        }

        class OnMapChangeEntity : ScriptBaseEntity
        {
            private bool IsTimeLimited;
            private float FragsLimit;

            void Spawn()
            {
                self.pev.solid = SOLID_NOT;
                self.pev.movetype = MOVETYPE_NONE;
            }

            void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
            {
                if( useType == USE_SET )
                {
                    FragsLimit = g_EngineFuncs.CVarGetFloat( "mp_fraglimit" );
                    IsTimeLimited = int( g_EngineFuncs.CVarGetFloat( "mp_timelimit" ) ) > 0;

                    SetThink( ThinkFunction( this.Think ) );
                    self.pev.nextthink = g_Engine.time + 1.0f;
                }
                else
                {
                    g_MapChangeType = MapChangeType( int( self.pev.max_health ) );
                }
            }

            void Touch( CBaseEntity@ pOther )
            {
                // This may not support multisource x[
                if( pOther !is null && pOther.IsPlayer() )
                {
                    g_MapChangeType = MapChangeType( int( self.pev.max_health ) );
                }
            }

            void Think()
            {
                // It's been already decided.
                if( g_MapChangeType != MapChangeType::Unknown )
                {
                    g_EntityFuncs.Remove( self );
                    return;
                }

                // Some plugins/scripts may enable support on the fly so check regardless of the current support.
                if( g_SurvivalMode.IsActive() && player::NumberOfPlayers( player::FindFilter::Dead ).length() <= 0 )
                {
                    g_MapChangeType = MapChangeType::SurvivalRoundEnd;
                    g_EntityFuncs.Remove( self );
                    return;
                }
                else if( IsTimeLimited && int( g_EngineFuncs.CVarGetFloat( "mp_timeleft" ) ) <= 0 )
                {
                    g_MapChangeType = MapChangeType::MapCycleTimeOut;
                    g_EntityFuncs.Remove( self );
                    return;
                }
                else if( FragsLimit > 0 )
                {
                    for( int i = 1; i <= g_Engine.maxClients; i++ )
                    {
                        auto player = g_PlayerFuncs.FindPlayerByIndex(i);

                        if( player !is null && player.pev.frags >= FragsLimit )
                        {
                            g_MapChangeType = MapChangeType::FragsLimitReached;
                            g_EntityFuncs.Remove( self );
                            return;
                        }
                    }
                }

                self.pev.nextthink = g_Engine.time + 1.0f;
            }
        }
    }
}
