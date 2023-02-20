CUtils g_Util;

final class CUtils
{
    array<string> ScriptAuthor;
    array<string> MapAuthor;

    void Trigger( string& in key, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE& in useType = USE_TOGGLE, float& in flDelay = 0.0f )
    {
        if( key.IsEmpty() )
        {
            return;
        }

        g_Util.DebugMessage( "g_Util.Trigger:" );

        string ReadTarget = g_Util.StringReplace
        (
            key,
            {
                { "#0", "" },
                { "#1", "" },
                { "#2", "" }
            }
        );

        CBaseEntity@ pFind = g_EntityFuncs.FindEntityByTargetname( pFind, ReadTarget );
        if( pFind is null )
        {
            g_Util.DebugMessage( "No entity found with targetname '" + ReadTarget + "'" );
            return;
        }

        USE_TYPE NewUseType = useType;

        // Those values overrides the default USE_TYPE.
        if( string( key ).EndsWith( "#0" ) )
        {
            NewUseType = USE_OFF;
        }
        if( string( key ).EndsWith( "#1" ) )
        {
            NewUseType = USE_ON;
        }
        if( string( key ).EndsWith( "#2" ) )
        {
            NewUseType = USE_KILL;
        }

        if( NewUseType == USE_KILL )
        {
            CBaseEntity@ pKillEnt = null;

			// hack cuz USE_KILL doesn't work.
            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( pKillEnt, ReadTarget ) ) !is null )
            {
                g_EntityFuncs.Remove( pKillEnt );
            }
        }
        else
        {
            g_EntityFuncs.FireTargets( ReadTarget, pActivator, pCaller, NewUseType, flDelay );
        }

        string What = ( NewUseType == USE_OFF ) ? "OFF" : ( NewUseType == USE_ON ) ? "ON" : ( NewUseType == USE_KILL ) ? "KILL" : "TOGGLE";

        g_Util.DebugMessage( "Fired entity '" + ReadTarget + "'" );
        g_Util.DebugMessage( "!activator '"+ string( pActivator.pev.classname ) + "' " + string( pActivator.pev.netname ) );
        g_Util.DebugMessage( "!caller '" + pCaller.pev.classname + "'" );
        g_Util.DebugMessage( "USE_TYPE '" + NewUseType + "' ( " + What + " )" );
        g_Util.DebugMessage( "Delay '" + flDelay + "'" );
    }

    string StringReplace( string_t FullSentence, dictionary@ pArgs )
    {
        string str = string(FullSentence);
        array<string> args = pArgs.getKeys();

        for (uint i = 0; i < args.length(); i++)
        {
            str.Replace( args[i], string( pArgs[ args[i] ] ) );
        }

        return str;
    }

    void ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
    {
        if(!hPlayer)
        {
            return;
        }

        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

        if(pPlayer is null)
        {
            return;
        }

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

    bool ShowDebugs = false;
    void DebugMessage( const string& in szMessage ) { if( ShowDebugs ) { g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szMessage + "\n" ); } else { g_Game.AlertMessage( at_console, szMessage + "\n" ); } }
    void DebugMode( const bool& in blmode = false ) { ShowDebugs = blmode; }

    string GetCKV( CBaseEntity@ pEntity, string szKey )
    {
        if( pEntity is null or szKey.IsEmpty() )
        {
            g_Util.DebugMessage( "g_Util.GetCKV:" );
            g_Util.DebugMessage( "Null entity nor value!" );
            return String::INVALID_INDEX;
        }

        return pEntity.GetCustomKeyvalues().GetKeyvalue( szKey ).GetString();
    }

    void SetCKV( CBaseEntity@ pEntity, string szKey, string szValue )
    {
        g_Util.DebugMessage( "g_Util.SetCKV:" );

        if( pEntity is null or szKey.IsEmpty() or szValue.IsEmpty() )
        {
            g_Util.DebugMessage( "Null entity nor value!" );
            return;
        }

        // Can't set strings or i didn't test enought. workaround.
        dictionary g_keyvalues =
        {
            { "target", "!activator" },
            { "m_iszValueName", szKey },
            { "m_iszNewValue", szValue },
            { "targetname", pEntity.GetTargetname() + "_ckv" }
        };
        CBaseEntity@ pChangeValue = g_EntityFuncs.CreateEntity( "trigger_changevalue", g_keyvalues );

        if( pChangeValue !is null )
        {
            pChangeValue.Use( pEntity, pEntity, USE_ON, 0.0f );
            g_EntityFuncs.Remove( pChangeValue );
            g_Util.DebugMessage( "Set CustomKeyValue '" + szKey + "' -> '" + szValue + "' for " + ( pEntity.IsPlayer() ? pEntity.pev.netname : pEntity.pev.classname ) );
        }
    }

    bool IsStringInFile( const string& in szPath, string& in szComparator )
    {
        File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::READ );

        if( pFile is null || !pFile.IsOpen() )
            return false;

        string strMap = szComparator;
        strMap.ToLowercase();

        string line;

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );
            line.Trim();

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
                continue;

            line.ToLowercase();

            if( strMap == line )
            {
                pFile.Close();
                return true;
            }

            if( line.EndsWith( "*", String::CaseInsensitive ) )
            {
                line = line.SubString( 0, line.Length()-1 );

                if( strMap.Find( line ) != Math.SIZE_MAX )
                {
                    pFile.Close();
                    return true;
                }
            }
        }

        pFile.Close();

        return false;
    }

    bool IsPluginInstalled( const string& in szPluginName )
    {
        array<string> pluginList = g_PluginManager.GetPluginList();

        if( pluginList.find( szPluginName ) >= 0 )
        {
            return true;
        }
        return false;
    }

    string RIPENTDebugger;

    void RipentShowInfo( CBasePlayer@ pPlayer )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Printed initialised entities info at your console.\n" );

		// If we reached the limit replace and send again
		while( RIPENTDebugger != '' )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  RIPENTDebugger.SubString( 0, 68 ) );

			if( RIPENTDebugger.Length() <= 68 ) RIPENTDebugger = '';
			else RIPENTDebugger = RIPENTDebugger.SubString( 68, RIPENTDebugger.Length() );
		}

        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n\n" );
    }

    bool LoadEntities( const string& in EntFileLoadText = 'scripts/maps/store/sex.txt', const string& in szClassname = '' )
    {
		RIPENTDebugger = "";

        string line, key, value;
        bool match = false;
        dictionary g_KeyValues;

        File@ pFile = g_FileSystem.OpenFile( EntFileLoadText, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            RIPENTDebugger = RIPENTDebugger + "RIPENT: Failed to open " + EntFileLoadText + " no entities initialised!\n";
            return false;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 )
            {
                continue;
            }

            if( line[0] == '/' and line[1] == '/' )
            {
				RIPENTDebugger = RIPENTDebugger + line + "\n";
                continue;
            }

            if( line == '"match"' )
            {
                match = true;
            }

            if( line[0] == '{' or line[0] == '}' )
            {
                RIPENTDebugger = RIPENTDebugger + string( line[0] ) + '\n';

                if( line[0] == '}' )
                {
                    if( match )
                    {
                        match = false;
                        continue;
                    }

					string Classname;
					Classname = szClassname;

					if( !string( g_KeyValues[ "classname" ] ).IsEmpty() ) Classname = string( g_KeyValues[ "classname" ] );

                    CBaseEntity@ pInitialized = g_EntityFuncs.CreateEntity( Classname, g_KeyValues, true );

                    if( pInitialized !is null )
                    {
                        RIPENTDebugger = RIPENTDebugger + "RIPENT: Entity '" + Classname + "' initialised.\n";
                    }
                    else
                    {
                        RIPENTDebugger = RIPENTDebugger + "RIPENT: A entity was not initialised.\n";
                    }

                    RIPENTDebugger = RIPENTDebugger + "RIPENT: Clearing Dictionary...\n";
                    g_KeyValues.deleteAll();
                }
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            if( match )
            {
                CBaseEntity@ pMatch = null;

                while( ( @pMatch = g_EntityFuncs.FindEntityByString( pMatch, key, value ) ) !is null )
                {
                    if( !pMatch.GetCustomKeyvalues().HasKeyvalue( "$i_ripent" ) )
                    {
                        g_EntityFuncs.Remove( pMatch );
                        RIPENTDebugger = RIPENTDebugger + 'RIPENT: Matched and removed entity with key and value ';
                    }
                }
            }

            RIPENTDebugger = RIPENTDebugger + '"'+key+'" "'+value+'"\n';

            g_KeyValues[ key ] = value;
        }
        pFile.Close();

        RIPENTDebugger = RIPENTDebugger + "\nRIPENT Script Utility created by Mikk https://github.com/Mikk155\nSpecial thanks to Gaftherman https://github.com/Gaftherman\n\n";
        return true;
    }

	int GetNumberOfEntities( const string& in szClassname )
	{
		int NumberOfEntities = 0;

		CBaseEntity@ pEntity = null;

		while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szClassname ) ) !is null )
		{
			NumberOfEntities += 1;
		}

        g_Util.DebugMessage( "g_Util.GetNumberOfEntities:\nFound '" + string( NumberOfEntities ) + "' Entities" );
		return NumberOfEntities;
	}
}
// End of final class


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
            { "english", self.pev.message},
            { "spanish", string( message_spanish ).IsEmpty() ? string( message_spanish2 ).IsEmpty() ? self.pev.message : message_spanish2 : message_spanish },
            { "spanish spain", string( message_spanish2 ).IsEmpty() ? string( message_spanish ).IsEmpty() ? self.pev.message : message_spanish : message_spanish2 },
            { "portuguese", string( message_portuguese ).IsEmpty() ? self.pev.message : message_portuguese },
            { "german", string( message_german ).IsEmpty() ? self.pev.message : message_german },
            { "french", string( message_french ).IsEmpty() ? self.pev.message : message_french },
            { "italian", string( message_italian ).IsEmpty() ? self.pev.message : message_italian },
            { "esperanto", string( message_esperanto ).IsEmpty() ? self.pev.message : message_esperanto },
            { "czech", string( message_czech ).IsEmpty() ? self.pev.message : message_czech },
            { "dutch", string( message_dutch ).IsEmpty() ? self.pev.message : message_dutch },
            { "indonesian", string( message_indonesian ).IsEmpty() ? self.pev.message : message_indonesian },
            { "romanian", string( message_romanian ).IsEmpty() ? self.pev.message : message_romanian },
            { "turkish", string( message_turkish ).IsEmpty() ? self.pev.message : message_turkish },
            { "albanian", string( message_albanian ).IsEmpty() ? self.pev.message : message_albanian }
        };
        
        if( CurrentLanguage == "" || CurrentLanguage.IsEmpty() )
        {
            return string_t( self.pev.message );
        }

        return string_t( Languages[ CurrentLanguage ] );
    }
}
// End of mixin class


