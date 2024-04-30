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

/*
    @prefix #include EntityFuncs
    @body #include "${1:../../}mikk/EntityFuncs"
    @description Utilidades relacionadas a entidades
*/
namespace EntityFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [EntityFuncs::'+s+'] '+d+'\n' );}

    /*
        @prefix EntityFuncs EntityFuncs::CreateEntity CreateEntity
        @body EntityFuncs::CreateEntity( dictionary g_Data, bool blSpawnNow = true )
        @description Crea y retorna una entidad con todas las keyvalues que existan en el dictionary g_Data
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
                    Vector VecPos;
                    g_Utility.StringToVector( VecPos, string( g_Data[ 'origin' ] ) );
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

    /*
        @prefix EntityFuncs EntityFuncs::LoadEntFile LoadEntFile
        @body EntityFuncs::LoadEntFile( const string &in m_szPath )
        @description Abre un archivo con formato ripent y crea todas las entidades en el juego.
        @description Retorna el numero de entidades creadas, -1 si el archivo no se pudo abrir.
    */
    int LoadEntFile( const string &in m_szPath )
    {
        File@ pFile = g_FileSystem.OpenFile(
            ( m_szPath.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szPath +
            ( m_szPath.EndsWith( '.ent' ) ? '' : '.ent' ), OpenFile::READ
        );

        if( pFile is null or !pFile.IsOpen() )
        {
            print('LoadEntFile','can not open file "'+m_szPath+'"');
            return -1;
        }

        int ents = 0;
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
                if( CreateEntity( g_Keyvalues ) !is null )
                {
                    ents++;
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

/*
    @prefix EntityFuncs EntityFuncs::CustomKeyValue CustomKeyValue
    @body CustomKeyValue( CBaseEntity@ pEntity, const string&in m_iszKey, const string&in m_iszValue = String::EMPTY_STRING )
    @description Retorna el valor dela custom-key-value
    @description Si m_iszValue es dada el valor se actualizará
    @description Si la entidad es nula retorna String::INVALID_INDEX
    @description Si la entidad no tiene la customkeyvalue retorna String::EMPTY_STRING
*/
string CustomKeyValue( CBaseEntity@ pEntity, const string &in m_iszKey, const string &in m_iszValue = String::EMPTY_STRING )
{
    if( pEntity is null )
    {
        return String::INVALID_INDEX;
    }

    if( m_iszValue != String::EMPTY_STRING )
    {
        g_EntityFuncs.DispatchKeyValue( pEntity.edict(), m_iszKey, m_iszValue );
    }

    if( !pEntity.GetCustomKeyvalues().HasKeyvalue( m_iszKey ) )
    {
        return String::EMPTY_STRING;
    }

    return pEntity.GetCustomKeyvalues().GetKeyvalue( m_iszKey ).GetString();
}
