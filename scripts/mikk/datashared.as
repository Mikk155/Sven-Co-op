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
    @prefix #include datashared
    @body #include "${1:../../}mikk/datashared"
    @description Utilidad utilizada para hacer que cualquier plugin pueda enviar informacion a otros plugins mediante la trasnferencia de dictionary
*/
namespace datashared
{
    /*
        @prefix datashared datashared::GetDataClass GetDataClass shared
        @body datashared::GetDataClass()
        @description Obten la instancia CSharedDataPlugins@ presente, si no existe una nueva será creada
    */
    CSharedDataPlugins@ GetDataClass()
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( 'data_shared' ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( 'datashared::CSharedDataPlugins', 'data_shared' );
        }

        CBaseEntity@ pDataEnt = g_EntityFuncs.FindEntityByClassname( null, 'data_shared' );

        if( pDataEnt is null )
        {
            @pDataEnt = g_EntityFuncs.Create( 'data_shared', g_vecZero, g_vecZero, false );
        }

        if( pDataEnt is null )
        {
            return null;
        }

        CSharedDataPlugins@ pDataClass = cast<CSharedDataPlugins@>( CastToScriptClass( pDataEnt ) );

        if( pDataClass is null )
        {
            return null;
        }

        return @pDataClass;
    }

    /*
        @prefix datashared datashared::GetData GetData shared
        @body datashared::GetData( const string szPlugin = String::EMPTY_STRING )
        @description Obten el dictionary correspondiente a el plugin con el nombre szPlugin
        @description Si ningun nombre es utilizado, se utilizara el nombre del archivo del plugin que este usando esta funcion
    */
    dictionary GetData( const string szPlugin = String::EMPTY_STRING )
    {
        string szLabel = ( szPlugin == String::EMPTY_STRING ? g_Module.GetModuleName() : szPlugin );

        CSharedDataPlugins@ pData = GetDataClass();

        if( pData !is null )
        {
            return dictionary( pData.gpData[ szLabel ] );
        }

        return {};
    }

    /*
        @prefix datashared datashared::SetData SetData shared
        @body datashared::SetData( dictionary pNewData, const string szPlugin = String::EMPTY_STRING )
        @description Actualiza el dictionario del plugin szPlugin
        @description Retorna una copia del dictionario luego de haber sido guardado
        @description Si ningun nombre es utilizado, se utilizara el nombre del archivo del plugin que este usando esta funcion
    */
    dictionary SetData( dictionary pNewData, const string szPlugin = String::EMPTY_STRING )
    {
        string szLabel = ( szPlugin == String::EMPTY_STRING ? g_Module.GetModuleName() : szPlugin );

        CSharedDataPlugins@ pData = GetDataClass();
        dictionary gOldData = {};

        if( pData !is null )
        {
            gOldData = dictionary( pData.gpData[ szLabel ] );
            pData.gpData[ szLabel ] = pNewData;
        }

        return gOldData;
    }

    class CSharedDataPlugins : ScriptBaseEntity
    {
        dictionary gpData;
    }
}
