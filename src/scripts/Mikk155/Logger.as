/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

#include "fmt"
#include "constdef"

namespace Logger
{
    enum Level
    {
        Critical = ( 1 << 0 ),
        Error = ( 1 << 1 ),
        Warning = ( 1 << 2 ),
        Information = ( 1 << 3 ),
        Debug = ( 1 << 4 ),
        Trace = ( 1 << 5 )
    };

    int GlobalLevel = (
        Level::Critical |
        Level::Error |
        Level::Warning |
        Level::Information |
        Level::Debug |
        Level::Trace
    );

    //-TODO Log to a file in store/ by pushing messages to a global list and iterate over it on a schedule basis
    bool LogToFile = false;

    array<CLogger@> LoggerInstances;

    void LoggerSetCallback( const CCommand@ args )
    {
        CBasePlayer@ player = g_ConCommandSystem.GetCurrentPlayer();

        if( args.ArgC() > 1 )
        {
            string LoggerLevelName;
            string LoggerInstanceName;
            CLogger@ loggerTarget = null;

            if( args.ArgC() > 2 )
            {
                LoggerLevelName = args[2];
                @loggerTarget = GetLogger( args[1] );

                if( loggerTarget is null )
                {
                    g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "Unknown logger instance with name \"%s\"\n", args[1] );
                    return;
                }
            }
            else
            {
                LoggerLevelName = args[1];
            }

            int LoggerLevelValue = GetLevelFromString(LoggerLevelName);

            if( LoggerLevelValue == 0 )
            {
                g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "Unknown logger level with name \"%s\"\n", LoggerLevelName );
                return;
            }

            UpdateAction added;

            if( loggerTarget !is null )
            {
                added = UpdateLevel( UpdateAction::TOGGLE, Level( LoggerLevelValue ), loggerTarget );
            }
            else
            {
                added = UpdateLevel( UpdateAction::TOGGLE, Level( LoggerLevelValue ) );
            }

