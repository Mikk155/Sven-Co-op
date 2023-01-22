namespace game_time
{
    bool blDebugHour = false;

    void Register( const bool& in DebugHour = false )
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_time::game_time", "game_time" );

        blDebugHour = DebugHour;

        g_Util.ScriptAuthor.insertLast
        (
            "Script: game_time\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mappers to make use of real time and custom time. create maps with timers n/or timelapse day/night fire entities depending the time etc.\n"
        );
    }

    const string[][] Pattern = 
    {
        { "1", "Best pattern for this current_hour" },
        { "2", "Best pattern for this current_hour" },
        { "3", "Best pattern for this current_hour" },
        { "4", "Best pattern for this current_hour" },
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
        SF_TIME_GETREALTIME = 1 << 0
    }

    class game_time : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        DateTime datetime;

        private int
        current_second = 0,
        current_minute = 0,
        current_hour = 0,
        current_day = 0;

        private int
        CuantosSegundosDuraUnMinuto = 59,
        CuantosMinutosDuraUnaHora = 59,
        CuantasHorasDuraUnDia = 23;

        private string
        trigger_second,
        trigger_minute,
        trigger_hour,
        trigger_day,
        light_pattern;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "current_second" ) current_second = atoi( szValue );
            else if( szKey == "trigger_second" ) trigger_second = szValue;
            else if( szKey == "current_minute" ) current_minute = atoi( szValue );
            else if( szKey == "trigger_minute" ) trigger_minute = szValue;
            else if( szKey == "current_hour" ) current_hour = atoi( szValue );
            else if( szKey == "trigger_hour" ) trigger_hour = szValue;
            else if( szKey == "current_day" ) current_day = atoi( szValue );
            else if( szKey == "trigger_day" ) trigger_day = szValue;
            else if( szKey == "light_pattern" ) trigger_day = szValue;
            return true;
        }
        
        void Spawn()
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 1.0f;
        
            CuantosSegundosDuraUnMinuto = int(self.pev.health);

            if( self.pev.SpawnFlagBitSet( SF_TIME_GETREALTIME ) )
            {
                current_hour = int( datetime.GetHour() );
                current_minute = int( datetime.GetMinutes() );
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

            if( blDebugHour )
            {
                g_Util.DebugMessage("The time is "+current_day+" days. "+current_hour+" hours. "+current_minute+" minutes.\n");
            }

            if( CuantosSegundosDuraUnMinuto != int( self.pev.health ) )
            {
                CuantosSegundosDuraUnMinuto = int(self.pev.health);
            }

            g_Util.Trigger( trigger_second, self, self, USE_TOGGLE, 0.0f );

            if( current_second >= CuantosSegundosDuraUnMinuto )
            {
                ++current_minute; current_second = 0;

                g_Util.Trigger( trigger_minute, self, self, USE_TOGGLE, 0.0f );
            }

            if( current_minute >= CuantosMinutosDuraUnaHora )
            {
                ++current_hour; current_minute = 0;

                g_Util.Trigger( trigger_hour, self, self, USE_TOGGLE, 0.0f );

                if( !string( light_pattern ).IsEmpty() )
                {
                    for( uint ui = 0; ui < Pattern.length(); ui++ )
                    {
                        if( atoi( Pattern[ui][0] ) == current_hour )
                        {
                            if( light_pattern == "!world" )
                            {
                                g_EngineFuncs.LightStyle( 0, Pattern[ui][1] );
                            }
                            else
                            {
                                CBaseEntity@ pLight = null;

                                while( ( @pLight = g_EntityFuncs.FindEntityByTargetname( pLight, light_pattern ) ) !is null )
                                {
                                    g_EntityFuncs.DispatchKeyValue( pLight.edict(), "pattern", Pattern[ui][1] );
                                    pLight.Use( self, self, USE_TOGGLE, 0.0f );
                                    pLight.Use( self, self, USE_TOGGLE, 0.0f );
                                    g_Util.DebugMessage("Light Pattern has been updated to "+ Pattern[ui][1] +"\n");
                                }
                            }
                            break;
                        }
                    }
                }
            }

            if( current_hour >= CuantasHorasDuraUnDia )
            {
                current_second = current_minute = current_hour = 0;

                g_Util.Trigger( trigger_day, self, self, USE_TOGGLE, 0.0f );
            }

            ++current_second;

            self.pev.nextthink = g_Engine.time + 1.0f;
        }
    }
}// end namespace