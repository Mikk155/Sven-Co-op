#include "utils"
namespace info_commentary
{
    class info_commentary : ScriptBaseEntity
    {
        void Precache()
        {
			g_Game.PrecacheModel( ( string( self.pev.model ).IsEmpty() ) ? 'models/error.mdl' : string( self.pev.model ) );
            BaseClass.Precache();
        }

        void Spawn()
        {
			if( self.GetTargetname().IsEmpty() )
			{
				self.pev.targetname = 'commentary_' + self.entindex();
			}

			dictionary g_keyvalues =
			{
				{ "spawnflags", "64" },
				{ "target", self.GetTargetname() },
				{ "renderamt", string( self.pev.renderamt ) },
				{ "rendermode", string( self.pev.rendermode ) },
				{ "rendercolor", self.pev.rendercolor.ToString() },
				{ "targetname", 'commentary_' + self.entindex() + '_FX' }
			};
			g_EntityFuncs.CreateEntity( "env_render_individual", g_keyvalues );
            g_EntityFuncs.SetModel( self, ( string( self.pev.model ).IsEmpty() ) ? 'models/error.mdl' : string( self.pev.model ) );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
			self.pev.renderamt = 0;
			self.pev.rendermode = 5;
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Think()
        {
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				int iRadius = ( self.pev.health > 0 ) ? int( self.pev.health ) : 200;

				if( pPlayer !is null
				and pPlayer.IsConnected()
				and g_Util.GetCKV( pPlayer, '$i_commentary' ) == '1'
				and ( self.pev.origin - pPlayer.pev.origin ).Length() <= iRadius )
				{
					g_PlayerFuncs.PrintKeyBindingString( pPlayer, 'Press +use to see commentary\n'  );

					if( pPlayer.pev.button & IN_USE != 0 )
					{
						g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
					}
				}
			}
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }

	CClientCommand g_Commentary( "commentary", "Toggle developer-commentary for clients", @CCommentary );

	void CCommentary( const CCommand@ args )
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

		if( pPlayer !is null && pPlayer.IsConnected() )
		{
			// Checkear valor de cmd on/off
			g_Util.SetCKV( pPlayer, '$i_commentary', ( g_Util.GetCKV( pPlayer, '$i_commentary' ) == '1' ? '0' : '1' ) );

			USE_TYPE UseType = ( g_Util.GetCKV( pPlayer, '$i_commentary' ) == '1' ? USE_ON : USE_OFF );

			CBaseEntity@ pEntity = null;

			while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'env_render_individual' ) ) !is null )
			{
				string Name = pEntity.GetTargetname();
				if( Name.StartsWith( 'commentary_' ) && Name.EndsWith( '_FX' ) )
				{
					pEntity.Use( pPlayer, null, UseType, 0.0f );
				}
			}
		}
	}
	bool Register = g_Util.CustomEntity( 'info_commentary::info_commentary','info_commentary' );
}