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

DataShared gpDataShared;

array<string> DataShared_e =
{
    "AntiClip",
    "dynamic_hostname",
    "DynamicDifficultyDeluxe"
};

class DataShared
{
    /*@
        @prefix DataShared Shared Data Plugin
        @body gpDataShared
        Return the value of the given key for this plugin, if szValue is set it will be updated. if szFrom is set is the plugin name
    */
    string opIndex( const string &in szKey, string szValue = '', string szFrom = String::EMPTY_STRING )
    {
        return GetValue( szKey, szValue, szFrom );
    }

    protected string szThisPlugin = g_Module.GetModuleName();

    protected string GetValue( const string &in szKey, string szValue = '', string szFrom = String::EMPTY_STRING )
    {
        int index = DataShared_e.find( ( szFrom != '' ? szFrom : szThisPlugin ) );

        if( index >= 0 )
        {
            string szCustomKeyValue = '$s_' + string( index ) + '_' + szKey;

            if( szValue != '' )
            {
                return CustomKeyValue( GetEntity(), szCustomKeyValue, szValue );
            }
            else
            {
                return CustomKeyValue( GetEntity(), szCustomKeyValue );
            }
        }

        return String::EMPTY_STRING;
    }

    protected CBaseEntity@ GetEntity()
    {
        CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( null, 'datashared_plugins' );

        if( pEnt is null )
        {
            @pEnt = Mikk.EntityFuncs.CreateEntity( { { 'classname', 'info_target' }, { 'targetname', 'datashared_plugins' } } );
        }

        return @pEnt;
    }
}
