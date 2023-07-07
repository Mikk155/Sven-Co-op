#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_spritehud
{
    void Register()
    {
        g_Util.CustomEntity( 'env_spritehud' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_spritehud' ) +
            g_ScriptInfo.Description( 'Shows a sprite on the player\'s HUD' ) +
            g_ScriptInfo.Wiki( 'env_spritehud' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum HUD_FLAGS
    {
        SPRITEHUD_ELEM = 1,
        SPRITEHUD_ELEM_ABSOLUTE_Y = 2,
        SPRITEHUD_ELEM_SCR_CENTER_X = 4,
        SPRITEHUD_ELEM_SCR_CENTER_Y = 8,
        SPRITEHUD_ELEM_NO_BORDER = 16,
        SPRITEHUD_ELEM_HIDDEN = 32,
        SPRITEHUD_ELEM_EFFECT_ONCE = 64,
        SPRITEHUD_ELEM_DEFAULT_ALPHA = 128,
        SPRITEHUD_ELEM_DYNAMIC_ALPHA = 256,
        SPRITEHUD_SPR_OPAQUE = 65536,
        SPRITEHUD_SPR_MASKED = 131072,
        SPRITEHUD_SPR_PLAY_ONCE = 262144,
        SPRITEHUD_SPR_HIDE_WHEN_STOPPED = 524288
    }

    class env_spritehud : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        HUDSpriteParams params;
        private uint8 effect;
        private string sprite = "logo.spr";

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "sprite" )
            {
                sprite = szValue;
            }
            else if( szKey == "channel" )
            {
                params.channel = atoi( szValue);
            }
            else if( szKey == "effect" )
            {
                effect = atoui( szValue );
            }
            else if( szKey == "frame" )
            {
                params.frame = atoi( szValue);
            }
            else if( szKey == "numframes" )
            {
                params.numframes = atoi( szValue);
            }
            else if( szKey == "framerate" )
            {
                params.framerate = atoi( szValue);
            }
            else if( szKey == "x" )
            {
                params.x = atof( szValue);
            }
            else if( szKey == "y" )
            {
                params.y = atof( szValue);
            }
            else if( szKey == "top" )
            {
                params.top = uint8( atoui( szValue) );
            }
            else if( szKey == "left" )
            {
                params.left = uint8( atoui( szValue) );
            }
            else if( szKey == "width" )
            {
                params.width = uint8( atoui( szValue) );
            }
            else if( szKey == "height" )
            {
                params.height = uint8( atoui( szValue) );
            }
            else if( szKey == "fadeinTime" )
            {
                params.fadeinTime = atof( szValue);
            }
            else if( szKey == "fadeoutTime" )
            {
                params.fadeoutTime = atof( szValue);
            }
            else if( szKey == "holdTime" )
            {
                params.holdTime = atof( szValue);
            }
            else if( szKey == "fxtime" )
            {
                params.fxTime = atof( szValue);
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }
        
        void Precache()
        {
            g_Game.PrecacheModel(  sprite );
            g_Game.PrecacheGeneric( sprite );
            BaseClass.Precache();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
            {
                return;
            }
            
            params.color1 = g_Util.atoc( self.pev.rendercolor.ToString() + ' ' + string( self.pev.renderamt ) );
            params.color2 = g_Util.atoc( self.pev.vuser1.ToString() + ' ' + string( uint8( self.pev.iuser1 ) ) );
            params.effect = effect;
            params.flags = HUD_FLAGS( self.pev.spawnflags );

            params.spritename = sprite.Replace( 'sprites/', '' );

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( g_Util.WhoAffected( pPlayer, m_iAffectedPlayer, pActivator ) )
                {
                    g_PlayerFuncs.HudCustomSprite( pPlayer, params );
                }
            }
        }
    }
}
