#include '../mikk/as_register'

namespace entities_state
{
    void Meta( int i )
    {
        // Un-comment if you're using Gaftherman's Limitless Potential AngelScript Extended Metamod plugin.
        ///*
        switch(i)
        {
            case 0:
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::KeyValue, @entities_state::KeyValue );
                    Metamod = true;
                        break;
            case 1:
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::KeyValue, @entities_state::KeyValue );
                    break;
        }
        //*/
    }

    void increase_state( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float delay )
    {
        m_iCurrentState++;
        StateWritte( m_iCurrentState );
    }

    bool Metamod;
    void MapInit()
    {
        StateRead();
        Meta( 0 );
    }

    HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result )
    {
        if( pszKey == '$i_entity_state' && atoi( pszValue ) > 0  )
        {
            eidx.insertLast( pEntity.entindex() );
        }
        return HOOK_CONTINUE;
    }

    array<int> eidx;

    void MapActivate()
    {
        CBaseEntity@ pEntity = null;

        if( Metamod )
        {
            for( uint i = 0; i < eidx.length(); i++ )
                CheckEntity( g_EntityFuncs.Instance( eidx[i] ) );
        }
        else
        {
            for( int i = g_Engine.maxClients + 2; i <= g_EngineFuncs.NumberOfEntities(); ++i ) 
                CheckEntity( g_EntityFuncs.Instance( i ) );
        }
        Meta( 1 );
    }

    void CheckEntity( CBaseEntity@ pEntity )
    {
        if( pEntity is null )
            return;

        int iState = atoi( pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_entity_state' ).GetString() );

        if( iState > 0 && iState == m_iCurrentState )
        {
            switch( atoi( pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_entity_state_action' ).GetString() ) )
            {
                case ES_USE_ON:
                {
                    pEntity.Use( null, null, USE_ON, 0.0f );
                    break;
                }
                case ES_USE_OFF:
                {
                    pEntity.Use( null, null, USE_OFF, 0.0f );
                    break;
                }
                case ES_USE_KILL:
                {
                    g_EntityFuncs.Remove( pEntity );
                    break;
                }
                case ES_KILLED:
                {
                    pEntity.Killed( null, GIB_ALWAYS );
                    break;
                }
            }
        }
    }

    enum ENTITIES_STATE
    {
        ES_NONE = 0,
        ES_USE_ON = 1,
        ES_USE_OFF = 2,
        ES_USE_KILL = 3,
        ES_KILLED = 4
    }

    int m_iCurrentState = ES_NONE;

    void StateRead()
    {
        File@ pFile = g_FileSystem.OpenFile( 'scripts/maps/store/entities_state.txt', OpenFile::READ );

        if( pFile !is null && pFile.IsOpen() )
        {
            string line;
            while( !pFile.EOFReached() )
            {
                pFile.ReadLine( line );

                if( line.Length() > 0 )
                {
                    array<string> pArguments = line.Split( ',' );

                    if( pArguments.length() == 2 )
                    {
                        m_iCurrentState = atoi( pArguments[1] );

                        if( pArguments[0] != string( g_Engine.mapname ) )
                        {
                            StateWritte( 0 );
                        }
                    }
                }
            }
            pFile.Close();
        }
    }

    void StateWritte( const int NewState )
    {
        File@ pFile = g_FileSystem.OpenFile( 'scripts/maps/store/entities_state.txt', OpenFile::WRITE );

        if( pFile !is null && pFile.IsOpen() )
        {
            string line = string( g_Engine.mapname ) + ',' + string( NewState );
            pFile.Write( line );
            pFile.Close();
        }
    }
}