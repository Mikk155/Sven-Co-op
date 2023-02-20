#include "utils"
namespace player_inbutton
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_inbutton::player_inbutton", "player_inbutton" );
    }

    enum player_inbutton_flags
    {
        SF_INBUTT_EVERYWHERE = 1 << 0
    }

    class player_inbutton : ScriptBaseEntity, ScriptBaseCustomEntity, ScriptBaseLanguages
    {
		private int IN_KEY = 32;
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            Languages( szKey, szValue );
            return true;
        }

        void Spawn() 
        {
            self.pev.movetype   = MOVETYPE_NONE;
            self.pev.solid      = SOLID_TRIGGER;
            self.pev.effects   |= EF_NODRAW;

            SetBoundaries();

            if( string( self.pev.netname ).IsEmpty() ) self.pev.netname = "32";

            SetThink( ThinkFunction( this.CheckInVolume ) );
            self.pev.nextthink = g_Engine.time + 0.2f;

			self.pev.message = 'Press +' + IN_KEY + ' to see information';
			message_spanish = '';
			message_spanish2 = '';
			message_portuguese = '';
			message_german = '';
			message_french = '';
			message_italian = '';
			message_esperanto = '';
			message_czech = '';
			message_dutch = '';
			message_indonesian = '';
			message_romanian = '';
			message_turkish = '!';
			message_albanian = '';

            BaseClass.Spawn();
        }

        void CheckInVolume()
        {
            if( master() )
			{
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
			}

			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer !is null and pPlayer.IsAlive() )
				{
                    if( atof( g_Util.GetCKV( pPlayer, "$f_player_inbutton" ) ) <= 0.0 )
                    {
						if( self.pev.SpawnFlagBitSet( SF_INBUTT_EVERYWHERE ) or self.Intersects( pPlayer ) )
						{
							g_PlayerFuncs.PrintKeyBindingString( pPlayer, ReadLanguages( pPlayer ) + "\n"  );
							Verify( pPlayer );
						}
                    }
                    else
                    {
						float OldValue = atof( g_Util.GetCKV( pPlayer, "$f_player_inbutton" ) );
                        g_Util.SetCKV( pPlayer, "$f_player_inbutton", string( OldValue -0.1 ) );
                    }
				}
			}
			self.pev.nextthink = g_Engine.time + 0.1f;
		}

		void Verify( CBasePlayer@ pPlayer )
		{
			if( pPlayer.pev.button & IN_KEY != 0 )
			{
				g_Util.Trigger( self.pev.target, pPlayer, self, USE_ON, 0.0f );
				g_Util.SetCKV( pPlayer, "$f_player_inbutton", string( delay ) );
			}
		}
    }
}
// End of namespace