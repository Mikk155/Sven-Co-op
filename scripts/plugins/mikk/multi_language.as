/*
    INSTALL:

    "plugin"
    {
        "name" "multi_language"
        "script" "mikk/multi_language"
    }

USAGE:
Create a ".mlang" file inside "scripts/plugins/mikk/translations/"
The syntax is similar as ripent see "scripts/plugins/mikk/translations/multi_language_example.mlang"

*/

#include "../../maps/mikk/entities/utils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk, Gaftherman, Kmkz" );
    g_Module.ScriptInfo.SetContactInfo(
    "Mikk: https://github.com/Mikk155

    Gaftherman: https://github.com/Gaftherman

    Kmkz: https://github.com/kmkz27"
    );

    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

string line, LoadDefaultMsgs, LoadEntFile, FirstParameter, SecondParameter;

bool Debug = true, DidntLoad = false, spanish = false, portuguese = false, german = false , french = false, italian = false, esperanto = false;

dictionary g_default_keysvalues;
dictionary g_fileload_keyvalues;
dictionary g_PlayerKeepLenguage;

const array<string> strKeyValues =
{
    "targetname",
    "target",
    "killtarget",
    "spawnflags",
    "delay",
    "effect",
    "x",
    "y",
    "color",
    "color2",
    "fadein",
    "fadeout",
    "holdtime",
    "fxtime",
    "channel",
    "messagesound",
    "messagevolume",
    "frags",
    "message",
    "message_spanish",
    "message_portuguese",
    "message_german",
    "message_french",
    "message_italian",
    "message_esperanto"
};

void MapInit()
{
    spanish    = false;
    portuguese = false;
    german     = false;
    french     = false;
    italian    = false;
    esperanto  = false;

    g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom", "game_text_custom" );

    // https://github.com/baso88/SC_AngelScript/wiki/Map-Scripts
    // "Entity loader: since this behaves like the map loading process, only map scripts can access it to prevent plugins from altering gameplay."
    // altering gameplay? my balls buy menus!!
    // Also this makes no sense. if i want to spawn a entity in my map y WILL do it in my BSP why in a txt?
    // Bruh this feature should be for plugins that want to make things like i am doing
    // With this stupid code that did take me alot of time because i'm stupid with string things -Mikkrophone mad

    LoadEntFile = "scripts/plugins/mikk/translations/" + string( g_Engine.mapname ) + ".mlang";
    File@ pFile = g_FileSystem.OpenFile( LoadEntFile, OpenFile::READ );

    if( pFile is null or !pFile.IsOpen() )
    {
        g_EngineFuncs.ServerPrint("WARNING! Failed to open " + LoadDefaultMsgs + " no multi-language entities loaded!\n");
        DidntLoad = true;
        return;
    }

    if(Debug) g_Game.AlertMessage( at_console, "\nMulti-Language entities initialized:\n");

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );

        if( line.Length() < 1 or line[0] == '/' and line[1] == '/' )
        {
            continue;
        }

        if( line[0] == '{' && Debug ) g_Game.AlertMessage( at_console, '{\n');

        // Verify that the .mlang file want those languages to be enabled and then show those in CreateMenu()
        if( string( line ).StartsWith( 'message_spanish ' ) ) spanish = true;
        if( string( line ).StartsWith( 'message_portuguese ' ) ) portuguese = true;
        if( string( line ).StartsWith( 'message_german ' ) ) german = true;
        if( string( line ).StartsWith( 'message_french ' ) ) french = true;
        if( string( line ).StartsWith( 'message_italian ' ) ) italian = true;
        if( string( line ).StartsWith( 'message_esperanto ' ) ) esperanto = true;

        for(uint i = 0; i < strKeyValues.length(); i++)
        {
            if( string( line ).StartsWith( string( strKeyValues[i] + " " ) ) )
            {
                if(Debug) g_Game.AlertMessage( at_console, '"' + strKeyValues[i] + '" "' + line.Replace( strKeyValues[i] + " ", "" ) + '"\n');
                g_fileload_keyvalues[ strKeyValues[i] ] = line.Replace( strKeyValues[i] + " ", "" );
            }
        }

        if( line[0] == '}' )
        {
            g_EntityFuncs.CreateEntity( "game_text_custom", g_fileload_keyvalues, true );
            if(Debug) g_Game.AlertMessage( at_console, '"classname" "game_text_custom"\n');
            if(Debug) g_Game.AlertMessage( at_console, '}\n');
            g_fileload_keyvalues.deleteAll();
        }
    }
    pFile.Close();

    LoadDefaultFile = "scripts/plugins/mikk/translations/multi_language_example.mlang";
    File@ pDefault = g_FileSystem.OpenFile( LoadDefaultFile, OpenFile::READ );

    while( !pDefault.EOFReached() )
    {
        pDefault.ReadLine( line );

        if( line.Length() < 1 or line[0] == '/' and line[1] == '/' )
        {
            continue;
        }

        if( line[0] == '{' && Debug ) g_Game.AlertMessage( at_console, '{\n');

        for(uint i = 0; i < strKeyValues.length(); i++)
        {
            if( string( line ).StartsWith( string( strKeyValues[i] + " " ) ) )
            {
                if(Debug) g_Game.AlertMessage( at_console, '"' + strKeyValues[i] + '" "' + line.Replace( strKeyValues[i] + " ", "" ) + '"\n');
                g_default_keysvalues[ strKeyValues[i] ] = line.Replace( strKeyValues[i] + " ", "" );
            }
        }

        if( line[0] == '}' )
        {
            g_EntityFuncs.CreateEntity( "game_text_custom", g_default_keysvalues, true );
            if(Debug) g_Game.AlertMessage( at_console, '"classname" "game_text_custom"\n');
            if(Debug) g_Game.AlertMessage( at_console, '}\n');
            g_default_keysvalues.deleteAll();
        }
    }
    pDefault.Close();
}

