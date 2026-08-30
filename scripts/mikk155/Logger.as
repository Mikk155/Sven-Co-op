// This file's "SERVER" pre processor can safely be disabled to reduce compile time and memory

// Logger's internal namespace.
namespace Logger
{
    /**
    *   Called when a message is about to be printed.
    *   level: Logge level
    *   message: Formated string message
    *   bOverride: prevent the message from being printed to console.
    *   return: HOOK_HANDLED to stop calling other callbacks. HOOK_CONTINUE otherwise.
    **/
    funcdef HookReturnCode PrintCallback( const Logger::ASLogLevel@ level, const string&in message, bool&out bOverride );
    // -TODO Move into the logger manager when #77 is closed: https://github.com/anjo76/angelscript/issues/77

    // Enum representing a logger state
    // By default all loggers and their levels are disabled.
    enum State
    {
        // Logger level disabled.
        Off = 0,
        // Logger level enabled but respects the global level at g_Logger.
        On,
        // Logger level enabled always and doesn't care for the global level at g_Logger.
        OnAlways
    };

    enum PrintResult
    {
        // Level is disabled
        Disabled = 0,
        // Message printed to server
        Printed,
        // Callback handled the output
        Handled,
        // Either empty message or formating error
        Error
    };

    final class ASLogLevel
    {
        private
            Logger@ m_Owner;

        private
            string m_LevelName;

        private
            Logger::State m_State;

        void SetState( const Logger::State&in state )
        {
            this.m_State = state;

            g_Game.AlertMessage( at_console, "Logger memoffset: %1 %2\n", this, int(m_State) );
            switch( this.m_State )
            {
                case Logger::State::Off:
                {
                    if( g_Logger.Log.Notice.IsActive() )
                        g_Logger.Log.Notice.Print( "Logger \"{}\" disabled level \"{}\"", this.m_Owner.GetName(), this.GetName() );
                    break;
                }
                case Logger::State::OnAlways:
                {
                    if( g_Logger.Log.Notice.IsActive() )
                        g_Logger.Log.Notice.Print( "Logger \"{}\" force enabled level \"{}\"", this.m_Owner.GetName(), this.GetName() );
                    break;
                }
                case Logger::State::On:
                default:
                {
                    if( g_Logger.Log.Notice.IsActive() )
                        g_Logger.Log.Notice.Print( "Logger \"{}\" enabled level \"{}\"", this.m_Owner.GetName(), this.GetName() );
                    break;
                }
            }
        }

        // Logger::opIndex requires this.
        ASLogLevel() {}

        ASLogLevel( const string level, Logger@ owner, State state = State::Off )
        {
            this.m_LevelName = level;
            this.m_State = state;
            @this.m_Owner = owner;

            this.m_Owner.m_Levels[ level ] = this;
        }

        // Logger level name.
        const string& GetName() const
        {
            return this.m_LevelName;
        }

        // Logger level name.
        bool IsActive() const
        {
            switch( this.m_State )
            {
                case Logger::State::OnAlways:
                {
                    return true;
                }
                case Logger::State::On:
                {
                    if( g_Logger.Log is this.m_Owner )
                        return true;
                    return g_Logger.Log[ this.GetName() ].IsActive();
                }
                case Logger::State::Off:
                default:
                {
                    return false;
                }
            }
        }

        protected
            bool ShouldDeliver( array<Logger::PrintCallback@> &in callbacks, const string &in message, bool&out handled ) const
            {
                bool result = true;

                uint length = callbacks.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    Logger::PrintCallback@ callback = callbacks[ui];

                    bool log_override = false;

                    HookReturnCode callback_result = callback( this, message, log_override );

                    if( log_override == true )
                    {
                        result = false;
                    }

                    if( callback_result == HOOK_HANDLED )
                    {
                        handled = true;
                        return result;
                    }
                }

                return result;
            }

