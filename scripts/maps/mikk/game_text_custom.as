#include "utils"
namespace game_text_custom
{
    class game_text_custom : ScriptBaseEntity,
    game_text_custom::ScriptBaseGameText,
    ScriptBaseLanguages, ScriptBaseCustomEntity
    {
        private bool IsSector = false;
        EHandle EhActivator = self;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            Languages( szKey, szValue );
            ExtraKeyValues( szKey, szValue );
            GameTextKeyvalues( szKey, szValue );
            return true;
        }

        void Spawn()
        {
            PluginEntInit( self );
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
                return;

            if( pActivator !is null ) EhActivator = pActivator; else EhActivator = null;

            if( spawnflag( 1 ) )
            {
				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        ShowText( pPlayer );
                    }
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                ShowText( cast<CBasePlayer@>(pActivator) );
            }

            g_Util.Trigger( killtarget, self, pCaller, USE_KILL, delay );

            if( !spawnflag( 4 ) )
            {
                g_Util.Trigger( self.pev.target, ( pActivator is null ) ? self : pActivator, self, useType, delay );
            }
        }

        void ShowText( CBasePlayer@ pPlayer )
        {
            string ReadLanguage = g_Util.StringReplace( ReadLanguages( pPlayer ),
            {
                { "!integer", g_Util.GetCKV( self, '$i_integer' ) },
                { "!float", g_Util.GetCKV( self, '$f_float' ) },
                { "!string", g_Util.GetCKV( self, '$s_string' ) },
                { "!vector", g_Util.GetCKV( self, '$v_vector' ) },
                { "!activator", StrActivator() }
            } );

            if( TextParams.effect == 3 )
            {
                g_PlayerFuncs.ShowMessage( pPlayer, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 4 )
            {
                string title = string( ReadLanguage ).SubString( 0., string( ReadLanguage ).Find( '#' ) );

                g_Util.ShowMOTD( pPlayer, title.Replace( '#', '' ), string( ReadLanguage ).SubString( string( ReadLanguage ).Find( '#' ) + 1, string( ReadLanguage ).Length() ) + "\n" );
            }
            else if( TextParams.effect == 5 )
            {
                string FullString = string( ReadLanguage );

                // If we reached the limit replace and send again
                while( FullString != '' )
                {
                    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, FullString.SubString( 0, 95 ) + ( FullString.Length() <= 95 ? '\n' : '-' ) );

                    if( FullString.Length() <= 95 ) FullString = '';
                    else FullString = FullString.SubString( 95, FullString.Length() );
                }
            }
            else if( TextParams.effect == 6 )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 7 )
            {
                g_PlayerFuncs.PrintKeyBindingString( pPlayer, string( ReadLanguage ) + "\n"  );
            }
            else if( TextParams.effect == 8 )
            {
                string FullString = string( ReadLanguage ) + '\n';

                // If we reached the limit replace and send again
                while( FullString != '' )
                {
                    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  FullString.SubString( 0, 68 ) );

                    if( FullString.Length() <= 68 ) FullString = '';
                    else FullString = FullString.SubString( 68, FullString.Length() );
                }
            }
            else if( TextParams.effect == 9 )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, string( ReadLanguage ) + "\n" );
            }
            else if( TextParams.effect == 10 )
            {
                NetworkMessage message( MSG_ONE, NetworkMessages::ServerName, pPlayer.edict() );
                    message.WriteString( string( ReadLanguage ) );
                message.End();
            }
            else
            {
                g_PlayerFuncs.HudMessage( pPlayer, TextParams, string( ReadLanguage ) + "\n" );
            }

            if( !spawnflag( 2 ) )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string( ReadLanguage ) + "\n" );
            }

            if( spawnflag( 4 ) )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
            }
        }

        string StrActivator()
        {
            if( EhActivator.GetEntity() is null )
            {
                return "world";
            }
            else if( EhActivator.GetEntity().IsPlayer() )
            {
                return string( EhActivator.GetEntity().pev.netname );
            }
            else if( EhActivator.GetEntity().IsMonster() )
            {
                return string( EhActivator.GetEntity().pev.classname ).Replace( '_', ' ');
            }
            return string( EhActivator.GetEntity().pev.classname );
        }

    }

    // game_text legacy
    mixin class ScriptBaseGameText
    {
        private string killtarget;
        HUDTextParams TextParams;
        
        private Vector color, color2;

        bool GameTextKeyvalues( const string& in szKey, const string& in szValue )
        {
            if(szKey == "channel")
            {
                TextParams.channel = atoi( szValue );
            }
            else if(szKey == "x")
            {
                TextParams.x = atof( szValue );
            }
            else if(szKey == "y")
            {
                TextParams.y = atof( szValue );
            }
            else if(szKey == "effect")
            {
                TextParams.effect = atoi( szValue );
            }
            else if(szKey == "color")
            {
                string delimiter = " ";
                array<string> splitColor = {"","",""};
                splitColor = szValue.Split(delimiter);
                array<uint8>result = {0,0,0};
                result[0] = atoi(splitColor[0]);
                result[1] = atoi(splitColor[1]);
                result[2] = atoi(splitColor[2]);
                if (result[0] > 255) result[0] = 255;
                if (result[1] > 255) result[1] = 255;
                if (result[2] > 255) result[2] = 255;
                RGBA vcolor = RGBA(result[0],result[1],result[2]);
                TextParams.r1 = vcolor.r;
                TextParams.g1 = vcolor.g;
                TextParams.b1 = vcolor.b;
            }
            else if(szKey == "color2")
            {
                string delimiter2 = " ";
                array<string> splitColor2 = {"","",""};
                splitColor2 = szValue.Split(delimiter2);
                array<uint8>result2 = {0,0,0};
                result2[0] = atoi(splitColor2[0]);
                result2[1] = atoi(splitColor2[1]);
                result2[2] = atoi(splitColor2[2]);
                if (result2[0] > 255) result2[0] = 255;
                if (result2[1] > 255) result2[1] = 255;
                if (result2[2] > 255) result2[2] = 255;
                RGBA vcolor2 = RGBA(result2[0],result2[1],result2[2]);
                TextParams.r2 = vcolor2.r;
                TextParams.g2 = vcolor2.g;
                TextParams.b2 = vcolor2.b;
            }
            else if(szKey == "fadein")
            {
                TextParams.fadeinTime = atof( szValue );
            }
            else if(szKey == "fadeout")
            {
                TextParams.fadeoutTime = atof( szValue );
            }
            else if(szKey == "holdtime")
            {
                TextParams.holdTime = atof( szValue );
            }
            else if(szKey == "fxtime")
            {
                TextParams.fxTime = atof( szValue );
            }
            else if( szKey == "killtarget" )
            {
                killtarget = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }
    }
    
    // Plugin feature.
    void PluginEntInit( CBaseEntity@ self )
    {
        if( self.pev.ClassNameIs( 'multi_language' ) )
        {
            if( string( self.pev.model ).StartsWith( "*" ) )
            {
                CBaseEntity@ Triggers = g_EntityFuncs.FindEntityByString( Triggers, "model", self.pev.model );

                if( Triggers !is null )
                {
                    if( Triggers.pev.ClassNameIs( "trigger_multiple" ) || Triggers.pev.ClassNameIs( "trigger_once" ) )
                    {
                        if( string( Triggers.pev.target ).IsEmpty() )
                        {
                            Triggers.pev.target = 'mlang_' + self.entindex();
                            self.pev.targetname = 'mlang_' + self.entindex();
                        }
                        else
                        {
                            self.pev.targetname = Triggers.pev.target;
                        }
                        Triggers.pev.message = String::INVALID_INDEX;
                    }
                }
            }
            else
            {
                CBaseEntity@ pGameText = null;

                while( ( @pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, self.pev.targetname ) ) !is null )
                {
                    if(pGameText.pev.ClassNameIs( "env_message" )
                    or pGameText.pev.ClassNameIs( "game_text" )
                    or pGameText.pev.ClassNameIs( "game_text_custom" ) )
                    {
                        g_EntityFuncs.Remove( pGameText );
                    }
                }
            }
        }
    }

	void MapInit()
	{
		g_Util.CustomEntity( 'game_text_custom::game_text_custom','multi_language' );
	}

	bool Register = g_Util.CustomEntity( 'game_text_custom::game_text_custom','game_text_custom' );
}