#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"
#include "utils/ScriptBaseLanguages"

namespace info_commentary
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "info_commentary::info_commentary", "info_commentary" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'info_commentary' ) +
            g_ScriptInfo.Description( 'Shows a developer-commentary to the client if uses the cvar "commentary" in console.' ) +
            g_ScriptInfo.Wiki( 'info_commentary' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class info_commentary : ScriptBaseEntity, ScriptBaseCustomEntity
    {
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

            dictionary g_Sprite =
            {
                { "spawnflags", '1' },
                { "renderamt", "0" },
                { "rendermode", "5" },
                { "vp_type", g_Util.CKV( self, "$i_vp_type" ) },
                { "framerate", g_Util.CKV( self, "$f_framerate" ) },
                { "scale", string( self.pev.scale ) },
                { "angles", self.pev.angles.ToString() },
                { "model", ( string( self.pev.model ).IsEmpty() ) ? 'sprites/mikk/misc/commentary.spr' : string( self.pev.model ) },
                { "targetname", self.GetTargetname() }
            };
            CBaseEntity@ pSprite = g_EntityFuncs.CreateEntity( "env_sprite", g_Sprite );

            g_EntityFuncs.SetOrigin( self, self.pev.origin );

            if( pSprite !is null )
            {
                g_EntityFuncs.SetOrigin( pSprite, self.pev.origin );

                SetThink( ThinkFunction( this.Think ) );
                self.pev.nextthink = g_Engine.time + 0.1f;
            }

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
                and g_Util.CKV( pPlayer, '$i_commentary' ) == '1'
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

    CClientCommand g_Commentary( "commentary", "0" "Toggle developer-commentary for clients", @CCommentary );
    bool blHook = g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    HookReturnCode ClientSay( SayParameters@ pParams )
    {
        const CCommand@ args = pParams.GetArguments();

        if( args.ArgC() > 0 )
        {
            if( args[0] == ".commentary" || args[0] == "commentary" )
            {
                SetDevState( pParams.GetPlayer(), args );
            }
		}
        return HOOK_CONTINUE;
    }

    void CCommentary( const CCommand@ args )
    {
        SetDevState( g_ConCommandSystem.GetCurrentPlayer(), args );
    }

    void SetDevState( CBasePlayer@ pPlayer, const CCommand@ args )
    {
        if( pPlayer !is null && pPlayer.IsConnected() )
        {
            dictionary g_Lang;

            if( args[1] == "on" || args[1] == "1")
            {
                g_Lang[ 'english' ] = 'Enabled developer commentary mode.';
                g_Lang[ 'spanish' ] = 'Activado el modo de comentarios del desarrollador.';

                g_Util.CKV( pPlayer, '$i_commentary', 1 );
            }
            else if( args[1] == "off" || args[1] == "0")
            {
                g_Lang[ 'english' ] = 'Disabled developer commentary mode.';
                g_Lang[ 'spanish' ] = 'Desactivado el modo de comentarios del desarrollador.';

                g_Util.CKV( pPlayer, '$i_commentary', 0 );
            }
            else
            {
                g_Lang[ 'english' ] = 'Toggled developer commentary mode.';
                g_Lang[ 'spanish' ] = 'Alternado el modo de comentarios del desarrollador.';

                g_Util.CKV( pPlayer, '$i_commentary', ( g_Util.CKV( pPlayer, '$i_commentary' ) == '1' ? '0' : '1' ) );
            }

            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, g_Language.GetLanguage( pPlayer, g_Lang ) + '\n' );

            USE_TYPE UseType = ( g_Util.CKV( pPlayer, '$i_commentary' ) == '1' ? USE_ON : USE_OFF );

            CBaseEntity@ pEntity = null;

            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( g_EntityFuncs.Instance( 0 ), 'env_render_individual' ) ) !is null )
            {
                if( pEntity.GetTargetname().StartsWith( 'commentary_' ) && pEntity.GetTargetname().EndsWith( '_FX' ) )
                {
                    pEntity.Use( pPlayer, null, UseType, 0.0f );
                }
            }
        }
    }
}