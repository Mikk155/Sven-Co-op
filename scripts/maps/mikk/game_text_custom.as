#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"
#include "utils/ScriptBaseLanguages"

namespace game_text_custom
{
    CCVar g_Titles ( "gtc_titles", "mikk/config/titles.txt", "custom titles.txt file", ConCommandFlag::AdminOnly );

    void Register()
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::game_text_custom", "game_text_custom" );

            g_ScriptInfo.SetInformation
            ( 
                g_ScriptInfo.ScriptName( 'game_text_custom' ) +
                g_ScriptInfo.Description( 'Expands game_text and adds languages support' ) +
                g_ScriptInfo.Wiki( 'game_text_custom' ) +
                g_ScriptInfo.Author( 'Mikk' ) +
                g_ScriptInfo.GetGithub() +
                g_ScriptInfo.Author( 'Gaftherman' ) +
                g_ScriptInfo.GetGithub( 'Gaftherman' ) +
                g_ScriptInfo.Author( 'Kmkz' ) +
                g_ScriptInfo.GetGithub( 'kmkz27' ) +
                g_ScriptInfo.GetDiscord()
            );
        }
    }
    
    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom::game_text_custom", "multi_language" );
    }

    enum game_text_custom_spawnflags
    {
        ALL_PLAYERS = 1,
        NO_CONSOLE_ECHO = 2,
        FIRE_PER_PLAYER = 4,
    }

    enum game_text_custom_effect
    {
        FADE_INOUT = 0,
        CREDITS = 1,
        SCAN_OUT = 2,
        PRINT_HUD = 3,
        PRINT_MOTD = 4,
        PRINT_CHAT = 5,
        PRINT_NOTIFY = 6,
        PRINT_KEYBIND = 7,
        PRINT_CONSOLE = 8,
        PRINT_CENTER = 9,
        PRINT_SCOREBOARD = 10
    }
    
    class game_text_custom : ScriptBaseEntity, ScriptBaseCustomEntity, ScriptBaseLanguages
    {
        EHandle hactivator = self;
        HUDTextParams TextParams;
        private string killtarget;
        private Vector color, color2;

        bool GTC_KEYVALUES( const string& in szKey, const string& in szValue )
        {
            Languages( szKey, szValue );
            ExtraKeyValues( szKey, szValue );
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
                TextParams.r1 = RGBVector( szValue ).r;
                TextParams.g1 = RGBVector( szValue ).g;
                TextParams.b1 = RGBVector( szValue ).b;
            }
            else if(szKey == "color2")
            {
                TextParams.r2 = RGBVector( szValue ).r;
                TextParams.g2 = RGBVector( szValue ).g;
                TextParams.b2 = RGBVector( szValue ).b;
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
            return true;
        }

        void Spawn()
        {
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( pActivator !is null )
            {
                hactivator = pActivator;
            }
            else
            {
                hactivator = self;
            }

            if( IsLockedByMaster() )
            {
                return;
            }

            if( spawnflag( ALL_PLAYERS ) )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        ShowText( pPlayer, useType );
                    }
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                ShowText( cast<CBasePlayer@>(pActivator), useType );
            }

            g_Util.Trigger( killtarget, hactivator.GetEntity(), pCaller, USE_KILL, m_fDelay );

            if( !spawnflag( FIRE_PER_PLAYER ) )
            {
                g_Util.Trigger( self.pev.target, hactivator.GetEntity(), self, GetUseType( useType ), m_fDelay );
            }
        }

        void ShowText( CBasePlayer@ pPlayer, USE_TYPE & in useType = USE_TOGGLE )
        {
            string ReadLanguage = g_Util.StringReplace( ReadLanguages( pPlayer ),
            {
                { "!integer", g_Util.GetCKV( self, '$i_integer' ) },
                { "!float", g_Util.GetCKV( self, '$f_float' ) },
                { "!string", g_Util.GetCKV( self, '$s_string' ) },
                { "!vector", g_Util.GetCKV( self, '$v_vector' ) },
                { "!activator", GetActivatorName() }
            } );

            if( TextParams.effect == PRINT_HUD )
            {
                g_PlayerFuncs.ShowMessage( pPlayer, ReadLanguage + "\n" );
            }
            else if( TextParams.effect == PRINT_MOTD )
            {
                array<string> MotdSubMsg = ReadLanguage.Split(" # ");
                // string motd_title = ReadLanguage;
                // motd_title.SubString( 0, motd_title.Find( '#' ) );
                // motd_title.Replace( '#', '' );
                // string motd_message = ReadLanguage;
                // motd_message.SubString( motd_message.Find( '#' ) + 1, motd_message.Length() )
                // motd_message.SubString( ( motd_message[0] == ' ' ? 1 : 0 ), motd_message.Length() )
                g_Util.ShowMOTD( pPlayer, MotdSubMsg[0], MotdSubMsg[1] + "\n" );
            }
            else if( TextParams.effect == PRINT_CHAT )
            {
                string FullString = ReadLanguage;

                // If we reached the limit replace and send again
                while( FullString != '' )
                {
                    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, FullString.SubString( 0, 95 ) + ( FullString.Length() <= 95 ? '\n' : '-' ) );

                    if( FullString.Length() <= 95 )
                    {
                        FullString = '';
                    }
                    else
                    {
                        FullString = FullString.SubString( 95, FullString.Length() );
                    }
                }
            }
            else if( TextParams.effect == PRINT_NOTIFY )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, ReadLanguage + "\n" );
            }
            else if( TextParams.effect == PRINT_KEYBIND )
            {
                g_PlayerFuncs.PrintKeyBindingString( pPlayer, ReadLanguage + "\n"  );
            }
            else if( TextParams.effect == PRINT_CONSOLE )
            {
                string FullString = ReadLanguage + '\n';

                // If we reached the limit replace and send again
                while( FullString != '' )
                {
                    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  FullString.SubString( 0, 68 ) );

                    if( FullString.Length() <= 68 )
                    {
                        FullString = '';
                    }
                    else
                    {
                        FullString = FullString.SubString( 68, FullString.Length() );
                    }
                }
            }
            else if( TextParams.effect == PRINT_CENTER )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, ReadLanguage + "\n" );
            }
            else if( TextParams.effect == PRINT_SCOREBOARD )
            {
                NetworkMessage message( MSG_ONE, NetworkMessages::ServerName, pPlayer.edict() );
                    message.WriteString( ReadLanguage );
                message.End();
            }
            else
            {
                g_PlayerFuncs.HudMessage( pPlayer, TextParams, ReadLanguage + "\n" );
            }

            if( !spawnflag( NO_CONSOLE_ECHO ) && TextParams.effect != PRINT_CONSOLE )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, ReadLanguage + "\n" );
            }

            if( spawnflag( FIRE_PER_PLAYER ) )
            {
                g_Util.Trigger( self.pev.target, pPlayer, self, GetUseType( useType ), m_fDelay );
            }
        }

        string GetActivatorName()
        {
            if( hactivator.GetEntity() is null )
            {
                return "world";
            }
            else if( hactivator.GetEntity().IsPlayer() )
            {
                return string( hactivator.GetEntity().pev.netname );
            }
            else if( hactivator.GetEntity().IsMonster() )
            {
                return string( hactivator.GetEntity().pev.classname ).Replace( '_', ' ');
            }
            return string( hactivator.GetEntity().pev.classname );
        }

        RGBA RGBVector( string szValue )
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
            return RGBA(result[0],result[1],result[2]);
        }

        void PostSpawn()
        {
            if( self.pev.ClassNameIs( 'game_text_custom' ) )
            {
                self.pev.message = GetTitle( self.pev.message );
                message_spanish = GetTitle( message_spanish );
                message_spanish2 = GetTitle( message_spanish2 );
                message_portuguese = GetTitle( message_portuguese );
                message_german = GetTitle( message_german );
                message_french = GetTitle( message_french );
                message_italian = GetTitle( message_italian );
                message_esperanto = GetTitle( message_esperanto );
                message_czech = GetTitle( message_czech );
                message_dutch = GetTitle( message_dutch );
                message_indonesian = GetTitle( message_indonesian );
                message_romanian = GetTitle( message_romanian );
                message_turkish = GetTitle( message_turkish );
                message_albanian = GetTitle( message_albanian );
            }
            else if( self.pev.ClassNameIs( 'multi_language' ) )
            {
                if( string( self.pev.model ).StartsWith( "*" ) )
                {
                    CBaseEntity@ Triggers = g_EntityFuncs.FindEntityByString( Triggers, "model", string( self.pev.model ) );

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
            BaseClass.PostSpawn();
        }

        string GetTitle( string_t iszLabel_t )
        {
            string iszLabel = string( iszLabel_t );

            if( !iszLabel.StartsWith( '!' ) || iszLabel.IsEmpty() )
                return iszLabel;

            iszLabel.Replace( '!', '' );
            string strFile = 'scripts/maps/' + g_Titles.GetString();

            File@ pFile = g_FileSystem.OpenFile( strFile, OpenFile::READ );

            if( pFile is null or !pFile.IsOpen() )
            {
                g_Util.Debug( "Failed to open '" + strFile + "' no custom titles loaded." );
                return iszLabel;
            }
            g_Util.Debug( '\n\n\n\n\n\n "'+iszLabel+'" \n\n\n\n\n' );

            string line;
            string latestx;
            string latesty;
            string latesteffect;
            string latestcolor;
            string latestcolor2;
            string latestfadein;
            string latestfadeout;
            string latestfxtime;
            string latestholdtime;
            string latestspawnflags;
            string latestmessage;

            bool capsule = false;
            bool ReadingTitle = false;
            bool read = false;
            bool finishread = false;

            while( !pFile.EOFReached() )
            {
                pFile.ReadLine( line );
                    
                if( line.Find("//") != String::INVALID_INDEX || line.Find("#") != String::INVALID_INDEX ) 
                    continue;

                if( iszLabel == line )
                {
                    ReadingTitle = true;
                }

                if( line.Find("$position") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestx = SubLines[1];
                    latesty = SubLines[2];
                }
                else if( line.Find("$effect") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latesteffect = SubLines[1];
                }
                else if( line.Find("$spawnflags") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestspawnflags = SubLines[1];
                }
                else if( line.Find("$color") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestcolor = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
                }
                else if( line.Find("$color2") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestcolor2 = SubLines[1] + " " + SubLines[2] + " " + SubLines[3];
                }
                else if( line.Find("$fadein") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestfadein = SubLines[1];
                }
                else if( line.Find("$fadeout") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestfadeout = SubLines[1];
                }
                else if( line.Find("$fxtime") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestfxtime = SubLines[1];
                }
                else if( line.Find("$holdtime") != String::INVALID_INDEX )
                {
                    array<string> SubLines = line.Split(" ");
                    latestholdtime = SubLines[1];
                }
                else if( line.Find("{") != String::INVALID_INDEX )
                {
                    capsule = true;
                }
                else if( line.Find("}") != String::INVALID_INDEX )
                {
                    capsule = false;
                    finishread = true;
                }
                else if( capsule && !read )
                {
                    read = true;
                }

                if( read )
                {
                    if( !finishread  )
                    {
                        if( latestmessage.IsEmpty() )
                        {
                            latestmessage = line;
                        }
                        else if( line.IsEmpty() )
                        {
                            latestmessage = latestmessage  + "\\n";
                        } 
                        else
                        {
                            latestmessage = latestmessage + "\\n" + line;
                        }
                    } 
                }
                else
                {
                    latestmessage = "";
                }

                if( finishread )
                {
                    if( !latestx.IsEmpty() ) { TextParams.x = atof( latestx ); }
                    if( !latesty.IsEmpty() ) { TextParams.y = atof( latesty ); }
                    if( !latesteffect.IsEmpty() ) { TextParams.effect = atoi( latesteffect ); }
                    if( !latestfadein.IsEmpty() ) { TextParams.fadeinTime = atof( latestfadein ); }
                    if( !latestfadeout.IsEmpty() ) { TextParams.fadeoutTime = atof( latestfadeout ); }
                    if( !latestholdtime.IsEmpty() ) { TextParams.holdTime = atof( latestholdtime ); }
                    if( !latestfxtime.IsEmpty() ) { TextParams.fxTime = atof( latestfxtime ); }
                    if( self.pev.spawnflags == 0 ) { self.pev.spawnflags = atoi( latestspawnflags ); }
                    if( !latestcolor.IsEmpty() )
                    {
                        TextParams.r1 = RGBVector( latestcolor ).r;
                        TextParams.g1 = RGBVector( latestcolor ).g;
                        TextParams.b1 = RGBVector( latestcolor ).b;
                    }
                    if( !latestcolor2.IsEmpty() )
                    {
                        TextParams.r2 = RGBVector( latestcolor2 ).r;
                        TextParams.g2 = RGBVector( latestcolor2 ).g;
                        TextParams.b2 = RGBVector( latestcolor2 ).b;
                    }

                    if( ReadingTitle )
                    {
                        pFile.Close();
                        return latestmessage;
                    }
                    finishread = false;
                    read = false;
                }
            }
            pFile.Close();
            return iszLabel;
        }
    }
}