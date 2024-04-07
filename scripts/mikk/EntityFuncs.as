//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

class MKEntityFuncs
{
    /*
        @prefix Mikk.EntityFuncs.CreateEntity CreateEntity EntityCreate
        @body Mikk.EntityFuncs
        Creates a entity with the given keyvalue data, if blSpawnNow is false the entity is not spawned
    */
    CBaseEntity@ CreateEntity( dictionary g_Data, bool blSpawnNow = true )
    {
        if( g_Data.exists( 'classname' ) )
        {
            CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_Data[ 'classname' ] ), g_Data, blSpawnNow );

            if( pEntity !is null )
            {
                if( g_Data.exists( 'origin' ) )
                {
                    g_EntityFuncs.SetOrigin( pEntity, atov( string( g_Data[ 'origin' ] ) ) );
                }
                if( blSpawnNow )
                {
                    g_EntityFuncs.DispatchSpawn( pEntity.edict() );
                }
                return pEntity;
            }
        }
        return null;
    }

    /*
        @prefix Mikk.EntityFuncs.LoadEntFile LoadEntFile
        @body Mikk.EntityFuncs
        Loads an external .ent file into the map
    */
    bool LoadEntFile( const string &in m_szPath )
    {
        File@ pFile = g_FileSystem.OpenFile(
            ( m_szPath.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szPath +
            ( m_szPath.EndsWith( '.ent' ) ? '' : '.ent' ), OpenFile::READ
        );

        if( pFile is null or !pFile.IsOpen() )
        {
            return false;
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
                Mikk.EntityFuncs.CreateEntity( g_Keyvalues );

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

        return true;
    }
}