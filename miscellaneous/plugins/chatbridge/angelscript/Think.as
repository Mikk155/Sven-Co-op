namespace Think
{
    CThink g_Think;

    class CThink
    {
        CScheduledFunction@ pThink = null;

        int flReadDelay = 0;
        int flStatusDelay = 0;

        void GlobalThink()
        {
            if( flReadDelay >= atoi( pJson.get( "INTERVAL_ANGESCRIPT:BOT" ) ) )
            {
                discord_from_server::Write();
                discord_to_server::Read();
                flReadDelay = 0;
            }
            else
            {
                flReadDelay++;
            }

            if( flStatusDelay >= atoi( pJson.get( "INTERVAL_STATUS:BOT" ) ) )
            {
                discord_to_status::Write();
                flStatusDelay = 0;
            }
            else
            {
                flStatusDelay++;
            }

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

            discord_to_server::PrintMessage();
        }
    }

    void PluginInit()
    {
        if( g_Think.pThink !is null )
        {
            g_Scheduler.RemoveTimer( g_Think.pThink );
        }

        @g_Think.pThink = g_Scheduler.SetInterval( @g_Think, "GlobalThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    }
}