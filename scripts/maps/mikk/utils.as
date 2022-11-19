/*
MapScripts:
#include "mikk/utils"

Plugins:
#include "../maps/mikk/utils"
*/

namespace UTILS
{
    /* instead of this use Intersect. InsideZone is here only for legacy.
    

        bool = self.Intersects( CBaseEntity@ pOther )
        "description" : "Returns whether this entity intersects with the given entity."

        UTILS::InsideZone( entity that need to be inside, of this entity );
    */
    bool InsideZone( CBaseEntity@ pInsider, CBaseEntity@ self )
    {
        bool blInside = true;
        blInside = blInside && pInsider.pev.origin.x + pInsider.pev.maxs.x >= self.pev.origin.x + self.pev.mins.x;
        blInside = blInside && pInsider.pev.origin.y + pInsider.pev.maxs.y >= self.pev.origin.y + self.pev.mins.y;
        blInside = blInside && pInsider.pev.origin.z + pInsider.pev.maxs.z >= self.pev.origin.z + self.pev.mins.z;
        blInside = blInside && pInsider.pev.origin.x + pInsider.pev.mins.x <= self.pev.origin.x + self.pev.maxs.x;
        blInside = blInside && pInsider.pev.origin.y + pInsider.pev.mins.y <= self.pev.origin.y + self.pev.maxs.y;
        blInside = blInside && pInsider.pev.origin.z + pInsider.pev.mins.z <= self.pev.origin.z + self.pev.maxs.z;

        return blInside;
    }

