#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"
#include "utils/ScriptBaseLanguages"

namespace player_inbutton
{
    void Register()
    {
        g_Util.CustomEntity( 'player_inbutton' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_inbutton' ) +
            g_ScriptInfo.Description( 'Fire its target if the player uses a in_button' ) +
            g_ScriptInfo.Wiki( 'player_inbutton' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum player_inbutton_spawnflags
    {
        PLAYERS_ANYWHERE = 1,
        NO_KEY_INPUT_MSG = 2
    }

    class player_inbutton : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Spawn() 
        {
            self.pev.movetype   = MOVETYPE_NONE;
            self.pev.solid      = SOLID_NOT;
            self.pev.effects   |= EF_NODRAW;

            SetBoundaries();

            if( int( self.pev.frags ) == 1 ) self.pev.netname = 'attack';
            else if( int( self.pev.frags ) == 2 ) self.pev.netname = 'jump';
            else if( int( self.pev.frags ) == 4 ) self.pev.netname = 'duck';
            else if( int( self.pev.frags ) == 8 ) self.pev.netname = 'forward';
            else if( int( self.pev.frags ) == 16 ) self.pev.netname = 'back';
            // else if( int( self.pev.frags ) == 64 ) self.pev.netname = 'cancelselect';
            else if( int( self.pev.frags ) == 128 ) self.pev.netname = 'left';
            else if( int( self.pev.frags ) == 256 ) self.pev.netname = 'right';
            else if( int( self.pev.frags ) == 512 ) self.pev.netname = 'moveleft';
            else if( int( self.pev.frags ) == 1024 ) self.pev.netname = 'moveright';
            else if( int( self.pev.frags ) == 2048 ) self.pev.netname = 'attack2';
            // else if( int( self.pev.frags ) == 4096 ) self.pev.netname = 'speed';
            else if( int( self.pev.frags ) == 8192 ) self.pev.netname = 'reload';
            else if( int( self.pev.frags ) == 16384 ) self.pev.netname = 'alt1';
            else if( int( self.pev.frags ) == 32768 ) self.pev.netname = 'showscores';
            else self.pev.netname = 'use';

            SetThink( ThinkFunction( this.CheckInVolume ) );
            self.pev.nextthink = g_Engine.time + 0.2f;

            BaseClass.Spawn();
        }

        void CheckInVolume()
        {
            if( IsLockedByMaster() )
            {
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null and pPlayer.IsAlive() )
                {
                    if( atof( g_Util.CKV( pPlayer, "$f_player_inbutton" ) ) <= 0.0 )
                    {
                        if( spawnflag( PLAYERS_ANYWHERE ) or self.Intersects( pPlayer ) )
                        {
                            if( !spawnflag( NO_KEY_INPUT_MSG ) )
                            {
                                dictionary g_Lang;
                                g_Lang[ 'english' ] = 'Press';
                                g_Lang[ 'spanish' ] = 'Presiona';

                                g_PlayerFuncs.PrintKeyBindingString( pPlayer, g_Language.GetLanguage( pPlayer, g_Lang ) + ' +' + self.pev.netname + "\n"  );
                            }

                            Verify( pPlayer );
                        }
                    }
                    else
                    {
                        float OldValue = atof( g_Util.CKV( pPlayer, "$f_player_inbutton" ) );
                        g_Util.CKV( pPlayer, "$f_player_inbutton", string( OldValue -0.1 ) );
                    }
                }
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        void Verify( CBasePlayer@ pPlayer )
        {
            if( pPlayer.pev.button & int( int( self.pev.frags ) ) != 0 )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_ON, 0.0f );
                g_Util.CKV( pPlayer, "$f_player_inbutton", string( m_fDelay ) );
            }
        }
    }
}
