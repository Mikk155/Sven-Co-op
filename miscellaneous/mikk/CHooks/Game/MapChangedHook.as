namespace Hooks
{
    namespace Game
    {
        namespace MapChangedHook
        {
            funcdef HookReturnCode MapChangedHook( const string& in );

            array<MapChangedHook@> MapChangedHooks;

            bool Register( ref @pFunction )
            {
                MapChangedHook@ pHook = cast<MapChangedHook@>( pFunction );

                if( pHook is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Game::MapChangedHook( const string& in m_iszMapName ) Not found.\n' );
                    return false;
                }
                else
                {
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Game::MapChangedHook( const string& in m_iszMapName ).\n' );

                    MapChangedHooks.insertLast( @pHook );
                    return true;
                }
            }

            void Remove( ref @pFunction )
            {
                MapChangedHook@ pHook = cast<MapChangedHook@>( pFunction );

                if( MapChangedHooks.findByRef( pHook ) >= 0 )
                {
                    MapChangedHooks.removeAt( MapChangedHooks.findByRef( pHook ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Game::MapChanged.\n' );
                }
                else
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Game::MapChanged.\n' );
                }
            }

            void RemoveAll()
            {
                MapChangedHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Game::MapChanged.\n' );
            }

            void MapChangedFunction()
            {
                if( MapChangedHooks.length() < 1 )
                    return;

                string m_iszLatestMap = String::EMPTY_STRING;

                File@ pFileRead = g_FileSystem.OpenFile( 'scripts/maps/store/CHooks_MapChangedHook.txt', OpenFile::READ );

                if( pFileRead !is null && pFileRead.IsOpen() )
                {
                    while( !pFileRead.EOFReached() )
                    {
                        string line;
                        pFileRead.ReadLine( line );

                        if( !line.IsEmpty() )
                        {
                            m_iszLatestMap = line;
                        }
                    }
                    pFileRead.Close();
                }

                File@ pFileWrite = g_FileSystem.OpenFile( 'scripts/maps/store/CHooks_MapChangedHook.txt', OpenFile::WRITE );

                if( pFileWrite !is null && pFileWrite.IsOpen() )
                {
                    pFileWrite.Write( string( g_Engine.mapname ) );
                    pFileWrite.Close();
                }

                for( uint ui = 0; ui < MapChangedHooks.length(); ui++ )
                {
                    MapChangedHook@ pHook = cast<MapChangedHook@>( MapChangedHooks[ui] );

                    if( pHook is null )
                        continue;

                    if( pHook( m_iszLatestMap ) == HOOK_HANDLED )
                        break;
                }
            }
        }
    }
}