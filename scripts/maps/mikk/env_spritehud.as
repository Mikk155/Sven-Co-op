#include "utils"
namespace env_spritehud
{
	bool Register = g_Util.CustomEntity( 'env_spritehud::env_spritehud','env_spritehud' );

    class env_spritehud : ScriptBaseEntity
    {
        HUDSpriteParams params;
        private int color1, color2, effect;
        private string sprite = "logo.spr";

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
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
                color1 = atoi( szValue );
            }
            else if( szKey == "color2" )
            {
                color2 = atoi( szValue );
            }
            else if( szKey == "effect" )
            {
                effect = atoi( szValue );
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
        
        void Spawn()
        {
            if( color1 == 1 ) { params.color1 = RGBA_BLACK; }
            else if( color1 == 2 ) { params.color1 = RGBA_RED; }
            else if( color1 == 3 ) { params.color1 = RGBA_GREEN; }
            else if( color1 == 4 ) { params.color1 = RGBA_BLUE; }
            else if( color1 == 5 ) { params.color1 = RGBA_YELLOW; }
            else if( color1 == 6 ) { params.color1 = RGBA_ORANGE; }
            else if( color1 == 7 ) { params.color1 = RGBA_SVENCOOP; }
            else { params.color1 = RGBA_WHITE; }
            
            if( color2 == 1 ) { params.color2 = RGBA_BLACK; }
            else if( color2 == 2 ) { params.color2 = RGBA_RED; }
            else if( color2 == 3 ) { params.color2 = RGBA_GREEN; }
            else if( color2 == 4 ) { params.color2 = RGBA_BLUE; }
            else if( color2 == 5 ) { params.color2 = RGBA_YELLOW; }
            else if( color2 == 6 ) { params.color2 = RGBA_ORANGE; }
            else if( color2 == 7 ) { params.color2 = RGBA_SVENCOOP; }
            else { params.color2 = RGBA_WHITE; }

            params.effect = int( effect );

            params.flags = HUD_NUM(self.pev.spawnflags);

            params.spritename = sprite.Replace( 'sprites/', '' );
            BaseClass.Spawn();
        }
        
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( self.pev.frags == 0 )
            {
                if( pActivator is null && !pActivator.IsPlayer() )
                    return;

                g_PlayerFuncs.HudCustomSprite( cast<CBasePlayer@>(pActivator), params );
            }
            else if( self.pev.frags == 1 )
            {
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer is null )
                        continue;

                    g_PlayerFuncs.HudCustomSprite( pPlayer, params );
                }
            }
        }
    }
}
// End of namespace