        // Deliver a message to the console or custom destination
        Logger::PrintResult Deliver( const string&in message, const array<string>@ args = null ) const
        {
            if( !this.IsActive() )
            {
            g_Game.AlertMessage( at_console, "Logger memoffset: %1 %2\n", this, int(m_State) );
                g_Game.AlertMessage( at_console,
                    "Warning: Logger \"%1.%2.Print(...)\" is being called without checking if it's active! save on resources.\n",
                    this.m_Owner.GetName(), this.GetName()
                );
                return Logger::PrintResult::Disabled;
            }

            if( message.IsEmpty() )
            {
                g_Game.AlertMessage( at_console,
                    "Warning: Logger \"%1.%2.Print(...)\" is sending a empty string!\n",
                    this.m_Owner.GetName(), this.GetName()
                );
                return Logger::PrintResult::Error;
            }

            string output;
            snprintf( output, "[%1] [%2] %3\n", this.m_Owner.GetName(), this.GetName(), message );

            if( args !is null )
            {
                uint length = args.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    uint index = output.Find( "{}" );

                    if( index == String::INVALID_INDEX )
                    {
                        g_Game.AlertMessage( at_console,
                            "Error: Logger \"%1.%2.Print(...)\" is addng more arguments than defined in message!\nMessage:\n",
                            this.m_Owner.GetName(), this.GetName()
                        );
                        g_Game.AlertMessage( at_console, message );
                        return Logger::PrintResult::Error;
                    }

                    auto start = output.SubString( 0, index );
                    auto end = output.SubString( index + 2 );

                    snprintf( output, "%1%2%3", start, args[ui], end );
                }

                if( output.Find( "{}" ) != String::INVALID_INDEX )
                {
                    g_Game.AlertMessage( at_console,
                        "Error: Logger \"%1.%2.Print(...)\" is adding less arguments than defined in message!\nMessage:\n",
                        this.m_Owner.GetName(), this.GetName()
                    );
                    g_Game.AlertMessage( at_console, message );
                    return Logger::PrintResult::Error;
                }
            }

            bool handled;
            if( !this.ShouldDeliver( this.m_Owner.m_Callbacks, output, handled) || ( !handled && this.m_Owner !is g_Logger.Log && !this.ShouldDeliver( g_Logger.Log.m_Callbacks, output, handled ) ) )
            {
                return Logger::PrintResult::Handled;
            }

            while( output.Length() > 128 )
            {
                g_EngineFuncs.ServerPrint( output.SubString( 0, 128 ) );
                output = output.SubString( 128 );
            }

            if( output.Length() > 0 )
            {
                g_EngineFuncs.ServerPrint( output );
            }

            return Logger::PrintResult::Printed;
        }

        // Return whatever result is been printed/handled
        bool Delivered( Logger::PrintResult result ) const
        {
            switch( result )
            {
                case Logger::PrintResult::Printed:
                case Logger::PrintResult::Handled:
                    return true;
                case Logger::PrintResult::Disabled:
                case Logger::PrintResult::Error:
                default:
                    return false;
            }
        }

        bool Print( const string&in message ) const
        {
            return this.Delivered( this.Deliver( message, null ) );
        }

        bool Print( const string&in message, const array<string>&in args ) const
        {
            return this.Delivered( this.Deliver( message, args ) );
        }

        bool Print( const string&in message, const string&in a1 ) const {
            return this.Delivered( this.Deliver( message, { a1 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3, const string&in a4 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3, a4 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3, const string&in a4, const string&in a5 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3, a4, a5 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3, const string&in a4, const string&in a5, const string&in a6 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3, a4, a5, a6 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3, const string&in a4, const string&in a5, const string&in a6, const string&in a7 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3, a4, a5, a6, a7 } ) );
        }
        bool Print( const string&in message, const string&in a1, const string&in a2, const string&in a3, const string&in a4, const string&in a5, const string&in a6, const string&in a7, const string&in a8 ) const {
            return this.Delivered( this.Deliver( message, { a1, a2, a3, a4, a5, a6, a7, a8 } ) );
        }
    }
}

class Logger
{
    private string m_Name;

    // Logger name.
    const string& GetName() const
    {
        return this.m_Name;
    }