            g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "%s level \"%s\" for %s\n", added != UpdateAction::SET ? "Disabled": "Enabled",
                LoggerLevelName, loggerTarget !is null ? loggerTarget.Name : "All loggers" );
            return;
        }

        array<string> list = fmt::SplitBuffer( LoggerLevelToggle.GetHelpInfo(), CONSTDEF::CHAT_BUFFER_SIZE );

        for( uint ui = 0; ui < list.length(); ui++ )
        {
            g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, list[ui] );
        }

        if( LoggerInstances.length() > 0 )
        {
            g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "Loggers currently initialized:\n" );

            for( uint ui = 0; ui < LoggerInstances.length(); ui++ )
            {
                CLogger@ logger = LoggerInstances[ui];

                if( logger !is null )
                {
                    g_PlayerFuncs.ClientPrint( player, HUD_PRINTCONSOLE, "\"%s\"\n", logger.Name );
                }
            }
        }
    }

    CClientCommand@ LoggerLevelToggle;

    // HACK: if this is not called in PluginInit is too early to apply the concommand prefix for plugins
    bool blAutoRegisterConCommands = RegisterConCommands();

    bool RegisterConCommands()
    {
        @LoggerLevelToggle = CClientCommand(
            "logger",
            "Toggle a logger level by name\n<command> <optional logger name> <logger level name>\nto get a message printed it should have both the logger instance and the global logger levels enabled.\nLogger names:\n\"critical\"\n\"error\"\n\"warning\"\n\"information\"\n\"debug\"\n\"trace\"\n",
            @Logger::LoggerSetCallback,
            ConCommandFlag::AdminOnly
        );
        return true;
    }

    /**
    <summary>
        <return>CLogger@</return>
        <body>Logger::GetLogger( const string&in Name )</body>
        <prefix>Logger::GetLogger, GetLogger</prefix>
        <description>Get a registered logger instance by name</description>
    </summary>
    **/
    CLogger@ GetLogger( const string&in Name )
    {
        if( Name != String::EMPTY_STRING )
        {
            for( uint ui = 0; ui < Logger::LoggerInstances.length(); ui++ )
            {
                CLogger@ logger = Logger::LoggerInstances[ui];

                if( logger.Name == Name )
                {
                    return logger;
                }
            }
        }
        return null;
    }

    /**
    <summary>
        <return>int</return>
        <body>Logger::GetLevelFromString( string Name )</body>
        <prefix>Logger::GetLevelFromString, GetLevelFromString</prefix>
        <description>Get a int equivalent to a Logger::Level enum by the given string, 0 if invalid.</description>
    </summary>
    **/
    int GetLevelFromString( string Name )
    {
        Name.ToLowercase();

        if( Name == "critical" )
            return Logger::Level::Critical;
        if( Name == "error" )
            return Logger::Level::Error;
        if( Name == "warning" )
            return Logger::Level::Warning;
        if( Name == "information" )
            return Logger::Level::Information;
        if( Name == "debug" )
            return Logger::Level::Debug;
        if( Name == "trace" )
            return Logger::Level::Trace;

        return 0;
    }

    enum UpdateAction
    {
        TOGGLE = 0,
        SET = 1,
        CLEAR = 2,
        NULL = 3
    };

    // mf int&out not working at all.
    UpdateAction UpdateLevel( const UpdateAction action, const Level level, CLogger@ logger )
    {
        if( logger is null )
            return UpdateAction::NULL;

        switch( action )
        {
            case UpdateAction::SET:
            {
                if( logger.Level & level == 0 )
                    logger.Level |= level;
                return UpdateAction::SET;
            }
            case UpdateAction::CLEAR:
            {
                if( logger.Level & level != 0 )
                    logger.Level &= ~level;
                return UpdateAction::CLEAR;
            }
            case UpdateAction::TOGGLE:
            default:
            {
                if( logger.Level & level != 0 )
                {
                    logger.Level &= ~level;
                    return UpdateAction::CLEAR;
                }
                logger.Level |= level;
                return UpdateAction::SET;
            }
        }
    }

    UpdateAction UpdateLevel( const UpdateAction action, const Level level )
    {
        switch( action )
        {
            case UpdateAction::SET:
            {
                if( GlobalLevel & level == 0 )
                    GlobalLevel |= level;
                return UpdateAction::SET;
            }
            case UpdateAction::CLEAR:
            {
                if( GlobalLevel & level != 0 )
                    GlobalLevel &= ~level;
                return UpdateAction::CLEAR;
            }
            case UpdateAction::TOGGLE:
            default:
            {
                if( GlobalLevel & level != 0 )
                {
                    GlobalLevel &= ~level;
                    return UpdateAction::CLEAR;
                }
                GlobalLevel |= level;
                return UpdateAction::SET;
            }
        }
    }

    void UpdateLevel( const UpdateAction action, const int level, const string&in name = String::EMPTY_STRING )
    {
        if( level == 0 )
            return;
        
        const Level levelE = Level(level);

        if( name != String::EMPTY_STRING )
        {
            CLogger@ logger = GetLogger( name );

            if( logger !is null )
            {
                UpdateLevel( action, levelE, logger );
            }
        }
        else
        {
            UpdateLevel( action, levelE  );
        }
    }

    void ClearLevel( const string&in level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::CLEAR, GetLevelFromString(level), name );
    }

    void ClearLevel( const int level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::CLEAR, level, name );
    }

    void SetLevel( const string&in level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::SET, GetLevelFromString(level), name );
    }

    void SetLevel( const int level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::SET, level, name );
    }

    void ToggleLevel( const string&in level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::TOGGLE, GetLevelFromString(level), name );
    }

    void ToggleLevel( const int level, const string&in name = String::EMPTY_STRING )
    {
        UpdateLevel( Logger::UpdateAction::TOGGLE, level, name );
    }
}

/**
<summary>
    <return>CLogger@</return>
    <body>CLogger( const string& name, bool IsStatic = false )</body>
    <prefix>Logger, CLogger</prefix>
    <description>Create a new CLogger instance, if IsStatic is true this logger is not added to the handler list</description>
</summary>
**/
class CLogger
{
    private string _Name;

