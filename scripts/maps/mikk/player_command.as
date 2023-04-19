/*

// INSTALLATION:

#include "mikk/game_stealth"

*/
#include "utils"

bool player_command_register = g_Util.CustomEntity( 'player_command::player_command','player_command' );

namespace player_command
{
    void ScriptInfo()
    {
        g_Information.SetInformation
        ( 
            'Script: game_debug\n' +
            'Description: Entity wich when fired, shows a debug message, also shows other entities being triggered..\n' +
            'Author: Mikk\n' +
            'Discord: ' + g_Information.GetDiscord( 'mikk' ) + '\n'
            'Server: ' + g_Information.GetDiscord() + '\n'
            'Github: ' + g_Information.GetGithub()
        );
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_debug::CBaseDebug", "game_debug" );
    }

    class player_command : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
                return;

            if( spawnflag( 1 ) )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    ExecCommand( pPlayer, self.pev.message );
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                ExecCommand( cast<CBasePlayer@>( pActivator ), self.pev.message );
            }
        }

        void ExecCommand( CBaseEntity@ pPlayer, const string command )
        {
            g.Util.ExecPlayerCommand( pPlayer, command );

            g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
        }
    }
}