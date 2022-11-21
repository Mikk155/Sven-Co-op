/*
INSTALL:

    "plugin"
    {
        "name" "AfkManager"
        "script" "mikk/AfkManager"
    }
*/

// Maximun time players can be afk before joining spectator mode (seconds)
const int AFKMaxTime = 300; // 5 minutes

#include "../../maps/mikk/utils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk: https://github.com/Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "Discord: https://discord.gg/VsNnE3A7j8 \n" );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @AfkSay );
}

bool ExcludedMapList()
{
    // This feature COMPLETELLY Disables the plugin. if the map has a cinematic use the alternative method i've did ctrl+f "-Entity"
    string szExcludedMapList = "scripts/plugins/mikk/AfkManager/MapBlackList.txt";
    File@ pFile = g_FileSystem.OpenFile( szExcludedMapList, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() )
        return false;

    string strMap = g_Engine.mapname;
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

        if( line.EndsWith("*", String::CaseInsensitive) )
        {
            line = line.SubString(0, line.Length()-1);

            if( strMap.Find(line) != Math.SIZE_MAX )
            {
                pFile.Close();
                return true;
            }
        }
    }

    pFile.Close();

    return false;
}

CScheduledFunction@ g_pThink = null;

void MapInit()
{
    if( ExcludedMapList() )
        return;

    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseAfkManagerZone", "afkmanager_zone" );

    g_Scheduler.RemoveTimer( g_pThink );
    @g_pThink = null;

    @g_pThink = g_Scheduler.SetInterval( "AFKThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    
    // Creates the entity that prevent players from getting the afk's keyvalue. -Entity
    UTILS::LoadRipentFile( "scripts/plugins/mikk/AfkManager/" + string( g_Engine.mapname ) + ".ent" );
}

void MapStart()
{
	array<string> ListOfPlugins = g_PluginManager.GetPluginList();

    if( ListOfPlugins.find( "multi_language" ) >= 0)
    {
        g_EngineFuncs.ServerPrint("\n Multi language plugin FOUND. Generating text entities..\n");

        // Create the text that this plugin uses to tell messages.
        UTILS::LoadRipentFile( "scripts/plugins/mikk/AfkManager/PluginMessages.ent" );
    }
    else
    {
        g_EngineFuncs.ServerPrint("\nWARNING! Could not find multi_language plugin. No text entities initialized.\n");
        g_EngineFuncs.ServerPrint("Make sure you add the plugin to default_plugins.txt!\n\n");
    }
}

/*
A entity that you must define a zone with the use of hullsizes. if the player is inside of it then do not count him as a AFK
You can enable flag 1 (start off) to toggle it via trigger. supports UseTypes.
or you can lock it by its master key if you prefeer.

"minhullsize" "min size"
"maxhullsize" "max size"
"master" "multisource"
"targetname" "name"
"spawnflags" "0/1"
"classname" "afkmanager_zone"
"model" "alternative set size by a brush model"
*/

class CBaseAfkManagerZone : ScriptBaseEntity, UTILS::MoreKeyValues
{
    private bool Toggle    = true;

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        ExtraKeyValues(szKey, szValue);

        return true;
    }
    
    void Spawn() 
    {
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
        self.pev.effects    |= EF_NODRAW;

        UTILS::SetSize( self, false );

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            Toggle = false;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;
        
        BaseClass.Spawn();
    }
    
    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        switch(useType)
        {
            case USE_ON:
                Toggle = true;
            break;

            case USE_OFF:
                Toggle = false;
            break;

            default:
                Toggle = !Toggle;
            break;
        }
    }

    void TriggerThink() 
    {
        if( !Toggle || multisource() )
        {
            self.pev.nextthink = g_Engine.time + 0.2f;
            return;
        }

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            if( UTILS::InsideZone( pPlayer, self ) )
                pPlayer.GetCustomKeyvalues().SetKeyvalue("$i_afktimer", 0 );
        }
        self.pev.nextthink = g_Engine.time + 0.2f;
    }
}

dictionary dictSteamsID;

void AFKThink()
{
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if( pPlayer is null )
            continue;

        string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

        // player is in AFK mode
        if( dictSteamsID.exists(SteamID) )
        {
            // If server full disconnect the player
            if( g_PlayerFuncs.GetNumPlayers() == g_Engine.maxClients )
            {
                UTILS::TriggerMode( "AFK_KICK_MODE", pPlayer, 0.5f );

                NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
                    msg.WriteString( "disconnect" );
                msg.End();
            }
            // If player is in spec mode tell how to leave afk mode
            else if( pPlayer.GetObserver().IsObserver() )
            {
                UTILS::TriggerMode( "AFK_EXIT_MODE", pPlayer, 0.5f );
                pPlayer.pev.nextthink = ( g_Engine.time + 2.0 );
            }
            // Move to spectator mode
            else
            {
                pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
            }
        }
		
        int iafktimer = UTILS::GetCKV( pPlayer, "$i_afktimer" );

        if( pPlayer.IsAlive() && !pPlayer.IsMoving() )
        {
            pPlayer.GetCustomKeyvalues().SetKeyvalue("$i_afktimer", iafktimer - 1 );

            if( iafktimer == 1 && !pPlayer.GetObserver().IsObserver() )
            {
                dictSteamsID[SteamID] = @pPlayer;
                UTILS::TriggerMode( "AFK_ENTER_MODE", pPlayer, 0.5f );
            }
        }

        if( pPlayer.IsMoving() || iafktimer <= 0 )
        {
            pPlayer.GetCustomKeyvalues().SetKeyvalue("$i_afktimer", AFKMaxTime );
        }

        if( iafktimer < 11 && iafktimer >= 1 )
        {
            UTILS::TriggerMode( "AFK_GOING_MODE", pPlayer, 0.5f );
        }
    }
}

HookReturnCode AfkSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();

    if( args.Arg(0) == "/afk" || args.Arg(0) == "!afk" )
	{
		if( ExcludedMapList() )
        	UTILS::TriggerMode( "AFK_TELL_DISABLED", pPlayer, 0.5f );
		else
        	ToggleAfk( pPlayer );
	}

    if( args.Arg(0) == "afk" or args.Arg(0) == "brb" )
	{
		if( ExcludedMapList() )
        	UTILS::TriggerMode( "AFK_TELL_DISABLED", pPlayer, 0.5f );
		else
        	UTILS::TriggerMode( "AFK_TELL_MODE", pPlayer, 0.5f );
	}

    return HOOK_CONTINUE;
}

void ToggleAfk( CBasePlayer@ pPlayer )
{
    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

    if( dictSteamsID.exists(SteamID) )
    {
        dictSteamsID.delete(SteamID);
        UTILS::TriggerMode( "AFK_LEFT_MODE", pPlayer, 0.5f );
    }
    else
    {
        dictSteamsID[SteamID] = @pPlayer;
        UTILS::TriggerMode( "AFK_ENTER_MODE", pPlayer, 0.5f );
    }
}