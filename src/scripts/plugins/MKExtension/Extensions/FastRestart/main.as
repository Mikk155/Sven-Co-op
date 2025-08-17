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

namespace Extensions
{
    namespace FastRestart
    {
        CLogger@ Logger;

        string GetName()
        {
            return "FastRestart";
        }

        void OnExtensionInit( Hooks::IExtensionInit@ info )
        {
            @Logger = CLogger( "Fast Restart" );
            Logger.info( "Registered \"" + GetName() + "\" at index \"" + info.ExtensionIndex + "\"" );
        }

        // -TODO To json or any kind of config
        const int SEARCH_RADIUS = 1024;
        const bool SHOULD_WAIT_MEDIC = true;
        const float RELOAD_TIME = 1.5f;

        bool FindMedicNearby( const string &in name )
        {
            CBaseEntity@ medic = null;

            while( ( @medic = g_EntityFuncs.FindEntityByClassname( @medic, name ) ) !is null )
            {
                CBaseMonster@ monster = cast<CBaseMonster>(medic);

                if( monster is null )
                    continue;

                if( !monster.IsPlayerAlly() )
                    continue;

                CBaseEntity@ corpse = null;

                while( ( @corpse = g_EntityFuncs.FindEntityByClassname( corpse, 'deadplayer' ) ) !is null )
                {
                    if( ( corpse.pev.origin - monster.pev.origin ).Length() <= SEARCH_RADIUS )
                    {
                        return true;
                    }
                }

                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    auto player = g_PlayerFuncs.FindPlayerByIndex(i);

                    if( player !is null && !player.IsAlive() && !player.GetObserver().IsObserver()
                    && ( ( player.pev.origin - monster.pev.origin ).Length() <= SEARCH_RADIUS ) )
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        void OnMapThink( Hooks::IHookInfo@ info )
        {
            if( !g_SurvivalMode.IsActive() )
                return; // -TODO Should disable this on map init instead :thinkies:

            if( g_PlayerFuncs.GetNumPlayers() <= 0 )
                return;

            if( player::NumberOfPlayers( player::FindFilter::Dead ).length() > 0 )
                return;

            if( SHOULD_WAIT_MEDIC )
            {
                if( FindMedicNearby( "monster_scientist" ) )
                    return;

                if( FindMedicNearby( "monster_human_medic_ally" ) )
                    return;
            }

            CBaseEntity@ loadsave = g_EntityFuncs.CreateEntity( "player_loadsaved", null, true );

            loadsave.pev.targetname = "mke_fastrestart";

            g_EntityFuncs.DispatchKeyValue( loadsave.edict(), "loadtime", RELOAD_TIME );

            loadsave.Use( null, null, USE_ON, 0.0f );
            OnMapChange::g_MapChangeType = MapChangeType::MKExtensionHandled;
        }
    }
}