mixin class ScriptBaseCustomEntity
{
    private float delay = 0.0f;
    private Vector minhullsize();
    private Vector maxhullsize();

    private string m_iszMaster();

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
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }

        return true;
    }

    bool master()
    {
        if( !m_iszMaster.IsEmpty()
        and !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
        {
            return true;
        }
        return false;
    }

    void SetBoundaries()
    {
        if( string( self.pev.model ).StartsWith( "*" ) && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            g_Util.DebugMessage( "g_Util.SetBoundaries:" );
            g_Util.DebugMessage( "Set size of entity '" + string( self.pev.classname ) + "'" );
            g_Util.DebugMessage( "model '"+ string( self.pev.model ) +"'" );
            g_Util.DebugMessage( "origin '" + self.pev.origin.x + " " + self.pev.origin.y + " " + self.pev.origin.z + "'" );
        }
        else
        {
            g_EntityFuncs.SetSize( self.pev, minhullsize, maxhullsize );
            g_Util.DebugMessage( "g_Util.SetBoundaries:" );
            g_Util.DebugMessage( "Set size of entity '" + string( self.pev.classname ) + "'" );
            g_Util.DebugMessage( "Max BBox: '" + string( maxhullsize.x ) + " " + string( maxhullsize.y ) + " " + string( maxhullsize.z ) + "'" );
            g_Util.DebugMessage( "Min BBox: '" + string( minhullsize.x ) + " " + string( minhullsize.y ) + " " + string( minhullsize.z ) + "'" );

            if( self.pev.origin != g_vecZero )
            {
                g_EntityFuncs.SetOrigin( self, self.pev.origin );
                g_Util.DebugMessage("BBox set around entity's origin." );
            }
            else
            {
                g_Util.DebugMessage("BBox set around worlds's origin." );
            }
        }
    }
}
// End of mixin class