    // Logger::ASLogLevel requires this.
    Logger() {}

    Logger( const string&in name )
    {
        this.m_Name = name;
    }

    array<Logger::PrintCallback@> m_Callbacks(0);

    /**
    *   Set a method to call back every time a log is about to be print.
    *   return: Handle to the given method or null
    **/
    Logger::PrintCallback@ SetCallback( Logger::PrintCallback@ callback )
    {
        if( callback is null )
        {
            if( this.Error.IsActive() )
                this.Error.Print( "Failed to call {}.SetCallback(...) with nullptr callback!", this.GetName() );
            return null;
        }

        if( m_Callbacks.findByRef( callback ) >= 0 )
        {
            if( this.Error.IsActive() )
                this.Error.Print( "Failed to call {}.SetCallback(...) with a pointer callback that already exists!", this.GetName() );
            return null;
        }

        m_Callbacks.insertLast( callback );

        return callback;
    }

    /**
    *   Remove a method from the callback list.
    **/
    bool RemoveCallback( Logger::PrintCallback@ callback )
    {
        if( callback is null )
        {
            if( this.Error.IsActive() )
                this.Error.Print( "Failed to call {}.RemoveCallback(...) with nullptr callback!", this.GetName() );
            return false;
        }

        int index = m_Callbacks.findByRef( callback );

        if( index < 0 )
        {
            if( this.Error.IsActive() )
                this.Error.Print( "Failed to call {}.RemoveCallback(...) with a pointer callback that doesn't exists!!", this.GetName() );
            return false;
        }

        m_Callbacks.removeAt( index );

        return true;
    }

    /**
    *   Trace: For hyper-detailed diagnostic events.
    *   It produces the highest volume of logs.
    *   Typically used to step through code execution line-by-line when debugging complex issues in a development environment.
    */
    Logger::ASLogLevel Trace( "Trace", this );

    /**
    *   Debug: For internal system events helpful during development.
    *   Use this to log variables, state changes, or execution paths that assist in troubleshooting without cluttering production logs.
    */
    Logger::ASLogLevel Debug( "Debug", this );

    /**
    *   Info: For standard operational events.
    *   Records normal, expected application lifecycle milestones (e.g., service started, user logged in, data exported successfully).
    */
    Logger::ASLogLevel Info( "Info", this );

    /**
    *   Notice: For standard but relevant events.
    *   Additional level for information more relevant than Info but not enough to be a Warning.
    */
    Logger::ASLogLevel Notice( "Notice", this, Logger::State::On );

    /**
    *   Warning: For unexpected but non-critical events.
    *   The application continues to function normally.
    *   But something unusual occurred that might indicate a potential future issue (e.g., disk space running low, deprecated API used).
    */
    Logger::ASLogLevel Warning( "Warning", this, Logger::State::OnAlways );

    /**
    *   Error: For actionable failures.
    *   The application could not perform a specific operation or fulfill a request.
    *   This indicates a definite problem that requires developer attention (e.g., database connection failed, operation timed out).
    */
    Logger::ASLogLevel Error( "Error", this, Logger::State::OnAlways );

    /**
    *   Critical: For fatal system failures.
    *   The application or a major subsystem has crashed, data has been corrupted, or an immediate system-wide outage has occurred.
    *   This requires immediate intervention.
    */
    Logger::ASLogLevel Critical( "Critical", this, Logger::State::OnAlways );

    dictionary m_Levels;

    /**
    *   Return the logger level according to the given name.
    *   For example "Critical" returns a handle to this.Critical.
    *   NOTE: Case sensitive is expected.
    */
    Logger::ASLogLevel@ opIndex( const string&in loggerLevelName ) const
    {
        Logger::ASLogLevel@ level;
        if( this.m_Levels.get( loggerLevelName, @level ) )
            return level;
        return null;
    }

    /**
    *   Return the logger level according to the given index.
    */
    Logger::ASLogLevel@ opIndex( uint index ) const
    {
        return this.opIndex( this.m_Levels.getKeys().opIndex( index ) );
    }

