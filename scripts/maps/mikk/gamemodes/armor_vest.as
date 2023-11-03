#include '../as_register'
#include '../utils/MEffects'

namespace armor_vest
{
    void MapInit()
    {
        GetCustomModelsConfig();

        g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPreTraceAttack, @armor_vest::MonsterPreTraceAttack );
    }

    HookReturnCode MonsterPreTraceAttack( TraceInfo@ pInfo )
    {
        CBaseMonster@ pVictim = cast<CBaseMonster@>( pInfo.pVictim );
        CBaseEntity@ pInflictor = pInfo.pInflictor;
        float v_fDamage = pInfo.flDamage;
        Vector v_VecDir = pInfo.vecDir;
        TraceResult ptr = pInfo.ptr;
        int v_bitsDamageType = pInfo.bitsDamageType;

        if( pVictim is null )
            return HOOK_CONTINUE;
            
        if( m_dModels.exists( string( pVictim.pev.model ) ) && array<int>( m_dModels[ string( pVictim.pev.model ) ] ).find( ptr.iHitgroup ) >= 0 )
        {
            g_Utility.Sparks( ptr.vecEndPos );
            m_Effect.splash( ptr.vecEndPos, g_Engine.v_forward, 6, 2, 128, 100 );
            pInfo.flDamage *= 0.8;
        }
        return HOOK_CONTINUE;
    }

    dictionary m_dModels;

    void GetCustomModelsConfig()
    {
        string m_iszPathFile = 'scripts/maps/mikk/gamemodes/armor_vest/' + string( g_Engine.mapname ) + '.ini';

        File@ pFile = g_FileSystem.OpenFile( m_iszPathFile, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            @pFile = g_FileSystem.OpenFile( 'scripts/maps/mikk/gamemodes/armor_vest/global_modellist.ini', OpenFile::READ );
        }

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Game.AlertMessage( at_error, '[custom_models] WARNING! Can not open file "scripts/maps/mikk/gamemodes/armor_vest/global_modellist.ini" No custom models loaded.' + '\n' );
            return;
        }

        string line, m_iszModel;
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
                m_iszModel = line;
            }

            if( bReading )
            {
                array<int> m_iHitGroups;

                if( m_dModels.exists( m_iszModel ) )
                {
                    m_iHitGroups = array<int>( m_dModels[ m_iszModel ] );
                }
                m_iHitGroups.insertLast( atoi( line ) );
                m_dModels[ m_iszModel ] = m_iHitGroups;

                g_Game.AlertMessage( at_console, '[custom_models] Added model "' + line + '" for "' + m_iszModel + '"' + '\n' );
            }
        }
        pFile.Close();
    }
}