class PlayerKeepLenguageData
{
    int lenguage;
}

HookReturnCode MapChange()
{
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
    {
        CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if( plr is null or !plr.IsConnected() )
            continue;

        string SteamID = g_EngineFuncs.GetPlayerAuthId( plr.edict() );

        PlayerKeepLenguageData pData;
        pData.lenguage = UTILS::GetCKV( plr, "$f_lenguage" );
        g_PlayerKeepLenguage[SteamID] = pData;
    }

    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ plr )
{
    if( plr is null )
        return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId( plr.edict() );

    if( g_PlayerKeepLenguage.exists(SteamID) )
    {
        PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict( plr.edict() ), SteamID );
    }
    else
    {
        PlayerKeepLenguageData pData;
        pData.lenguage = UTILS::GetCKV( plr, "$f_lenguage" );
        g_PlayerKeepLenguage[SteamID] = pData;
    }
    return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ plr )
{
    if( plr is null )
        return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId( plr.edict() );

    PlayerKeepLenguageData pData;
    pData.lenguage = UTILS::GetCKV( plr, "$f_lenguage" );
    g_PlayerKeepLenguage[SteamID] = pData;   

    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
    CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(iIndex);

    if( plr is null )
        return;

    PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);

    UTILS::SetCKV( plr, "$f_lenguage", int(pData.lenguage) );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ plr = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();
    
    if( args.ArgC() == 1 && args.Arg(0) == "language"
    || args.Arg(0) == "idioma"
    || args.Arg(0) == "lenguaje"
    || args.Arg(0) == "linga"
    || args.Arg(0) == "lingvo"
    || args.Arg(0) == "sprache"
    || args.Arg(0) == "langue"
    || args.Arg(0) == "linguaggio" )
    {
        if( DidntLoad )
        {
            g_EntityFuncs.FireTargets( "MLANGUAGE_NOSUPPORT", plr, plr, USE_TOGGLE );
        }
        else
        {
            CreateMenu( plr );
        }
    }
    
    return HOOK_CONTINUE;
}

CTextMenu@ g_VoteMenu;

void CreateMenu( CBasePlayer@ plr )
{
    int i = UTILS::GetCKV( plr, "$f_lenguage" );

    @g_VoteMenu = CTextMenu( @MainCallback );

    g_VoteMenu.SetTitle(
        ( i == 1 ) ? "Elige un lenguaje" :
        ( i == 2 ) ? "Selecione um idioma" :
        ( i == 3 ) ? "Wahle eine Sprache" :
        ( i == 4 ) ? "Selectionnez une langue" :
        ( i == 5 ) ? "Seleziona una lingua" :
        ( i == 6 ) ? "Elektu lingvon" : "Select a language"
    );

    g_VoteMenu.AddItem( "English" );
    if( spanish ) g_VoteMenu.AddItem( "Spanish" );
    if( portuguese ) g_VoteMenu.AddItem( "Portuguese" );
    if( german ) g_VoteMenu.AddItem( "German" );
    if( french ) g_VoteMenu.AddItem( "French" );
    if( italian ) g_VoteMenu.AddItem( "Italian" );
    if( esperanto ) g_VoteMenu.AddItem( "Esperanto" );
    g_VoteMenu.Register();
    g_VoteMenu.Open( 25, 0, plr );
}