    int opForBegin() const 
    {
        return 0;
    }

    bool opForEnd( int it ) const 
    {
        return it >= int(this.m_Levels.getSize());
    }

    int opForNext( int it ) const 
    {
        return it + 1;
    }

    const Logger::ASLogLevel@ opForValue( int it ) const
    {
        return this.opIndex( uint(it) );
    }

    Logger::ASLogLevel@ opForValue( int it )
    {
        return this.opIndex( uint(it) );
    }

    void SetLevel( const string&in level, Logger::State state )
    {
        g_Logger.SetLevel( this, level, state );
    }

    void SetAllLevels( Logger::State state )
    {
        foreach( auto level : this )
        {
            level.SetState( state );
        }
    }
}

final class ASLoggerManager
{
    Logger m_GlobalLogger( g_Module.GetModuleName() );

    // Access a global logger instance
    const Logger@ get_Log()
    {
        return this.m_GlobalLogger;
    }

    private
        array<Logger@> m_LoggerRefCount(0);

    /**
    *   Set a method to call back every time the global logger is about to be print.
    *   return: Handle to the given method or null
    **/
    Logger::PrintCallback@ SetCallback( Logger::PrintCallback@ callback )
    {
        return this.m_GlobalLogger.SetCallback( callback );
    }

    /**
    *   Remove a method from the callback list in the global logger
    **/
    bool RemoveCallback( Logger::PrintCallback@ callback )
    {
        return this.m_GlobalLogger.RemoveCallback( callback );
    }

    /**
    *   Set a method to call back every time the given logger is about to be print.
    *   return: Handle to the given method or null
    **/
    Logger::PrintCallback@ SetCallback( Logger@ logger, Logger::PrintCallback@ callback )
    {
        if( logger is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetCallback on a null Logger!" );
            return null;
        }
        return logger.SetCallback( callback );
    }

    /**
    *   Remove a method from the callback list in the given logger
    **/
    bool RemoveCallback( Logger@ logger, Logger::PrintCallback@ callback )
    {
        if( logger is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to RemoveCallback on a null Logger!" );
            return false;
        }
        return logger.RemoveCallback( callback );
    }


    /**
    *   Set a method to call back every time the given logger is about to be print.
    *   return: Handle to the given method or null
    **/
    Logger::PrintCallback@ SetCallback( weakref<Logger>&in logger, Logger::PrintCallback@ callback )
    {
        return this.SetCallback( logger.get(), callback );
    }

    /**
    *   Remove a method from the callback list in the given logger
    **/
    bool RemoveCallback( weakref<Logger>&in logger, Logger::PrintCallback@ callback )
    {
        return this.RemoveCallback( logger.get(), callback );
    }

    // Set the log state for the given level
    void SetLevel( Logger::ASLogLevel@ level, Logger::State state )
    {
        if( level is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger level instance!" );
            return;
        }

        level.SetState( state );
    }

    // Set the log state for the given level at the given logger
    void SetLevel( Logger@ logger, const string&in level, Logger::State state )
    {
        if( logger is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger instance!" );
            return;
        }

        Logger::ASLogLevel@ logLevel = logger[ level ];

        if( logLevel is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger level instance! named level {}", level );
            return;
        }

    }

    // Set the log state for the given level at the given logger
    void SetLevel( weakref<Logger>&in logger, const string&in level, Logger::State state )
    {
        if( @logger.get() is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger instance!" );
            return;
        }

        this.SetLevel( logger.get(), level, state );
    }

    // Set the log state for the given level at the given logger
    void SetLevel( const string&in loggerName, const string&in level, Logger::State state )
    {
        weakref<Logger> logger = this.Get( loggerName );

        if( @logger.get() is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger instance! named logger {}", loggerName );
            return;
        }

        this.SetLevel( logger, level, state );
    }

    // Set the log state for all levels at the given logger
    void SetAllLevels( Logger@ logger, Logger::State state )
    {
        if( logger is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetAllLevels on a null Logger instance!" );
            return;
        }

        logger.SetAllLevels(state);
    }

