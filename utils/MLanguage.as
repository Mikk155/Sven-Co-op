MLanguages m_Language;

final class MLanguages
{
    string GetLanguage( CBasePlayer@ pPlayer, dictionary@ g_Languages )
    {
        string CurrentLanguage;

        if( m_CustomKeyValue.HasKey( pPlayer, '$s_language' ) )
        {
            m_CustomKeyValue.GetValue( pPlayer, '$s_language', CurrentLanguage );
        }

        if( CurrentLanguage == "" || CurrentLanguage.IsEmpty() || string( g_Languages[ CurrentLanguage ] ).IsEmpty() )
        {
            return string( g_Languages[ 'english' ] );
        }

        return string( g_Languages[ CurrentLanguage ] );
    }

    void ScheduledPrint( CBasePlayer@ pPlayer, dictionary g_Message, int MSG_ENUM = 0, dictionary@ rArgs = null )
    {
        PrintMessage( pPlayer, g_Message, MSG_ENUM, false, rArgs );
    }

    void PrintMessage( CBasePlayer@ pCaller, dictionary g_Message, int MSG_ENUM = 0, bool bAllPlayers = false, dictionary@ rArgs = null )
    {
        if( bAllPlayers )
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null && pPlayer !is pCaller )
                {
                    ScheduledPrint( pPlayer, g_Message, MSG_ENUM, rArgs );
                }
            }
            return;
        }

        if( pCaller is null )
        {
            return;
        }

        string iszMessageString = m_Language.GetLanguage( pCaller, g_Message );

        if( rArgs !is null )
        {
            const array<string> Args = rArgs.getKeys();

            for( uint i = 0; i < Args.length(); i++ )
            {
                iszMessageString.Replace( Args[i], string( rArgs[ Args[i] ] ) );
            }
        }

        if( MSG_ENUM == ML_BIND )
        {
            g_PlayerFuncs.PrintKeyBindingString( pCaller, iszMessageString + '\n' );
        }
        else if( MSG_ENUM == ML_CHAT )
        {
            string m_iszMessage = iszMessageString;

            // HACK for max limit chars
            while( m_iszMessage != '' )
            {
                g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTTALK, m_iszMessage.SubString( 0, 95 ) + ( m_iszMessage.Length() <= 95 ? '\n' : '-' ) );

                if( m_iszMessage.Length() <= 95 ) m_iszMessage = '';
                else m_iszMessage =  '-' + m_iszMessage.SubString( 95, m_iszMessage.Length() );
            }
        }
        else if( MSG_ENUM == ML_HUD )
        {
            g_PlayerFuncs.HudMessage( pCaller, textParams( g_Message ), iszMessageString + "\n" );
        }
        else if( MSG_ENUM == ML_CONSOLE )
        {/*
            string m_iszMessage = iszMessageString;

            // HACK for max limit chars
            while( m_iszMessage != '' )
            {*/
                g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, iszMessageString + /*m_iszMessage.SubString( 0, 68 ) + ( m_iszMessage.Length() <= 68 ? */'\n' /*: '-' ) */);
/*
                if( m_iszMessage.Length() <= 68 ) m_iszMessage = '';
                else m_iszMessage = '-' + m_iszMessage.SubString( 68, m_iszMessage.Length() );
            }*/
        }
    }
}

enum MSG_ENUM
{
    ML_BIND = 1,
    ML_CHAT = 2,
    ML_HUD = 3,
    ML_CONSOLE = 4
}

