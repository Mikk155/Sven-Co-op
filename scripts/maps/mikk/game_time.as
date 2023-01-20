namespace game_time
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_time::game_time", "game_time" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_time\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mappers to make use of real time and custom time. create maps with timers n/or timelapse day/night etc etc..\n"
        );
    }

    const string[][] Pattern = 
    {
        { "1", "Best pattern for this hour" },
        { "2", "Best pattern for this hour" },
        { "3", "Best pattern for this hour" },
        { "4", "Best pattern for this hour" },
        { "5", "Best pattern for this hour" },
        { "6", "Best pattern for this hour" },
        { "7", "Best pattern for this hour" },
        { "8", "Best pattern for this hour" },
        { "9", "Best pattern for this hour" },
        { "10", "Best pattern for this hour" },
        { "11", "Best pattern for this hour" },
        { "12", "Best pattern for this hour" },
        { "13", "Best pattern for this hour" },
        { "14", "Best pattern for this hour" },
        { "15", "Best pattern for this hour" },
        { "16", "Best pattern for this hour" },
        { "17", "Best pattern for this hour" },
        { "18", "Best pattern for this hour" },
        { "19", "Best pattern for this hour" },
        { "21", "Best pattern for this hour" },
        { "22", "Best pattern for this hour" },
        { "23", "Best pattern for this hour" },
        { "0", "Best pattern for this hour" },
    };

    enum game_time_flags
    {
        SF_TIME_ONDEMAND = 1 << 0,
        SF_TIME_GETREALTIME = 1 << 1
    }

    class game_time : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        DateTime datetime;
        private int TimerS = 0, TimerM = 0, TimerH = 0, TimerD = 0;
        private int CuantosSegundosDuraUnMinuto = 59, CuantosMinutosDuraUnaHora = 59, CuantasHorasDuraUnDia = 23;
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "TimerM" ) TimerM = atoi( szValue );
            else if( szKey == "TimerH" ) TimerH = atoi( szValue );
            else if( szKey == "TimerD" ) TimerD = atoi( szValue );
            ExtraKeyValues(szKey, szValue);
            return true;
        }
        
        void Spawn()
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 1.0f;
        
            CuantosSegundosDuraUnMinuto = int(self.pev.health);

            if( self.pev.SpawnFlagBitSet( SF_TIME_GETREALTIME ) )
            {
                TimerH = int( datetime.GetHour() );
                TimerM = int( datetime.GetMinutes() );
            }

            BaseClass.Spawn();
        }

        void TriggerThink()
        {
            if( master() )
            {
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            g_Util.DebugMessage("The time is "+TimerD+" days. "+TimerH+" hours. "+TimerM+" minutes.\n");

            if( self.pev.SpawnFlagBitSet( SF_TIME_ONDEMAND ) )
            {
                CuantosSegundosDuraUnMinuto = int(self.pev.health);
            }

            // Increase one minute
            if( TimerS >= CuantosSegundosDuraUnMinuto )
            {
                ++TimerM; TimerS = 0;

                // Trigger every minute is increased
                g_EntityFuncs.FireTargets( "MINUTE_"+TimerM+"", self, self, USE_TOGGLE );
                g_Util.DebugMessage("Triggered entity 'MINUTE_"+TimerM+"'\n");
            }

            // Increase one hour
            if( TimerM >= CuantosMinutosDuraUnaHora )
            {
                ++TimerH; TimerM = 0;

                // Trigger every hour is increased
                g_EntityFuncs.FireTargets( "HOUR_"+TimerH+"", self, self, USE_TOGGLE );
                g_Util.DebugMessage("Triggered entity 'HOUR_"+TimerH+"'\n");

               for( uint ui = 0; ui < Pattern.length(); ui++ )
                {
                    // Change pattern every hour is increased
                    if( atoi( Pattern[ui][0] ) == TimerH )
                    {
                        CBaseEntity@ pGlobalLight = g_EntityFuncs.FindEntityByTargetname( pGlobalLight, "global_light" );
                        if( pGlobalLight is null ) return;
                        g_EntityFuncs.DispatchKeyValue( pGlobalLight.edict(), "pattern", Pattern[ui][1] );
                        g_EntityFuncs.FireTargets( "global_light", self, self, USE_ON );
                        g_Util.DebugMessage("Light Pattern has been updated to "+ Pattern[ui][1] +"\n");
                        break;
                    }
                }
            }

            // Increase one day
            if( TimerH >= CuantasHorasDuraUnDia )
            {
                TimerS = TimerM = TimerH = 0;

                // Trigger every day is increased
                g_EntityFuncs.FireTargets( "DAY_"+TimerD+"", self, self, USE_TOGGLE );
                g_Util.DebugMessage("Triggered entity 'DAY_"+TimerD+"'\n");
            }

            // Increase one second
            ++TimerS;

            self.pev.nextthink = g_Engine.time + 1.0f;
        }
    }
}// end namespace