void MainCallback( CTextMenu@ menu, CBasePlayer@ plr, int iSlot, const CTextMenuItem@ pItem )
{
    if( pItem !is null )
    {
        string sChoice = pItem.m_szName;
        if( sChoice == "English" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 0 );
        }
        else if( sChoice == "Spanish" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 1 );
        }
        else if( sChoice == "Portuguese" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 2 );
        }
        else if( sChoice == "German" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 3 );
        }
        else if( sChoice == "French" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 4 );
        }
        else if( sChoice == "Italian" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 5 );
        }
        else if( sChoice == "Esperanto" )
        {
            UTILS::SetCKV( plr, "$f_lenguage", 6 );
        }
        g_EntityFuncs.FireTargets( "MLANGUAGE_SET_LANGUAGE", plr, plr, USE_TOGGLE );
    }
}

class game_text_custom : ScriptBaseEntity, UTILS::MoreKeyValues
{
    HUDTextParams TextParams;
    private string m_iszMaster();
    private string killtarget = "";
    private string messagesound = "null.wav";
    private float messagevolume = 10;

    void Precache()
    {
        g_SoundSystem.PrecacheSound( messagesound );
        g_Game.PrecacheGeneric( "sound/" + messagesound );

        BaseClass.Precache();
    }

    void Spawn()
    {
        Precache();

        if( string( self.pev.model ).StartsWith( "*" ) and self.IsBSPModel() )
        {
            for( int i = 0; i < g_Engine.maxEntities; ++i ) 
            {
                CBaseEntity@ Triggers = g_EntityFuncs.Instance( i );

                if( Triggers is null 
                or string( Triggers.pev.message ).EndsWith( ".wav" )
                or string( Triggers.pev.message ).EndsWith( ".ogg" )
                or string( Triggers.pev.message ).EndsWith( ".flac" )
                or string( Triggers.pev.message ).EndsWith( ".mp3" ) 
                or string( Triggers.pev.classname ) != "trigger_multiple"
                or string( Triggers.pev.classname ) != "trigger_once"
                or string( Triggers.pev.classname ) != "trigger_push"
                or string( Triggers.pev.classname ) != "trigger_gravity"
                or string( Triggers.pev.classname ) != "trigger_teleport" )  
                {
                    continue;
                }

                if( string( Triggers.pev.model ) == string( self.pev.model ) )
                {
                    UTILS::SetSize( self );

                    // Cuz we can't access to key "wait"
                    if( string( Triggers.pev.classname ) == "trigger_multiple" )
                    {
                        if( string( Triggers.pev.target ).IsEmpty() )
                        {
                            // when the trigger_multiple doesn't have a "target" set. you must set a "targetname" to your game_text_custom
                            Triggers.pev.targetname = self.pev.target;
                        }
                        else
                        {
                            self.pev.targetname = Triggers.pev.target;
                        }
                    }
                    else
                    {
                        // Not sure if this is enough time to show messages in trigger_teleport at the proper time. anyways no one uses those triggers.
                        // Also don't use effects like chat message or subtitles, it'll decrease your frames since those triggers doesn't have a cooldown like trigger_multiple does
                        SetThink( ThinkFunction( this.TriggerThink ) );
                        self.pev.nextthink = g_Engine.time + 0.1f;
                    }

                    Triggers.pev.message = "";
                }
            }
        }
        else
        {
            /*CBaseEntity@ pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, self.pev.targetname );

            if( pGameText.pev.classname == "game_text" || pGameText.pev.classname == "env_message" )
            {
                g_EntityFuncs.Remove( pGameText );
            }*/
        }

        BaseClass.Spawn();
    }

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        MLANKeyValues(szKey, szValue);

