#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_spritehud
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "env_spritehud::env_spritehud", "env_spritehud" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_spritehud' ) +
            g_ScriptInfo.Description( 'Shows a sprite on the player\'s HUD' ) +
            g_ScriptInfo.Wiki( 'env_spritehud' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    enum env_spritehud_affected
    {
        ACTIVATOR_ONLY = 0,
        ALL_PLAYERS = 1
    }

    class env_spritehud : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        HUDSpriteParams params;
        private uint8 color1, color2, effect;
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
            else if( szKey == "color1" )
            {
                color1 = atoui( szValue );
            }
            else if( szKey == "color2" )
            {
                color2 = atoui( szValue );
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
                params.top = atoi( szValue);
            }
            else if( szKey == "left" )
            {
                params.left = atoi( szValue);
            }
            else if( szKey == "width" )
            {
                params.width = atoi( szValue);
            }
            else if( szKey == "height" )
            {
                params.height = atoi( szValue);
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
            array<RGBA> RGBA_COLOR =
            {
                RGBA_WHITE,
                RGBA_BLACK,
                RGBA_GREEN,
                RGBA_BLUE,
                RGBA_YELLOW,
                RGBA_ORANGE,
                RGBA_SVENCOOP
            };

            params.color1 = RGBA_COLOR[color1];
            params.color2 = RGBA_COLOR[color2];
            
            params.effect = effect;
            params.flags = HUD_NUM(self.pev.spawnflags);
            params.spritename = sprite.Replace( 'sprites/', '' );

            if( self.pev.frags == ACTIVATOR_ONLY )
            {
                if( pActivator !is null && pActivator.IsPlayer() && !IsLockedByMaster() )
                {
                    g_PlayerFuncs.HudCustomSprite( cast<CBasePlayer@>(pActivator), params );
                }
            }
            else if( self.pev.frags == ALL_PLAYERS )
            {
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null && !IsLockedByMaster() )
                    {
                        g_PlayerFuncs.HudCustomSprite( pPlayer, params );
                    }
                }
            }
        }
    }
}