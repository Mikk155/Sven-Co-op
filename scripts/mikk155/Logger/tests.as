#include "../Logger"
#include "WriteStream"

namespace Logger
{
    uint m_TestsPassed = 0;
    uint m_TestsFailed = 0;

    bool TestExpect( const string&in title, bool expected, bool condition )
    {
        if( condition != expected )
        {
            m_TestsFailed++;
            g_Game.AlertMessage( at_console, "FAIL: \"%1\"\n", title );
            return false;
        }

        g_Game.AlertMessage( at_console, "Pass: \"%1\"\n", title );

        m_TestsPassed++;

        return true;
    }

    funcdef bool Condition();

    // Compare condition to expected for internal tests return whatever condition is expected.
    bool TestExpect( const string&in title, bool expected, Condition@ condition )
    {
        if( condition !is null )
            return TestExpect( title, expected, condition() );
        return false;
    }

    // return 0/1 true false, -1 means re-call method, the int argument is the times your callback has been called
    funcdef int AsyncCallback( int );
    int m_AsyncCallbacks = 0;

    void TestExpectAsync( const string&in title, bool expected, AsyncCallback@ condition, int callTime = 0 )
    {
        if( callTime == 0 )
        {
            if( m_AsyncCallbacks <= 0 )
            {
                g_Game.AlertMessage( at_console, "========================================\n" );
                g_Game.AlertMessage( at_console, "Running Asyncronous tests for Logger.as\n" );
                g_Game.AlertMessage( at_console, "========================================\n" );
            }

            m_AsyncCallbacks++;
        }

        int result = condition( callTime++ );

        if( result < 0 )
        {
            g_Scheduler.SetTimeout( "__IHateFuckingSchedules__", 0.0f, title, expected, condition, callTime );
            return;
        }

        TestExpect( title, expected, ( result != 0 ? true : false ) );

        m_AsyncCallbacks--;

        // All async callbacks finished
        if( m_AsyncCallbacks <= 0 )
        {
            TestEnd();
        }
    }

    // Run logging tests
    void Test()
    {
        g_Game.AlertMessage( at_console, "========================================\n" );
        g_Game.AlertMessage( at_console, "Running tests for Logger.as\n" );
        g_Game.AlertMessage( at_console, "========================================\n" );

        weakref<Logger> test;

        TestExpect( "Find unexistent logger", true, g_Logger.Find( "someUnexistentLoggerNamesex" ) is null );
        TestExpect( "Insert a new logger", true, g_Logger.Register( "Test", test ) );
        TestExpect( "Find the inserted logger", true, g_Logger.Find( "Test" ) !is null );
        TestExpect( "Remove the inserted logger", true, g_Logger.Shutdown( test ) );
        TestExpect( "Shared logger reference to a single instance", true, function()
        {
            auto logger1 = g_Logger.Shared( "shared" );
            auto logger2 = g_Logger.Shared( "shared" );
            return logger1 is logger2;
        } );

        auto cb = Logger::PrintCallback( function( const Logger::ASLogLevel@ level, const string&in message, bool&out bOverride ) { return HOOK_CONTINUE; } );

        TestExpect( "Set a null callback", true, g_Logger.m_GlobalLogger.SetCallback( null ) is null );
        TestExpect( "Set a callback", true, g_Logger.m_GlobalLogger.SetCallback( cb ) !is null );
        TestExpect( "Set an already registered callback", true, g_Logger.m_GlobalLogger.SetCallback( cb ) is null );

        TestExpect( "Remove an already registered callback", true, g_Logger.m_GlobalLogger.RemoveCallback( cb ) );
        TestExpect( "Remove a un-registered callback", false, g_Logger.m_GlobalLogger.RemoveCallback( cb ) );
        TestExpect( "Remove a null callback", false, g_Logger.m_GlobalLogger.RemoveCallback( null ) );

        TestExpect( "WriteStream log file output invalid file", false, Logger::WriteStream::Set( "scripts/maps/invalidfile.txt" ) );
        TestExpect( "WriteStream log file output", true, Logger::WriteStream::Set( "test.log" ) );

        TestExpect( "Print to Critical", true, g_Logger.Log.Critical.Print( "Critical" ) );
        TestExpect( "Print to Error", true, g_Logger.Log.Error.Print( "Error" ) );
        TestExpect( "Print to Warning", true, g_Logger.Log.Warning.Print( "Warning" ) );
        TestExpect( "Print to Notice", true, g_Logger.Log.Notice.Print( "Notice" ) );
        TestExpect( "Print to Info", false, g_Logger.Log.Info.Print( "Info" ) );
        TestExpect( "Print to Debug", false, g_Logger.Log.Debug.Print( "Debug" ) );
        TestExpect( "Print to Trace", false, g_Logger.Log.Trace.Print( "Trace" ) );

        TestExpect( "Logger foreach loop", true,
            function()
            {
                uint i = 0;
                foreach( const Logger::ASLogLevel@ level : g_Logger.Log )
                {
                    i++;
                }
                return i == g_Logger.Log.m_Levels.getSize();
            } );

        g_Logger.SetAllLoggersLevels( Logger::State::On );

        TestExpect( "+128 characters buffer size", true, g_Logger.Log.Info.Print( "--------========--------========--------========--------========--------========--------========--------========--------========string out of buffer size" ) );

        auto PreventAllMessages = g_Logger.m_GlobalLogger.SetCallback(
            function( const Logger::ASLogLevel@ level, const string&in message, bool&out bOverride )
            {
                bOverride = true;
                return HOOK_HANDLED;
            } );

        TestExpect( "Call all levels but a callback disabled them.", true,
            function()
            {
                foreach( const Logger::ASLogLevel@ level : g_Logger.Log )
                {
                    switch( level.Deliver( "dummy" ) )
                    {
                        case Logger::PrintResult::Disabled:
                        case Logger::PrintResult::Handled:
                            break;
                        default:
                            return false;
                    }
                }
                return true;
            } );

        g_Logger.m_GlobalLogger.RemoveCallback( PreventAllMessages );

        TestExpectAsync( "Logger removed from Garbage Collector", true, function( int calls )
        {
            switch( calls )
            {
                case 0:
                    if( !g_Logger.Register( "Reference", void ) )
                        return 0;
                break;
                case 1:
                    if( !g_Logger.Shutdown( "Reference" ) )
                        return 0;
                break;
                default:
                    if( @g_Logger.Get( "Reference" ).get() is null )
                        return 1;
                    if( calls > 120 )
                        return 0;
                break;
            }
            return -1;
        } );

        // No async callbacks?
        if( m_AsyncCallbacks <= 0 )
            TestEnd();
    }

    void TestEnd()
    {
        g_Game.AlertMessage( at_console, "========================================\n" );
        if( m_TestsFailed == 0 )
        {
            g_Game.AlertMessage( at_console, "All %1 tests passed!\n", m_TestsPassed );
        }
        else
        {
            g_Game.AlertMessage( at_console, "%1 tests failed!\n", m_TestsFailed );
        }
        g_Game.AlertMessage( at_console, "========================================\n" );
    }
}

void __IHateFuckingSchedules__( const string&in title, bool expected, Logger::AsyncCallback@ condition, int callTime = 0 )
{
    Logger::TestExpectAsync(title, expected, condition, callTime );
}
