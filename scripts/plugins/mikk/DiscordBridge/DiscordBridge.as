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

json pJson;
string language;

CScheduledFunction@ pTimer;

array<string> m_szBuffer;

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
        g_Reflection[ 'PlayerSpawn::Register' ].Call();
}

float flfileloadNextThink;

void Think()
{
    if( string( pJson[ 'method' ] ) == 'fileload' && g_Engine.time > flfileloadNextThink )
    {
        if( g_Reflection[ 'fileload::ThinkForFileLoad' ] !is null )
            g_Reflection[ 'fileload::ThinkForFileLoad' ].Call();
        flfileloadNextThink = g_Engine.time + float( pJson[ 'interval' ] );
    }

    for( int i = 0; m_szBuffer.length() > 0 && i < int( pJson[ 'messages per second' ] ); i++ )
    {
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, m_szBuffer[0] + '\n' );
        m_szBuffer.removeAt(0);
    }
}
