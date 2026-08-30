#include "../Logger"

namespace Logger
{
    namespace WriteStream
    {
        Logger::PrintCallback@ gpCallback = @Logger::WriteStream::gpStream;
        dictionary gpStreams;

        /**
        *   Create a callback onto loggers for writing logs into an external file with the given name.
        *   exists_ok: if true logs are appended otherwise the file is cleared first
        **/
        bool Set( const string&in fileName, bool exists_ok = false )
        {
            string filePath;
            snprintf( filePath, "scripts/%1/store/%2", ( g_Module.GetModuleName() != "MapModule" ? "plugins" : "maps" ), fileName );

            bool validPath = false;

            if( exists_ok == false )
            {
                File@ fWrite = g_FileSystem.OpenFile( filePath, OpenFile::OpenFile::WRITE );

                if( fWrite !is null && fWrite.IsOpen() )
                {
                    validPath = true;
                    fWrite.Write( String::EMPTY_STRING );
                    fWrite.Close();
                }
            }
            else
            {
                File@ fRead = g_FileSystem.OpenFile( filePath, OpenFile::OpenFile::READ );

                if( fRead is null || fRead.IsOpen() )
                {
                    if( g_Logger.Log.Notice.IsActive() )
                        g_Logger.Log.Notice.Print( "File not found for Logger::WriteStream::Set( \"{}\" )", filePath );

                    File@ fWrite = g_FileSystem.OpenFile( filePath, OpenFile::OpenFile::WRITE );

                    if( fWrite !is null && fWrite.IsOpen() )
                    {
                        validPath = true;
                        fWrite.Write( String::EMPTY_STRING );
                        fWrite.Close();
                    }
                }
                else
                {
                    validPath = true;
                    fRead.Close();
                }
            }

            if( !validPath )
            {
                g_Logger.Log.Error.Print( "Path \"{}\" is invalid for Logger::WriteStream::Set( \"{}\" )", fileName, filePath );
                return false;
            }

            if( Logger::WriteStream::gpStreams.getSize() <= 0 )
                g_Logger.SetCallback( Logger::WriteStream::gpCallback );

            if( g_Logger.Log.Notice.IsActive() )
                g_Logger.Log.Notice.Print( "Start logging at \"svencoop/{}\" )", filePath );

            Logger::WriteStream::gpStreams[ fileName ] = filePath;

            return true;
        }

        bool Del( const string&in fileName )
        {
            bool result = Logger::WriteStream::gpStreams.delete( fileName );

            if( result && Logger::WriteStream::gpStreams.getSize() <= 0 )
                g_Logger.RemoveCallback( Logger::WriteStream::gpCallback );

            return result;
        }

        HookReturnCode gpStream( const Logger::ASLogLevel@ level, const string&in message, bool&out bOverride )
        {
            const array<string> fileNames = Logger::WriteStream::gpStreams.getKeys();
            const uint filesSize = Logger::WriteStream::gpStreams.getSize();

            for( uint ui = 0; ui < filesSize; ui++ )
            {
                auto fileName = fileNames[ui];
                auto filePath = string( Logger::WriteStream::gpStreams[ fileName ] );

                File@ file = g_FileSystem.OpenFile( filePath, OpenFile::OpenFile::APPEND );

                if( file is null )
                {
                    if( g_Logger.Log.Notice.IsActive() )
                        g_Logger.Log.Notice.Print( "Logger::WriteStream::gpStreams[ \"{}\" ] value path \"{}\" ended being null for some reason! removing...", fileName, filePath );
                    
                    Logger::WriteStream::Del( fileName );
                    continue;
                }

                if( file.IsOpen() )
                {
                    file.Write( message );
                }
            }

            return HOOK_CONTINUE;
        }
    }
}
