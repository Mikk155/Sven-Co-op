namespace EntityFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [EntityFuncs::'+s+'] '+d+'\n' );}

    CBaseEntity@ CreateEntity( string szClassname, dictionary pkvd, bool blSpawnNow = true )
    {
        pkvd[ "classname" ] = szClassname;
        return CreateEntity( pkvd, blSpawnNow );
    }

    CBaseEntity@ CreateEntity( dictionary pkvd, bool blSpawnNow = true )
    {
        if( pkvd.exists( 'classname' ) )
        {
            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( pkvd[ 'classname' ] ), pkvd, blSpawnNow );

            if( pEntity !is null )
            {
                if( pkvd.exists( 'origin' ) )
                {
                    Vector VecPos;
                    g_Utility.StringToVector( VecPos, string( pkvd[ 'origin' ] ) );
                    g_EntityFuncs.SetOrigin( pEntity, VecPos );
                }

                if( blSpawnNow )
                {
                    g_EntityFuncs.DispatchSpawn( pEntity.edict() );
                }
                return pEntity;
            }
        }
        else
        {
            print('CreateEntity','No classname field given!');
        }

        return null;
    }


    void PrecacheCustom( string m_szClassname, dictionary pkvd )
    {
        pkvd[ "classname" ] = m_szClassname;
        PrecacheCustom( pkvd );
    }

    void PrecacheCustom( dictionary pkvd )
    {
        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( pkvd[ 'classname' ] ), pkvd, false );

        if( pEntity !is null )
        {
            pEntity.Precache();
            pEntity.pev.flags |= FL_KILLME;
        }
    }

    array<int> LoadEntFile( const string &in m_szPath )
    {
        array<int> ents;

        File@ pFile = g_FileSystem.OpenFile(
            ( m_szPath.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szPath +
            ( m_szPath.EndsWith( '.ent' ) ? '' : '.ent' ), OpenFile::READ
        );

        if( pFile is null or !pFile.IsOpen() )
        {
            print('LoadEntFile','can not open file "'+m_szPath+'"');
            return ents;
        }

        string line, key, value;
        dictionary g_Keyvalues;

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '{' )
            {
                continue;
            }

            if( line[0] == '}' )
            {
                CBaseEntity@ pEntity = CreateEntity( g_Keyvalues );

                if( pEntity !is null )
                {
                    ents.insertLast( pEntity.entindex() );
                }

                g_Keyvalues.deleteAll();
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            g_Keyvalues[ key ] = value;
        }
        pFile.Close();

        return ents;
    }
}
