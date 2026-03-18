#include "../mikk155/Server/Framerate"

dictionary g_Players = {};
Server::Framerate::FrameRateCallback@ cb = null;

int g_AvgAccumulator = 0;
int g_AvgSamples = 0;
int g_LastAverage = 0;

auto cmd = CClientCommand( "framerate", "Display frame rate information", function( const CCommand@ args )
{
    auto player = g_ConCommandSystem.GetCurrentPlayer();

    if( player !is null )
    {
        string id = g_EngineFuncs.GetPlayerUserId(player.edict());
        if( g_Players.exists( id ) )
            g_Players.delete( id );
        else
            g_Players[ id ] = true;
        
        if( cb is null )
        {
            @cb = Server::Framerate::SetCallback( function( const ServerFramerate@ data )
            {
                if( data.LastFrame )
                {
                    g_AvgAccumulator += data.Frames;
                    g_AvgSamples++;

                    if( g_AvgSamples >= 10 )
                    {
                        g_LastAverage = g_AvgAccumulator / g_AvgSamples;
                        g_AvgAccumulator = 0;
                        g_AvgSamples = 0;
                    }
                }

                HUDTextParams params;
                params.holdTime = 1.0f;
                params.fadeinTime = 0.0f;
                params.r1 = 255;
                params.g1 = params.b1 = 0;
                params.y = 0.3;
                params.x = 0.0;

                if( g_Players.getSize() <= 0 )
                {
                    Server::Framerate::RemoveCallback( cb );
                    @cb = null;
                }

                string buffer;
                snprintf( buffer, "second: %1\nframes last second: %2\nframes this second: %3\nCurrent framerate: %4\nAverage framerate: %5\n",
                    int(g_Engine.time), data.Frames, data.Count, data.Current, g_LastAverage );

                bool Any = false;

                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    auto player = g_PlayerFuncs.FindPlayerByIndex(i);

                    if( player !is null )
                    {
                        Any = true;
                        g_PlayerFuncs.HudMessage( player, params, buffer );
                    }
                }

                if( !Any )
                    g_Players.deleteAll();
            } );
        }

    }
}, ConCommandFlag::None );

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
}
