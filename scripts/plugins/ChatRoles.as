#include "../mikk155/meta_api/json"
#include "../mikk155/Player/GetUniqueID"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    MapActivate();
}

bool g_AllowColors;
ClientSayHook@ fnClientSay = ClientSayHook( ClientSay );
dictionary g_UserData;

void MapActivate()
{
    g_Hooks.RemoveHook( Hooks::Player::ClientSay, @fnClientSay );

    dictionary data;
    meta_api::json::Deserialize( "scripts/plugins/ChatRoles.json", data );

    if( meta_api::json::IsMapListed( data ) )
    {
        g_Game.AlertMessage( at_console, "Chat-Roles disabled for this map.\n" );
        return;
    }

    dictionary userdata;

    if( !data.get( "userdata", userdata ) )
        return;

    auto authIDs = userdata.getKeys();

    if( authIDs.length() <= 0 )
        return;

    for( uint ui = 0; ui < authIDs.length(); ui++ )
    {
        string authID = authIDs[ui];

        dictionary newData;
        userdata.get( authID, newData );

        string color; // Convert to integer to use less bytes
        if( newData.get( "color", color ) )
        {
            if( color == "red" ) {
                newData[ "color" ] = 17;
            }
            else if( color == "green" ) {
                newData[ "color" ] = 19;
            }
            else if( color == "blue" ) {
                newData[ "color" ] = 16;
            }
            else if( color == "yellow" ) {
                newData[ "color" ] = 18;
            }
            else {
                g_Game.AlertMessage( at_console, "[ChatRoles] Parsed an invalid color name \"%1\"\n", color );
            }
        }

        dictionary curData;
        if( g_UserData.get( authID, curData ) )
        {
            newData[ "hide" ] = bool( curData[ "hide" ] );
        }

        g_UserData[ authID ] = newData;
    }

    g_AllowColors = ( g_PluginManager.GetPluginList().find( "ChatColors" ) <= 0 );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @fnClientSay );
}

CClientCommand g_CommandHandler( "chatroles", "ChatRoles", @ClientCommand );

void ClientCommand( const CCommand@ args )
{
    auto player = g_ConCommandSystem.GetCurrentPlayer();

    if( args.ArgC() == 1 )
    {
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "--- Chat Roles ---\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, ".chatroles hide\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "- Hide your roles from chat\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, ".chatroles show\n" );
        g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "- Show your roles on chat\n" );
        return;
    }
    else if( args.ArgC() == 2 )
    {
        string arg = args[1];

        if( arg == "hide" || arg == "show" )
        {
            string authID = Player::GetUniqueID( player );

            dictionary userdata;

            if( g_UserData.get( authID, userdata ) )
            {
                userdata[ "hide" ] = ( arg == "hide" );
                g_UserData[ authID ] = userdata;
            }
            else
            {
                g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "You don't appear to be part of the plugin config.\n" );
            }
        }
    }
}

void RestoreColor( EHandle hplayer )
{
    if( hplayer.IsValid() )
    {
        auto player = cast<CBasePlayer@>( hplayer.GetEntity() );

        if( player !is null && player.IsConnected() )
        {
            player.SendScoreInfo();
        }
    }
}

HookReturnCode ClientSay( SayParameters@ params )
{
    if( params.ShouldHide )
        return HOOK_CONTINUE;

    CBasePlayer@ player = params.GetPlayer();

    if( player is null )
        return HOOK_CONTINUE;

    dictionary userdata;

    if( !g_UserData.get( Player::GetUniqueID( player ), userdata ) )
        return HOOK_CONTINUE;

    if( bool( userdata[ "hide" ] ) )
        return HOOK_CONTINUE;

    const CCommand@ args = params.GetArguments();

    string sentence = args.GetCommandString();

    if( sentence.IsEmpty() )
        return HOOK_CONTINUE;

    string message;

    string role;
    if( userdata.get( "role", role ) && !role.IsEmpty() )
    {
        snprintf( message, "[%1] %2: %3\n", role, string( player.pev.netname ), sentence );
    }
    else
    {
        snprintf( message, "%2: %3\n", string( player.pev.netname ), sentence );
    }

    bool HasColor;
    int oldClassify = -1;

    if( g_AllowColors )
    {
        oldClassify = player.Classify();

        // False if this is a team-play based map.
        if( oldClassify < 16 || oldClassify > 19 )
        {
            int color;
            if( userdata.get( "color", color ) )
            {
                player.SetClassification( color );
                player.SendScoreInfo();
                HasColor = true;
            }
        }
    }

    if( !HasColor && role.IsEmpty() )
        return HOOK_CONTINUE;

    // -TODO Add the NetworkMessages header after it leaves the WIP-box
    NetworkMessage msg( MSG_ALL, NetworkMessages::NetworkMessageType(74) );
        msg.WriteByte( player.entindex() );
        msg.WriteByte( 2 );
        msg.WriteString( message );
    msg.End();

    if( oldClassify != -1 )
    {
        player.SetClassification( oldClassify );
        g_Scheduler.SetTimeout( "RestoreColor", 0.1f, EHandle( player ) );
    }

    params.ShouldHide = true;

    return HOOK_CONTINUE;
}
