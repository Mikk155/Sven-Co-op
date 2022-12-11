/*
    Script that contains shared coded that almost ( to not say 'all') of our scripts uses.
*/

// Enable if you're testing. so the entities/scripts shows debug messages.
bool ShowDebugs = true;

bool blClientSayAuthor = g_Hooks.RegisterHook( Hooks::Player::ClientSay, @UTILS::MapAuthorSay );

namespace UTILS
{
    /*
        FireTargets function customized for the usage of custom entities.

        SAMPLE:

            void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
            {
				UTILS::Trigger( self.pev.target, pActivator, pCaller, useType, delay_key_value )
			}
		now your entity supports the usage of USE_TYPE the same as multi_manager (#0 #1 #2) at the end of the target value
    */
    void Trigger( string key, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flDelay = 0.0f )
    {
        if( string( key ).IsEmpty() )
        {
            return;
        }

        string ReadTarget = Replace(key,{
            { "#0", "" },
            { "#1", "" },
            { "#2", "" }
        });

        USE_TYPE NewUseType = useType;

        // Those values overrides the default USE_TYPE
        if( string( key ).EndsWith( "#0" ) ){NewUseType = USE_OFF;}
        if( string( key ).EndsWith( "#1" ) ){NewUseType = USE_ON;}
        if( string( key ).EndsWith( "#2" ) ){NewUseType = USE_KILL;}

        if( NewUseType == USE_KILL )
        {
            CBaseEntity@ pKillEnt = null; // hack because USE_KILL doesn't work.
            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( pKillEnt, ReadTarget ) ) !is null ){
                g_EntityFuncs.Remove( pKillEnt );
            }
        }else{
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pCaller, NewUseType, flDelay );
        }


        Debug( "[UTILS::Trigger]" );
        Debug( "Fired entity '" + ReadTarget + "'" );
        Debug( "!activator '"+ string( pActivator.pev.classname ) + "' " + string( pActivator.pev.netname ) );
        Debug( "!caller '" + pCaller.pev.classname + "'" );
        Debug( "USE_TYPE '" + NewUseType + "'" );
        Debug( "Delay '" + flDelay + "'" );
    }

    /*
        Add extra keyvalues to your custom entity.

        SAMPLE:

			class CBaseGameTextCustom : ScriptBaseEntity, UTILS::MoreKeyValues
			{
				bool KeyValue( const string& in szKey, const string& in szValue )
				{
					ExtraKeyValues(szKey, szValue);
				}
			}
    */
    mixin class MoreKeyValues
    {
        private float delay = 0.0f;
        
        private int origin_to_world = 0;
        private Vector minhullsize();
        private Vector maxhullsize();

        private string m_iszMaster();

        private string_t message_spanish,
        message_portuguese, message_german,
        message_french, message_italian,
        message_esperanto, message_czech,
        message_dutch, message_spanish2,
        message_indonesian, message_romanian,
        message_turkish, message_albanian;

        bool ExtraKeyValues( const string& in szKey, const string& in szValue )
        {
            if( szKey == "delay" )
            {
                delay = atof(szValue);
            }
            else if ( szKey == "master" )
            {
                this.m_iszMaster = szValue;
            }
            else if( szKey == "minhullsize" ) 
            {
                g_Utility.StringToVector( minhullsize, szValue );
            }
            else if( szKey == "maxhullsize" ) 
            {
                g_Utility.StringToVector( maxhullsize, szValue );
            }
            else if( szKey == "origin_to_world" )
            {
                origin_to_world = atoi(szValue);
            }
            else if( szKey == "message_spanish" )
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

        /*
            Reads a language from the previus messages keyvalues. if empty = return english (message)

            string( ReadLanguage )
        */
        string_t ReadLanguages( int iLanguage )
        {
            dictionary Languages =
            {
                { "0", self.pev.message},
                { "1", string( message_spanish ).IsEmpty() ? string( message_spanish2 ).IsEmpty() ? self.pev.message : message_spanish2 : message_spanish },
                { "9", string( message_spanish2 ).IsEmpty() ? string( message_spanish ).IsEmpty() ? self.pev.message : message_spanish : message_spanish2 },
                { "2", string( message_portuguese ).IsEmpty() ? self.pev.message : message_portuguese },
                { "3", string( message_german ).IsEmpty() ? self.pev.message : message_portuguese },
                { "4", string( message_french ).IsEmpty() ? self.pev.message : message_french },
                { "5", string( message_italian ).IsEmpty() ? self.pev.message : message_italian },
                { "6", string( message_esperanto ).IsEmpty() ? self.pev.message : message_esperanto },
                { "7", string( message_czech ).IsEmpty() ? self.pev.message : message_czech },
                { "8", string( message_dutch ).IsEmpty() ? self.pev.message : message_dutch },
                { "9", string( message_spanish2 ).IsEmpty() ? string( message_spanish ).IsEmpty() ? self.pev.message : message_spanish : message_spanish2 },
                { "10", string( message_indonesian ).IsEmpty() ? self.pev.message : message_indonesian },
                { "11", string( message_romanian ).IsEmpty() ? self.pev.message : message_romanian },
                { "12", string( message_turkish ).IsEmpty() ? self.pev.message : message_turkish },
                { "13", string( message_albanian ).IsEmpty() ? self.pev.message : message_albanian }
            };

            return string_t( Languages[ iLanguage ] );
        }

        /*
            Returns wharever this entity's master has been triggered.

            if( master() )
                return;
        */
        bool master() { if( !m_iszMaster.IsEmpty() && !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) ) { return true; } return false; }

        /*
            Make a entity take size by its brush model or by its minhullsize/maxhullsize
            if the key value "origin_to_world" is set.
            when using hullsizes the bbox zone will depend on the world's origin
            but not the entity's origin.

            SetBoundaries();
        */
        void SetBoundaries()
        {
            if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
            {
                g_EntityFuncs.SetModel( self, self.pev.model );
                g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
                g_EntityFuncs.SetOrigin( self, self.pev.origin );
                Debug
                    ( "[UTILS::SetBoundaries]\n"
                    + "Set size of entity '" + string( self.pev.classname ) + "'\n"
                    + "model '"+ string( self.pev.model ) +"'\n"
                    + "origin '" + self.pev.origin.x + " " + self.pev.origin.y + " " + self.pev.origin.z + "'\n"
                );
            }
            else
            {
                g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
                Debug
                    ( "[UTILS::SetBoundaries]\n"
                    + "Set size of entity '" + string( self.pev.classname ) + "'\n"
                    + "Max BBox: '" + string( maxhullsize.x ) + " " + string( maxhullsize.y ) + " " + string( maxhullsize.z ) + "'\n"
                    + "Min BBox: '" + string( minhullsize.x ) + " " + string( minhullsize.y ) + " " + string( minhullsize.z ) + "'\n"
                );

                if( origin_to_world == 1 )
                {
                    g_EntityFuncs.SetOrigin( self, self.pev.origin );
                    Debug("BBox set around entity's origin." );
                }
                else
                {
                    g_EntityFuncs.SetOrigin( self, Vector(0,0,0) );
                    Debug("BBox set around worlds's origin." );
                }
            }
        }
    }

    /*
        Replace the given string

        string StrReplacedString = UTILS::Replace( StrYourFullString ),
        {
            { "!frags", string( self.pev.frags ) },
            { "!activator", string( self.pev.netname ) }
        } );
    */
    string Replace( string_t FullSentence, dictionary@ pArgs )
    {
        string str = string(FullSentence);
        array<string> args = pArgs.getKeys();

        for (uint i = 0; i < args.length(); i++)
        {
            str.Replace( args[i], string( pArgs[ args[i] ] ) );
        }

        return str;
    }

    /*
        UTILS::Debug( "any debug" );
    */
    void Debug( const string String )
    {
        if( ShowDebugs )
        {
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, String + "\n" );
        }
    }

    /*
        Shows yourself as a map author
        USAGE:

        string AuthorsID;
    */
    string AuthorsID;
    HookReturnCode MapAuthorSay( SayParameters@ pParams )
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();

        if( AuthorsID.Find( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) != String::INVALID_INDEX )
        {
            const CCommand@ args = pParams.GetArguments();
            string FullSentence = pParams.GetCommand();
            pParams.ShouldHide = true;
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, '[Author] ' + pPlayer.pev.netname + ': ' + FullSentence + '\n' );
        }
        return HOOK_CONTINUE;
    }
}
// End of namespace