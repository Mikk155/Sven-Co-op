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

#include "chatbridge/extern"

json pJson;
json JsonLog;
json JsonEmotes;
json JsonLang;
json JsonBadWords;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Reflection.Call( 'PluginInit' );
    LoadJson();
    g_Chatbridge.PluginInit();
}

void MapInit()
{
    if( pJson[ 'json reload periodically', false ] )
        LoadJson();

    g_Reflection.Call( 'MapInit' );
}

void LoadJson()
{
    pJson.load('plugins/mikk/chatbridge/chatbridge.json');

    if( pJson.keysize <= 0 )
    {
        g_Game.AlertMessage( at_error, "WARNING! Can not open chatbridge.json! Shutting down plugin...\n" );
        array<int>i(0);i[i.length()];
    }

    JsonLog = pJson[ 'LOG', {} ];
    JsonEmotes = pJson[ 'emotes', {} ];
    JsonLang = pJson[ pJson[ 'language', 'english' ], {} ];
    JsonBadWords = pJson[ 'bad words', {} ];
}

HookReturnCode MapChange()
{
    g_Chatbridge.restarts++;
    return HOOK_CONTINUE;
}

void MapStart()
{
    g_Reflection.Call( 'MapStart' );
    g_Chatbridge.mapname = g_Engine.mapname;
}

void MapActivate()
{
    g_Reflection.Call( 'MapActivate' );
}

ChatBridge g_Chatbridge;

final class ChatBridge
{
    CServer Server;
    CDiscord Discord;

    string mapname;
    int seconds;
    int minutes;
    int hours;
    int days;
    int restarts;

    ChatBridge()
    {
        Server = CServer();
        Discord = CDiscord();
    }

    void PluginInit()
    {
        seconds = minutes = hours = days = restarts = 0;

        if( this.CThink !is null )
        {
            g_Scheduler.RemoveTimer( this.CThink );
        }

        @this.CThink = g_Scheduler.SetInterval( @this, "Think", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );

        g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    }

    CScheduledFunction@ CThink = null;

    void Think()
    {
        if( Discord.flNextThink < g_Engine.time )
        {
            if( Discord.pFile() !is null )
            {
                Discord.Think();
            }
            Discord.flNextThink = g_Engine.time + Discord.flThink;
        }
        Discord.flNextThink -= 1.0;


        if( Server.flNextThink < g_Engine.time )
        {
            if( Server.pFile() !is null )
            {
                Server.Think();
            }
            Server.flNextThink = g_Engine.time + Server.flThink;
        }
        Server.flNextThink -= 1.0;


        if( Server.flNextThinkWrite < g_Engine.time )
        {
            if( Server.m_szBuffer.length() >= 1 )
            {
                Server.print();
            }
            Server.flNextThinkWrite = g_Engine.time + Server.flThinkWrite;
        }
        Server.flNextThinkWrite -= 1.0;

        seconds++;
        if( seconds > 59 )
        {
            minutes++;
            seconds = 0;
        }
        if( minutes > 59 )
        {
            hours++;
            minutes = 0;
        }
        if( hours > 23 )
        {
            days++;
            hours = 0;
        }
    }

    void GetPlayers( int &out AllPlayers, int &out AlivePlayers = 0)
    {
        int z=0,x=0;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

            if( pPlayer !is null )
            {
                z++;

                if( pPlayer.IsAlive() )
                    x++;
            }
        }
        AllPlayers = z;
        AlivePlayers = x;
    }
}