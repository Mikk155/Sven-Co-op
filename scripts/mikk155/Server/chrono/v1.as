namespace Server
{
    class chrono
    {
        private float m_enginetime;
        private uint64 m_ms;
        private TimeDifference m_Difference;
        private DateTime m_Time;

        /**
        *   @brief Get the time of creation of this chronometer.
        **/
        const DateTime& Time
        {
            get const
            {
                return this.m_Time;
            }
        }

        /**
        *   @brief Stop the chrono and build the time difference
        **/
        void Stop()
        {
            DateTime now = DateTime();
            this.m_Difference = now - this.m_Time;
            // this.m_ms = uint64( uint( now.GetMilliseconds() - this.m_Time.GetMilliseconds() ) ); nowork
            // No real mili seconds, estimated time by frame rate
            this.m_ms = uint64( double( g_Engine.time - this.m_enginetime ) + uint( ( g_Engine.frametime > 0.0f ? int( 1.0f / g_Engine.frametime ) : 0 ) ) );
            this.m_Difference.MakeAbsolute();
        }

        /**
        *   @brief Get the time diference of this chronometer.
        **/
        const TimeDifference& Difference
        {
            get const
            {
                return this.m_Difference;
            }
        }

        /**
        *   @brief Restart the chronometer time
        **/
        void Restart()
        {
            this.m_enginetime = g_Engine.time;
            this.m_Time = DateTime();
        }

        chrono()
        {
            this.Restart();
        }

        uint8 Seconds
        {
            get const
            {
                return uint8( this.Difference.GetSeconds() % 60 );
            }
        }

        uint8 Minutes
        {
            get const
            {
                return uint8( this.Difference.GetMinutes() % 60 );
            }
        }

        uint8 Hours
        {
            get const
            {
                return uint8( this.Difference.GetHours() % 24 );
            }
        }

        uint8 Days
        {
            get const
            {
                return uint8( this.Difference.GetDays() );
            }
        }

        uint64 Miliseconds
        {
            get const
            {
                return this.m_ms;
            }
        }
    }
}