bool blClientSayHook = g_Hooks.RegisterHook( Hooks::Player::ClientSay, @UTILS::ClientSay );
bool blClientPutHook = g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @UTILS::ClientPutInServer );
bool blMapchangeHook = g_Hooks.RegisterHook( Hooks::Game::MapChange, @UTILS::MapChange );

namespace UTILS
{
    HookReturnCode MapChange()
    {
		g_Util.ScriptAuthor.resize(0);
		g_Util.MapAuthor.resize(0);
		g_Util.ScriptAuthor.insertLast( "Script: utils\nAuthors:\nGithub: github.com/Mikk155\ngithub.com/Gaftherman\ngithub.com/JulianR0\ngithub.com/RedSprend\nDescription: Lot of utility scripts.\n");
        return HOOK_CONTINUE;
	}

    HookReturnCode ClientSay( SayParameters@ pParams )
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        const CCommand@ args = pParams.GetArguments();

        if( args.Arg(0) == "info" || args.Arg(0) == "/info" )
        {
            ShowInfo( pPlayer );
        }
        else if( args.Arg(0) == "ripent" || args.Arg(0) == "/ripent" )
        {
            g_Util.RipentShowInfo( pPlayer );
        }

        for(uint ui = 0; ui < g_Util.MapAuthor.length(); ui++)
        {
            if( g_Util.MapAuthor[ui] == g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) )
            {
                g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Author] " + pPlayer.pev.netname + ": " + pParams.GetCommand() + "\n" );
                pParams.ShouldHide = true;
            }
        }

        return HOOK_CONTINUE;
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        ShowInfo( pPlayer );
        return HOOK_CONTINUE;
    }
    
    void ShowInfo( CBasePlayer@ pPlayer )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Printed Scripts info at your console.\n" );
        for(uint ui = 0; ui < g_Util.ScriptAuthor.length(); ui++)
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n\n" );

            string FullString = g_Util.ScriptAuthor[ui];

            // If we reached the limit replace and send again
            while( FullString != '' )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  FullString.SubString( 0, 68 ) );

                if( FullString.Length() <= 68 ) FullString = '';
                else FullString = FullString.SubString( 68, FullString.Length() );
            }
        }
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "\n====================================\n\n" );
    }

    void GetPlayerData( CBaseEntity@ self )
    {
        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null )
            {
                g_Util.SetCKV( pPlayer, "$i_hassuit", string( pPlayer.HasSuit() ) );
                g_Util.SetCKV( pPlayer, "$s_steamid", string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );
                g_Util.SetCKV( pPlayer, "$i_adminlevel", string( g_PlayerFuncs.AdminLevel( pPlayer ) ) );
                g_Util.SetCKV( pPlayer, "$i_hascorpse", string( pPlayer.GetObserver().HasCorpse() ) );
                g_Util.SetCKV( pPlayer, "$i_flashlight", string( pPlayer.FlashlightIsOn() ) );
				g_Util.Trigger( self.pev.netname, pPlayer, self, USE_TOGGLE, 0.0f );
            }
        }
		self.Use( null, null, USE_OFF, 0.0f );
    }
}
// End of namespace.