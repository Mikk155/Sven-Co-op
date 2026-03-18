class ServerFramerate
{
    // Current framerate
    int Current;

    // Number of frames per second
    int Count;

    // Total frames the previous second had
    int Frames;

    // True if this is the last frame of a second
    bool LastFrame;
}

namespace Server
{
    // Server's frame-rate
    namespace Framerate
    {
        funcdef void FrameRateCallback( const ServerFramerate@ data );

        /**
        *   @brief Get the current server's frame rate
        **/
        int CurrentRate()
        {
            if( g_Engine.frametime > 0.0f )
                return int( 1.0f / g_Engine.frametime );
            return 0.0f;
        }

        class __CThinker__
        {
            private CScheduledFunction@ m_Think = null;
            array<FrameRateCallback@> m_Callbacks;

            __CThinker__()
            {
                @this.m_Think = g_Scheduler.SetInterval( @this, "__Think__", 0.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
                @this.data = ServerFramerate();
            }

            void Shutdown()
            {
                if( m_Think !is null )
                {
                    g_Scheduler.RemoveTimer( @this.m_Think );
                    @m_Think = null;
                }
                @data = null;
            }

            ~__CThinker__()
            {
                Shutdown();
            }

            private int m_FrameCount = 0;
            private int m_ServerFrames = 0;
            private float m_NextFrameUpdate = 0.0f;
            private ServerFramerate@ data;

            void __Think__()
            {
                this.data.Count = this.m_FrameCount++;

                if( g_Engine.time >= this.m_NextFrameUpdate )
                {
                    this.data.Frames = this.m_ServerFrames = this.m_FrameCount;
                    this.m_FrameCount = 0;
                    data.LastFrame = true;
                    this.m_NextFrameUpdate = g_Engine.time + 1.0f;
                }

                data.Current = CurrentRate();

                uint size = this.m_Callbacks.length();

                if( size < 0 )
                {
                    Shutdown();
                    return;
                }

                for( uint ui = 0; ui < size; ui++ )
                {
                    FrameRateCallback@ callback = this.m_Callbacks[ui];

                    if( callback !is null )
                        callback( @data );
                }

                data.LastFrame = false;
            }
        }

        __CThinker__@ __Thinker__;

        /**
        *   @brief Set a callback method for every frame update
        **/
        FrameRateCallback@ SetCallback( FrameRateCallback@ callback )
        {
            if( __Thinker__ is null )
                @__Thinker__ = __CThinker__();

            __Thinker__.m_Callbacks.insertLast( @callback );

            return @callback; // So can use lambda and kill em later
        }

        /**
        *   @brief remove a callback method from the list
        **/
        void RemoveCallback( FrameRateCallback@ callback )
        {
            if( __Thinker__ is null )
                return;

            int m_Id = __Thinker__.m_Callbacks.findByRef( callback );

            if( m_Id >= 0 )
                __Thinker__.m_Callbacks.removeAt( m_Id );

            uint size = __Thinker__.m_Callbacks.length();

            for( uint ui = 0; ui < size; ui++ )
            {
                if( __Thinker__.m_Callbacks[ui] !is null )
                    return;
            }

            __Thinker__.m_Callbacks.resize(0);
            // -TODO Call delete if AS is updated.
            @__Thinker__ = null;
        }
    }
}
