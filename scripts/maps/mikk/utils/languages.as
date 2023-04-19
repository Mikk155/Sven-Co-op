mixin class ScriptBaseLanguages
{
    private string_t message_spanish,
    message_portuguese, message_german,
    message_french, message_italian,
    message_esperanto, message_czech,
    message_dutch, message_spanish2,
    message_indonesian, message_romanian,
    message_turkish, message_albanian;

    bool Languages( const string& in szKey, const string& in szValue )
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
        string CurrentLanguage = g_Util.GetCKV( pPlayer, "$s_language" );

        dictionary Languages =
        {
            { "english", self.pev.message },
            { "spanish", message_spanish == '' ?message_spanish2 == '' ? self.pev.message : message_spanish2 : message_spanish },
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