        if(szKey == "channel")
        {
            TextParams.channel = atoi(szValue);
        }
        else if(szKey == "x")
        {
            TextParams.x = atof(szValue);
        }
        else if(szKey == "y")
        {
            TextParams.y = atof(szValue);
        }
        else if(szKey == "effect")
        {
            TextParams.effect = atoi(szValue);
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
            TextParams.fadeinTime = atof(szValue);
        }
        else if(szKey == "fadeout")
        {
            TextParams.fadeoutTime = atof(szValue);
        }
        else if(szKey == "holdtime")
        {
            TextParams.holdTime = atof(szValue);
        }
        else if(szKey == "fxtime")
        {
            TextParams.fxTime = atof(szValue);
        }
        else if( szKey == "killtarget" )
        {
            killtarget = szValue;
        }
        else if( szKey == "messagesound" )
        {
            messagesound = szValue;
        }
        else if( szKey == "messagevolume" )
        {
            messagevolume = atof(szValue);
        }
        else if ( szKey == "master" )
        {
            this.m_iszMaster = szValue;
            return true;
        }
        else 
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
        return true;
    }

    void TriggerThink() 
    {
        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( plr is null || !plr.IsConnected() || !plr.IsAlive() ) { continue; }

            if( UTILS::InsideZone( plr, self ) )
            {
                CallText( plr );
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pActivator !is null )
        {
            CallText( pActivator );
        }
    }

    void CallText( CBaseEntity@ pActivator )
    {
        if( !m_iszMaster.IsEmpty() && !g_EntityFuncs.IsMasterTriggered( m_iszMaster, @pActivator ) )
        {
            return;
        }

        string strMonster = string( pActivator.pev.classname ).Replace( "monster_", "" );

        self.pev.netname = ( pActivator.IsMonster() ) ? string( strMonster ).Replace( "_", " " ) : ( pActivator.IsPlayer() ) ? string( pActivator.pev.netname ) : "Worldspawn" ;

        // All players flag
        if ( self.pev.SpawnFlagBitSet( 1 ) )
        {
            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( plr !is null )
                {
                    if( pActivator !is null && pActivator.IsPlayer() ) self.pev.netname = pActivator.pev.netname;

                    ShowText( plr );
                }
            }
        }
        else if( pActivator !is null && pActivator.IsPlayer() )
        {
            ShowText( cast<CBasePlayer@>(pActivator) );
        }

        // Game text legacy -
        if( killtarget != "" )
        {
            UTILS::TriggerMode( string( self.pev.target ) + "#2", null );
        }
    }

    void ShowText( CBasePlayer@ plr )
    {
        string ReadLanguage = UTILS::Replace( ReadLanguages( UTILS::GetCKV( plr, "$f_lenguage" ) ),
        {
            { "!frags", ""+int( self.pev.frags ) },
            { "!activator", string( self.pev.netname ) }
        } );

        // No echo console flag
        if( !self.pev.SpawnFlagBitSet( 2 ) )
        {
            g_PlayerFuncs.ClientPrint( plr, HUD_PRINTCONSOLE, ReadLanguage+"\n" );
        }

        // env_message legacy
        if( messagesound != "" )
        {
            g_SoundSystem.PlaySound( plr.edict(), CHAN_AUTO, messagesound, messagevolume/10, ATTN_NORM, 0, PITCH_NORM, plr.entindex(), true, plr.GetOrigin() );
        }

        // Game text legacy - with addition of multi_manager feature for TriggerState
        UTILS::TriggerMode( self.pev.target, plr );

        // trigger_once/multiple-like messages
        if( TextParams.effect == 3 )
        {
            g_PlayerFuncs.ShowMessage( plr, ""+ReadLanguage+"\n" );
        }
        // Motd message
        else if( TextParams.effect == 4 )
        {
            UTILS::ShowMOTD( plr, string( "motd" ), ReadLanguage+"\n" );
        }
        // Chat message
        else if( TextParams.effect == 5 )
        {
            g_PlayerFuncs.ClientPrint( plr, HUD_PRINTTALK, ""+ReadLanguage+"\n" );
        }
        // Subtitle -TODO
        else if( TextParams.effect == 6 )
        {
            g_PlayerFuncs.ClientPrint( plr, HUD_PRINTTALK, ""+ReadLanguage+"\n (Subtitle effect not implemented yet)\n" );
        }
        // Prints the key binded "use +alt1 to attack" -> "use [MOUSE3] to attack"
        else if( TextParams.effect == 7 )
        {
            g_PlayerFuncs.PrintKeyBindingString( plr, ""+ReadLanguage+"\n"  );
        }
        // Game text default effects
        else
        {
            g_PlayerFuncs.HudMessage( plr, TextParams, ReadLanguage+"\n" );
        }
    }
}