    // Set the log state for all levels at the given logger
    void SetAllLevels( weakref<Logger>&in logger, Logger::State state )
    {
        if( @logger.get() is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetAllLevels on a null Logger instance!" );
            return;
        }

        logger.get().SetAllLevels( state );
    }

    // Set the log state for all levels at the given logger
    void SetAllLevels( const string&in loggerName, Logger::State state )
    {
        weakref<Logger> logger = this.Get( loggerName );

        if( @logger.get() is null )
        {
            g_Logger.Log.Critical.Print( "Attempted to SetLevel on a null Logger instance! named logger {}", loggerName );
            return;
        }

        this.SetAllLevels( logger, state );
    }

    // Set log state for all levels at all loggers
    void SetAllLoggersLevel( const string&in level, Logger::State state )
    {
        foreach( auto logger : this )
        {
            logger.SetLevel( level, state );
        }
    }


    // Set log state for all levels at all loggers
    void SetAllLoggersLevels( Logger::State state )
    {
        foreach( auto logger : this )
        {
            logger.SetAllLevels( state );
        }
    }

    // Find the logger with the given name and return it. null otherwise
    const Logger@ Find( const string&in loggerName )
    {
        uint length = this.m_LoggerRefCount.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            const Logger@ candidate = this.m_LoggerRefCount[ui];

            if( loggerName == candidate.GetName() )
                return @candidate;
        }
        return null;
    }

    // Find the logger with the given name and return a valid weakref if it exists
    weakref<Logger> Get( const string&in loggerName )
    {
        weakref<Logger> logger;

        uint length = this.m_LoggerRefCount.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            Logger@ candidate = this.m_LoggerRefCount[ui];

            if( loggerName == candidate.GetName() )
            {
                logger.opHndlAssign( candidate );
                break;
            }
        }

        return logger;
    }

    // Find the logger with the given name if it doesn't exists allocates it.
    weakref<Logger> Shared( const string&in loggerName )
    {
        weakref<Logger> logger;

        uint length = this.m_LoggerRefCount.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            Logger@ candidate = this.m_LoggerRefCount[ui];

            if( loggerName == candidate.GetName() )
            {
                logger.opHndlAssign( candidate );
                return logger;
            }
        }

        this.Register( loggerName, logger );

        return logger;
    }

    // Register a logger with the given name and outputs a weakref, return false if the given loggerName already exists.
    bool Register( const string&in loggerName, weakref<Logger>&out logger )
    {
        if( Find( loggerName ) is null )
        {
            Logger@ loggerInstance = Logger( loggerName );
            this.m_LoggerRefCount.insertLast( loggerInstance );
            logger.opHndlAssign( loggerInstance );
            return true;
        }

        return false;
    }

    // Remove the given logger from the list of logging
    bool Shutdown( const Logger@ logger )
    {
        if( logger !is null )
        {
            int found = this.m_LoggerRefCount.findByRef( logger );

            if( found >= 0 )
            {
                this.m_LoggerRefCount.removeAt( found );
                return true;
            }
        }
        return false;
    }

    // Remove the given logger from the list of logging
    bool Shutdown( weakref<Logger>&in logger )
    {
        return Shutdown( logger.get() );
    }

    // Remove the logger with the given name from the list of logging
    bool Shutdown( const string&in loggerName )
    {
        uint length = this.m_LoggerRefCount.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            const Logger@ candidate = this.m_LoggerRefCount[ui];

            if( loggerName == candidate.GetName() )
                return Shutdown( candidate );
        }

        return false;
    }

    int opForBegin() 
    {
        return 0;
    }

    bool opForEnd( int it ) 
    {
        return it > int( this.m_LoggerRefCount.length() );
    }

    int opForNext( int it ) 
    {
        return it + 1;
    }

    Logger@ opForValue( int it )
    {
        if( it >= int( this.m_LoggerRefCount.length() ) )
            return @this.m_GlobalLogger;
        return @this.m_LoggerRefCount[it];
    }
}

// Global logger handler
ASLoggerManager g_Logger;