    /*
        Make a entity take size by its brush model or by its minhullsize/maxhullsize

        UTILS::SetSize( entity to set size, true/false to keep origin when using hullsizes );
    */
    void SetSize( CBaseEntity@ self, const bool KeepOrigin = false )
    {
        if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            Debug("SetSize: Set size of entity '" + string( self.pev.classname ) + "' with model "+ string( self.pev.model ) +"\n" );
        }
        else
        {
            g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
            Debug("SetSize: Set size of entity '" + string( self.pev.classname ) + "' with vectors." );

			if( KeepOrigin )
			{
				g_EntityFuncs.SetOrigin( self, self.pev.origin );
				Debug(" around its origin." );
			}
			Debug("\n" );
        }
    }

    /*
        Make your custom entity be able to send different types of trigger USE_ON/OFF/TOGGLE/KILL respectively with the same format as a multi_manager

        UTILS::TriggerMode( string(self.pev.target), pActivator, 0.0f );
    */
    void TriggerMode( string key, CBaseEntity@ pActivator, float flDelay = 0.0f )
    {
        string ReadTarget = Replace(key,{
            { "#0", "" },
            { "#1", "" },
            { "#2", "" }
        });

        if( string( key ).EndsWith( "#0" ) )
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_OFF, flDelay );
            Debug("TriggerMode: Fired entity '" + ReadTarget + "' with OFF Trigger Mode.\n" );
        }
        else if( string( key ).EndsWith( "#1" ) )
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_ON, flDelay );
            Debug("TriggerMode: Fired entity '" + ReadTarget + "' with ON Trigger Mode.\n" );
        }
        else if( string( key ).EndsWith( "#2" ) )
        {
            CBaseEntity@ pKillEnt = null;

            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( pKillEnt, key ) ) !is null )
            {
                g_EntityFuncs.Remove( pKillEnt );
				Debug("TriggerMode: Fired entity '" + ReadTarget + "' with KILL Trigger Mode.\n" );
            }
        }
        else
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pActivator, USE_TOGGLE );
            Debug("TriggerMode: Fired entity '" + ReadTarget + "' with TOGGLE Trigger Mode.\n" );
        }
    }

    /*
        Shows a custom MOTD to the given target. code by Geigue

        UTILS::ShowMOTD( pActivator, "title", "message");
    */
    void ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
    {
        if(!hPlayer){return;}
        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
        if(pPlayer is null){return;}
        NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        title.WriteString( szTitle );
        title.End();
        uint iChars = 0;
        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        for( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
            iChars++;
            if( iChars == 32 )
            {
                NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                message.WriteByte( 0 );
                message.WriteString( szSplitMsg );
                message.End();
                
                iChars = 0;
            }
        }
        // If we reached the end, send the last letters of the message
        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );
            NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
            fix.WriteByte( 0 );
            fix.WriteString( szSplitMsg );
            fix.End();
        }
        NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
        endMOTD.WriteByte( 1 );
        endMOTD.WriteString( "\n" );
        endMOTD.End();
        NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
        restore.End();
    }

    /*
        Add extra keyvalues to your custom entity.

        class CBaseGameTextCustom : ScriptBaseEntity, UTILS::MoreKeyValues
    */
    mixin class MoreKeyValues
    {
        private string m_iszMaster();
        private string_t message_spanish,
        message_portuguese, message_german,
        message_french, message_italian,
        message_esperanto;

        bool ExtraKeyValues( const string& in szKey, const string& in szValue )
        {
            if( szKey == "minhullsize" ) 
            {
                g_Utility.StringToVector( self.pev.vuser1, szValue );
                return true;
            }
            else if( szKey == "maxhullsize" ) 
            {
                g_Utility.StringToVector( self.pev.vuser2, szValue );
                return true;
            }
            else if ( szKey == "master" )
            {
                this.m_iszMaster = szValue;
                return true;
            }
            if(szKey == "message_spanish")
            {
                message_spanish = szValue;
            }
            else if(szKey == "message_portuguese")
            {
                message_portuguese = szValue;
            }
            else if(szKey == "message_german")
            {
                message_german = szValue;
            }
            else if(szKey == "message_french")
            {
                message_french = szValue;
            }
            else if(szKey == "message_italian")
            {
                message_italian = szValue;
            }
            else if(szKey == "message_esperanto")
            {
                message_esperanto = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }

            return true;
        }

		/*
			Reads a language from the previus language keyvalues.

			string( ReadLanguage )
		*/
        string_t ReadLanguages( int iLanguage )
        {
            dictionary Languages =
            {
                { "0", self.pev.message},
                { "1", string( message_spanish ).IsEmpty() ? self.pev.message : message_spanish },
                { "2", string( message_portuguese ).IsEmpty() ? self.pev.message : message_portuguese },
                { "3", string( message_german ).IsEmpty() ? self.pev.message : message_portuguese },
                { "4", string( message_french ).IsEmpty() ? self.pev.message : message_french },
                { "5", string( message_italian ).IsEmpty() ? self.pev.message : message_italian },
                { "6", string( message_esperanto ).IsEmpty() ? self.pev.message : message_esperanto }
            };

            return string_t( Languages[ iLanguage ] );
        }

		/*
			Return wharever this entity's master has been triggered.
            
            if( multisource() )
            {
                self.pev.nextthink = g_Engine.time + 0.1f;
                return;
            }
		*/
        bool multisource()
        {
            if( !m_iszMaster.IsEmpty() && !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
            {
                return true;
            }
            return false;
        }
    }
    
    /*
        Gets the float of a custom keyvalue

        int ivalueis = int( UTILS::GetCKV( pPlayer, "$f_keyvalue" ) );
    */
    int GetCKV( CBasePlayer@ pPlayer, string valuename )
    {
        CustomKeyvalues@ CKVReturn = pPlayer.GetCustomKeyvalues();
        return int( CKVReturn.GetKeyvalue ( valuename ).GetFloat() );
    }

	/*
		Replace the given string with something else.

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
        Change the server's name (Only in scoreboard)

        UTILS::ServerName( "Campaign 'Half-Life: Episode One'" );
    */
    void ServerName( const string StrTitle)
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
            message.WriteString(StrTitle);
        message.End();
    }

    /*
        Call a intermission like if a level has ended. cant stop so use just before a restart

        UTILS::SVC_INTERMISSION();
    */
    void SVC_INTERMISSION()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
        message.End();
    }

    /*
        Call to set a view mode to the player

        UTILS::ViewMode( int imode, pPlayer );
		0 = third person
    */
    void ViewMode( int imode, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ViewMode, pPlayer.edict() );
            message.WriteByte(imode);
        message.End();
    }

    // https://github.com/baso88/SC_AngelScript/wiki/Map-Scripts
    // "Entity loader: since this behaves like the map loading process, only map scripts can access it to prevent plugins from altering gameplay."
    // altering gameplay? my balls, hold buy menus!!
    // Also this makes no sense. if i want to spawn a entity in my map y WILL do it in my BSP why via script?
    // Bruh this feature should be for plugins that want to make things like i am doing with multi language and antirush for lazy server ops :face_with_monocle:

    // spawn entities easly in a ripent-format with this stupid code that did take me alot of time because i'm stupid with string things -Mikkrophone mad
    
    // Call with full route for plugins and maps.
    // UTILS::LoadRipentFile( "scripts/plugins/ripent/translations/" + string( g_Engine.mapname ) + ".ent" );
    void LoadRipentFile( const string EntFileLoadText )
    {
        string LoadEntityFile, line, key, value;
        dictionary g_fileload_keyvalues;

        LoadEntityFile = EntFileLoadText;
        File@ pFile = g_FileSystem.OpenFile( LoadEntityFile, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            Debug("Ripent: WARNING! Failed to open " + LoadEntityFile + " no entities initialised!\n");
            return;
        }

        Debug("Ripent: Initialising entities...\n" );

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 or line[0] == '/' and line[1] == '/' )
            {
                continue;
            }

            if( line[0] != '"' && line[0] != '{' && line[0] != '}' )
            {
                Debug("Ripent: Missing quote.\nFailed to get entity's value '" + line + "'\nEntity will be spawned but this key/value will not be added.\n" );
                continue;
            }

            /*if( line == '"modify"' ) // A function to modify an existent entity in the game -TODO
            {
                blModifying = true;
                continue;
            }
            
            if( blModifying )
            {
                // Dictionary aparte en el que usaremos para comparar luego.
                
                if( dictcreado Classname == Classname )
                    if( dictcreado Cualquiera == Cualquiera )
                        if( si NO tiene custom keyvalue )
                            eliminar entidad;
                            blModifying = false;
            }*/

            if( line[0] == '{' or line[0] == '}' )
            {
                g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, string( line[0] ) + '\n' );

                if( line[0] == '}' )
                {
                    CBaseEntity@ pInitialized = g_EntityFuncs.CreateEntity( string( g_fileload_keyvalues[ "classname" ] ), g_fileload_keyvalues, true );

                    if( pInitialized !is null )
                    {
                        Debug("Ripent: Entity '" + string( g_fileload_keyvalues[ "classname" ] ) + "' initialised.\n" );
                    }
                    else
                    {
                        Debug("Ripent: WARNING! Entity '" + string( g_fileload_keyvalues[ "classname" ] ) + "' Not initialised.\n" );
                    }

                    g_fileload_keyvalues.deleteAll();
                }
                continue;
            }
            
            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );
            
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, '"'+key+'" ' );
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, '"'+value+'"\n' );

            g_fileload_keyvalues[ key ] = value;
        }
        pFile.Close();

        g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, "\nRipent Script Utility created by Mikk https://github.com/Mikk155\nSpecial thanks to Gaftherman https://github.com/Gaftherman\n\n" );
    }

    /*
        Call to send debugs if the player decides to see them (say /debug)

        UTILS::Debug( "any debug" );
    */
    void Debug( const string String )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ Player = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( Player !is null && UTILS::GetCKV( Player, "$i_debug" ) != 0 )
                g_PlayerFuncs.ClientPrint( Player, HUD_PRINTCONSOLE, String + '\n' );
        }
    }
}
// End of namespace