HUDTextParams textParams( dictionary g_Params )
{
    HUDTextParams pParams;

    pParams.channel = ( g_Params.exists( 'channel' ) ? atoi( string( g_Params['channel'] ) ) : 3 );
    pParams.x = ( g_Params.exists( 'x' ) ? atof( string( g_Params['x'] ) ) : -1.0f );
    pParams.y = ( g_Params.exists( 'y' ) ? atof( string( g_Params['y'] ) ) : 0.70f );
    if( g_Params.exists( 'color' ) )
    {
        RGBA Color = atorgba( string( g_Params['color'] ) );
        pParams.r1 = Color.r;
        pParams.g1 = Color.g;
        pParams.b1 = Color.b;
        pParams.a1 = Color.a;
    }
    if( g_Params.exists( 'color2' ) )
    {
        RGBA Color = atorgba( string( g_Params['color2'] ) );
        pParams.r2 = Color.r;
        pParams.g2 = Color.g;
        pParams.b2 = Color.b;
        pParams.a2 = Color.a;
    }
    pParams.fadeinTime = ( g_Params.exists( 'in' ) ? atof( string( g_Params['in'] ) ) : 0.0f );
    pParams.fadeoutTime = ( g_Params.exists( 'out' ) ? atof( string( g_Params['out'] ) ) : 0.5f );
    pParams.holdTime = ( g_Params.exists( 'hold' ) ? atof( string( g_Params['hold'] ) ) : 0.5f );

    return pParams;
}

namespace LANGUAGE
{
    void MapInit()
    {/*
        GTC kmkz
        MLanguages mikk
        plugin gafther*/
    }

    mixin class ScriptBaseLanguages
    {
        private string_t message_spanish,
        message_portuguese, message_german,
        message_french, message_italian,
        message_esperanto, message_czech,
        message_dutch, message_spanish2,
        message_indonesian, message_romanian,
        message_turkish, message_albanian;

        bool LangKeyValues( const string& in szKey, const string& in szValue )
        {
            if( szKey == "message_spanish" )
            {
                message_spanish = szValue;
            }
            else if( szKey == "message_spanish2" )
            {
                message_spanish2 = szValue;
            }
            else if( szKey == "message_portuguese" )
            {
                message_portuguese = szValue;
            }
            else if( szKey == "message_german" )
            {
                message_german = szValue;
            }
            else if( szKey == "message_french" )
            {
                message_french = szValue;
            }
            else if( szKey == "message_italian" )
            {
                message_italian = szValue;
            }
            else if( szKey == "message_esperanto" )
            {
                message_esperanto = szValue;
            }
            else if( szKey == "message_czech" )
            {
                message_czech = szValue;
            }
            else if( szKey == "message_dutch" )
            {
                message_dutch = szValue;
            }
            else if( szKey == "message_indonesian" )
            {
                message_indonesian = szValue;
            }
            else if( szKey == "message_romanian" )
            {
                message_romanian = szValue;
            }
            else if( szKey == "message_turkish" )
            {
                message_turkish = szValue;
            }
            else if( szKey == "message_albanian" )
            {
                message_albanian = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }

            return true;
        }

        string_t ReadLanguages( CBasePlayer@ pPlayer )
        {
            string CurrentLanguage/* = g_Util.CKV( pPlayer, "$s_language" )*/;

            dictionary Languages =
            {
                { "english", self.pev.message },
                { "spanish", message_spanish == '' ? message_spanish2 == '' ? self.pev.message : message_spanish2 : message_spanish },
                { "spanish spain", message_spanish2 == '' ? message_spanish == '' ? self.pev.message : message_spanish : message_spanish2 },
                { "portuguese", message_portuguese == '' ? self.pev.message : message_portuguese },
                { "german", message_german == '' ? self.pev.message : message_german },
                { "french", message_french == '' ? self.pev.message : message_french },
                { "italian", message_italian == '' ? self.pev.message : message_italian },
                { "esperanto", message_esperanto == '' ? self.pev.message : message_esperanto },
                { "czech", message_czech == '' ? self.pev.message : message_czech },
                { "dutch", message_dutch == '' ? self.pev.message : message_dutch },
                { "indonesian", message_indonesian == '' ? self.pev.message : message_indonesian },
                { "romanian", message_romanian == '' ? self.pev.message : message_romanian },
                { "turkish", message_turkish == '' ? self.pev.message : message_turkish },
                { "albanian", message_albanian == '' ? self.pev.message : message_albanian }
            };
            
            if( CurrentLanguage == "" || CurrentLanguage.IsEmpty() )
            {
                return string_t( self.pev.message );
            }

            return string_t( Languages[ CurrentLanguage ] );
        }
    }
}