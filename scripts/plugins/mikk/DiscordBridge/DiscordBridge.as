//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../../mikk/shared"
#include "method/fileload"
#include "metamod/main"
#include "AngelScript/PlayerKilled"
#include "AngelScript/SurvivalEndRound"
#include "AngelScript/SurvivalStartRound"
#include "AngelScript/PlayerConnect"
#include "AngelScript/ClientDisconnect"
#include "AngelScript/PlayerSpawn"
#include "AngelScript/PlayersConnected"
#include "AngelScript/FormatMessage"
#include "AngelScript/GetPlayers"
#include "AngelScript/ClientSay"
#include "AngelScript/GetEmote"
#include "AngelScript/gamestatus"

json pJson;
string language;

CScheduledFunction@ pTimer;

array<string> m_szBuffer;
array<string> m_szCommandBuffer;

const string TO_DISCORD = '<';
const string TO_SERVER  = '>';
const string TO_COMMAND = '-';
const string TO_STATUS  = '=';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    pJson.load( 'plugins/mikk/DiscordBridge/DiscordBridge.json' );

    if( g_Reflection[ 'fileload::PluginInit' ] !is null )
        g_Reflection[ 'fileload::PluginInit' ].Call();

    RegisterAll();

    Mikk.UpdateTimer( pTimer, 'Think', 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void MapInit()
{
    if( pJson.reload( 'plugins/mikk/DiscordBridge.json' ) == 0 )
    {
        RegisterAll();
    }
}

void MapStart()
{
    if( g_Reflection[ 'SurvivalStartRound::MapStart' ] !is null )
        g_Reflection[ 'SurvivalStartRound::MapStart' ].Call();
    if( g_Reflection[ 'PlayersConnected::MapStart' ] !is null )
        g_Reflection[ 'PlayersConnected::MapStart' ].Call();
    if( g_Reflection[ 'MapStarted::MapStart' ] !is null )
        g_Reflection[ 'MapStarted::MapStart' ].Call();
}

void MapActivate()
{
    Mikk.UpdateTimer( pTimer, 'Think', 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void RegisterAll()
{
    language = pJson[ 'language', 'english' ];

    if( g_Reflection[ 'HASMETAMOD::RegisterAll' ] !is null )
        g_Reflection[ 'HASMETAMOD::RegisterAll' ].Call();
    if( g_Reflection[ 'PlayerKilled::Register' ] !is null )
        g_Reflection[ 'PlayerKilled::Register' ].Call();
    if( g_Reflection[ 'PlayerConnect::Register' ] !is null )
        g_Reflection[ 'PlayerConnect::Register' ].Call();
    if( g_Reflection[ 'ClientDisconnect::Register' ] !is null )
        g_Reflection[ 'ClientDisconnect::Register' ].Call();
    if( g_Reflection[ 'SurvivalEndRound::Register' ] !is null )
        g_Reflection[ 'SurvivalEndRound::Register' ].Call();
    if( g_Reflection[ 'PlayerSpawn::Register' ] !is null )
        g_Reflection[ 'ClientSay::Register' ].Call();
}

float flfileloadNextThink;
float flCreateJsonNextThink;

void Think()
{
    if( int( pJson[ 'status', {} ][ 'channel' ] ) > 0 && g_Engine.time > flCreateJsonNextThink )
    {
        if( g_Reflection[ 'gamestatus::CreateJson' ] !is null )
            g_Reflection[ 'gamestatus::CreateJson' ].Call();

        flCreateJsonNextThink = g_Engine.time + float( pJson[ 'interval' ] );
    }

    if( string( pJson[ 'method' ] ) == 'fileload' && g_Engine.time > flfileloadNextThink )
    {
        if( g_Reflection[ 'fileload::ThinkForFileLoad' ] !is null )
            g_Reflection[ 'fileload::ThinkForFileLoad' ].Call();

        flfileloadNextThink = g_Engine.time + float( pJson[ 'interval' ] );
    }

    for( int i = 0; m_szBuffer.length() > 0 && i < int( pJson[ 'messages per second' ] ); i++ )
    {
        string MSG = string( pJson[ 'MESSAGES', {} ][ 'FromDiscordTag' ] ) + m_szBuffer[0];
        m_szBuffer.removeAt(0);
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, MSG + '\n' );
    }

    for( int i = 0; m_szCommandBuffer.length() > 0 && i < int( pJson[ 'messages per second' ] ); i++ )
    {
        array<string> pArgs = m_szCommandBuffer[0].Split( ' ' );
        m_szCommandBuffer.removeAt(0);
        if( pArgs.length() > 0 )
        {
            string Command = pArgs[0];
            string Args = ( pArgs.length() > 1 ? ' "' : '' );
            for( uint ui = 1; ui < pArgs.length(); ui++ ){
                Args += ( ui == 1 ? '' : ' ' ) + pArgs[ui]; }
            Args += ( pArgs.length() > 1 ? '"' : '' );
            string FullCommand = Command + Args;
            FullCommand = FullCommand.Replace( '\\n', '' );
            g_EngineFuncs.ServerCommand( FullCommand + '\n');
            g_EngineFuncs.ServerExecute();
        }
    }
}