    /**
    <summary>
        <return>string</return>
        <body>Name</body>
        <prefix>CLogger.Name, Name</prefix>
        <description>Return the name of this logger handle</description>
    </summary>
    **/
    string Name
    {
        get const { return this._Name; }
    }

    /**
    <summary>
        <return>int</return>
        <body>Level</body>
        <prefix>CLogger.Level, Level</prefix>
        <description>Return the log level of this logger handle</description>
    </summary>
    **/
    int Level = Logger::GlobalLevel;

    CLogger( const string& in name, bool IsStatic = false /*Zzz being unable to know this automatically*/ )
    {
        _Name = name;

        if( !IsStatic )
        {
            Logger::LoggerInstances.insertLast( @this );
        }
    }

    ~CLogger()
    {
        this.Shutdown();
    }

    /**
    <summary>
        <return>void</return>
        <body>Shutdown</body>
        <prefix>CLogger.Shutdown, Shutdown</prefix>
        <description>Remove this logger handle from the logger handler list</description>
    </summary>
    **/
    void Shutdown()
    {
        // Remove the reference from the logger list
        for( uint ui = 0; ui < Logger::LoggerInstances.length(); ui++ )
        {
            CLogger@ logger = Logger::LoggerInstances[ui];

            if( logger.Name == this.Name )
            {
                Logger::LoggerInstances.removeAt(ui);
                break;
            }
        }
    }

    protected const string log( const string&in message, const string&in level )
    {
        //-TODO Datetime? If LogToFile is implemented of course.
        string buffer;
        snprintf( buffer, "[%1] [%2] %3 \n", this.Name, level, message );
        g_EngineFuncs.ServerPrint( buffer );
        return buffer;
    }

    /**
    <summary>
        <return>void</return>
        <body>error( const string&in message )</body>
        <prefix>CLogger.error, error</prefix>
        <description>Print a error message. this ignores the log level and will always be printed.</description>
    </summary>
    **/
    void error( const string&in message )
    {
        this.log( message, "Error" );
    }

    /**
    <summary>
        <return>void</return>
        <body>critical( const string&in message )</body>
        <prefix>CLogger.critical, critical</prefix>
        <description>Print a critical message. this ignores the log level and will always be printed.</description>
    </summary>
    **/
    void critical( const string&in message )
    {
        this.log( message, "Critical" );
    }

    /**
    <summary>
        <return>void</return>
        <body>warn( const string&in message )</body>
        <prefix>CLogger.warn, warn</prefix>
        <description>Print a warn message.</description>
    </summary>
    **/
    void warn( const string&in message )
    {
        if( Level & Logger::Level::Warning != 0 && Logger::GlobalLevel & Logger::Level::Warning != 0 )
            this.log( message, "Warning" );
    }

    /**
    <summary>
        <return>void</return>
        <body>info( const string&in message )</body>
        <prefix>CLogger.info, info</prefix>
        <description>Print a info message.</description>
    </summary>
    **/
    void info( const string&in message )
    {
        if( Level & Logger::Level::Information != 0 && Logger::GlobalLevel & Logger::Level::Information != 0 )
            this.log( message, "Information" );
    }

    /**
    <summary>
        <return>void</return>
        <body>debug( const string&in message )</body>
        <prefix>CLogger.debug, debug</prefix>
        <description>Print a debug message.</description>
    </summary>
    **/
    void debug( const string&in message )
    {
        if( Level & Logger::Level::Debug != 0 && Logger::GlobalLevel & Logger::Level::Debug != 0 )
            this.log( message, "Debug" );
    }

    /**
    <summary>
        <return>void</return>
        <body>trace( const string&in message )</body>
        <prefix>CLogger.trace, trace</prefix>
        <description>Print a trace message.</description>
    </summary>
    **/
    void trace( const string&in message )
    {
        if( Level & Logger::Level::Trace != 0 && Logger::GlobalLevel & Logger::Level::Trace != 0 )
            this.log( message, "Trace" );
    }
}
