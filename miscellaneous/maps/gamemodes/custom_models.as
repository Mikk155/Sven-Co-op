#include '../as_register'

namespace custom_models
{
    void MapInit()
    {
        GetCustomModelsConfig();

        for( uint ui = 0; ui < m_aModels.length(); ui++ )
        {
            g_Game.PrecacheModel( m_aModels[ui] );
            g_Game.PrecacheGeneric( m_aModels[ui] );
        }

        g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @custom_models::EntityCreated );
    }

    HookReturnCode EntityCreated( CBaseEntity@ pEntity )
    {
        if( pEntity.IsMonster() )
        {
            g_Scheduler.SetTimeout( 'EntityCreatedDelayed', 0, EHandle( pEntity ) );
        }
        return HOOK_CONTINUE;
    }

    void EntityCreatedDelayed( EHandle hMonster )
    {
        CBaseEntity@ pEntity = hMonster.GetEntity();

        if( pEntity !is null && m_dModels.exists( string( pEntity.pev.model ) ) )
        {
            array<string> m_aGetModels = array<string>( m_dModels[ string( pEntity.pev.model ) ] );
			int m_iSequence = pEntity.pev.sequence;
			Vector m_vMinhullSize = pEntity.pev.mins;
			Vector m_vMaxhullSize = pEntity.pev.maxs;
			g_EntityFuncs.SetModel( pEntity,  m_aGetModels[ Math.RandomLong( 0, m_aGetModels.length() -1 ) ] );
			g_EntityFuncs.SetSize( pEntity.pev, m_vMinhullSize, m_vMaxhullSize );
			pEntity.pev.sequence = m_iSequence;
        }
    }

    dictionary m_dModels;
    array<string> m_aModels;

    void GetCustomModelsConfig()
    {
        string m_iszPathFile = 'scripts/maps/mikk/gamemodes/custom_models/' + string( g_Engine.mapname ) + '.ini';

        File@ pFile = g_FileSystem.OpenFile( m_iszPathFile, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            @pFile = g_FileSystem.OpenFile( 'scripts/maps/mikk/gamemodes/custom_models/global_modellist.ini', OpenFile::READ );
        }

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Game.AlertMessage( at_error, '[custom_models] WARNING! Can not open file "scripts/maps/mikk/gamemodes/custom_models/global_modellist.ini" No custom models loaded.' + '\n' );
            return;
        }

        string line;
        string m_iszClassname;
        bool bReading = false;

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            line.Replace( ' ', String::EMPTY_STRING );

            if( line.Length() < 1 || line[0] == ';' )
                continue;

            if( line[0] == '{' )
            {
                bReading = true;
                continue;
            }
            else if( line[0] == '}' )
            {
                bReading = false;
            }

            if( !bReading )
            {
                m_iszClassname = line;
            }

            if( bReading && line.EndsWith( '.mdl' ) && line.StartsWith( 'models/' ) )
            {
                if( m_dModels.exists( m_iszClassname ) )
                {
                    array<string> m_aNewModels = array<string>( m_dModels[ m_iszClassname ] );

                    m_aNewModels.insertLast( line );

                    m_dModels[ m_iszClassname ] = m_aNewModels;
                }
                else
                {
                    array<string> m_aNewModels = { line };

                    m_dModels[ m_iszClassname ] = m_aNewModels;
                }
                m_aModels.insertLast( line );
                g_Game.AlertMessage( at_console, '[custom_models] Added model "' + line + '" for "' + m_iszClassname + '"' + '\n' );
            }
        }
        pFile.Close();
    }
}