/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

#include "../mikk155/meta_api"
#include "../mikk155/meta_api/json"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();

    g_Hooks.RegisterHook( Hooks::Game::MapChange, MapChangeHook( function( const string& in nextmap )
    {
        if( string( g_Engine.mapname ) == nextmap )
        {
            mapRestarts++;
        }
        else
        {
            date = DateTime();
        }

        Shutdown();

        return HOOK_CONTINUE;
    } ) );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, ClientSayHook( function( SayParameters@ params )
    {
        if( g_NextClientDisplay > g_Engine.time )
            return HOOK_CONTINUE;

        if( params.GetArguments().Arg(0) != '/time' )
            return HOOK_CONTINUE;

        ShowTime();

        g_NextClientDisplay = g_Engine.time + 10.0f;

        return HOOK_CONTINUE;
    } ) );

    MapActivate();
}

DateTime date;
int mapRestarts = 0;
CScheduledFunction@ fnThink;
float g_MessageSchedule = 60;
float g_NextClientDisplay;
bool g_ShouldReloadJson = true;
array<string> g_Messages;

void Shutdown()
{
    if( fnThink !is null )
    {
        g_Scheduler.RemoveTimer( fnThink );
        @fnThink = null;
    }
}

void PluginExit()
{
    Shutdown();
}

void ShowTime()
{
    TimeDifference difference = DateTime() - date;
    difference.MakeAbsolute();

    int days = difference.GetDays();
    int hours = difference.GetHours() % 24;
    int minutes = difference.GetMinutes() % 60;
    int seconds = difference.GetSeconds() % 60;

    string time = g_Messages[0] + " ";

    if( days > 0 ) { snprintf( time, "%1%2 %3 ", time, days, ( days > 1 ? g_Messages[2] : g_Messages[1] ) ); }
    if( hours > 0 ) { snprintf( time, "%1%2 %3 ", time, hours, ( hours > 1 ? g_Messages[4] : g_Messages[3] ) ); }
    if( minutes > 0 ) { snprintf( time, "%1%2 %3 ", time, minutes, ( minutes > 1 ? g_Messages[6] : g_Messages[5] ) ); }
    if( seconds > 0 ) { snprintf( time, "%1%2 %3 ", time, seconds, ( seconds > 1 ? g_Messages[8] : g_Messages[7] ) ); }

    if( mapRestarts > 0 ) { snprintf( time, ( mapRestarts > 1 ? g_Messages[10] : g_Messages[9] ), time, mapRestarts ); }

    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, time + "\n" );
}

void MapActivate()
{
    if( g_ShouldReloadJson )
    {
        dictionary data;
        if( meta_api::json::Deserialize( "ShowPlayTime.json", data ) )
        {
            g_Messages = meta_api::json::ToArray( data[ "message" ] );
            g_ShouldReloadJson = bool( data[ "reload" ] );
            data.get( "client_cooldown", g_NextClientDisplay );
            data.get( "message_schedule", g_MessageSchedule );
        }
    }

    @fnThink = g_Scheduler.SetInterval( "ShowTime", g_MessageSchedule, g_Scheduler.REPEAT_INFINITE_TIMES );
}
