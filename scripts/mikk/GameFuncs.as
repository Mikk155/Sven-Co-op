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
    @prefix #include GameFuncs
    @body #include "${1:../../}mikk/GameFuncs"
    @description Utilidades sin aparente relacion
*/
namespace GameFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [PlayerFuncs::'+s+'] '+d+'\n' );}

    /*
        @prefix GameFuncs GameFuncs::IsPluginInstalled IsPluginInstalled plugin
        @body GameFuncs::IsPluginInstalled( string m_iszPluginName, bool bCaseSensitive = false )
        @description Retorna si el plugin esta instalado
    */
    bool IsPluginInstalled( string m_iszPluginName, bool bCaseSensitive = false )
    {
        array<string> PluginsList = g_PluginManager.GetPluginList();

        if( bCaseSensitive )
        {
            return ( PluginsList.find( m_iszPluginName ) >= 0 );
        }

        for( uint ui = 0; ui < PluginsList.length(); ui++ )
        {
            if( PluginsList[ui].ToLowercase() == m_iszPluginName.ToLowercase() )
            {
                return true;
            }
        }
        return false;
    }

    /*
        @prefix GameFuncs GameFuncs::UpdateTimer schedule
        @body GameFuncs::UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
        @description Actualiza un timer rapidamente
    */
    void UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
    {
        if( pTimer !is null )
        {
            g_Scheduler.RemoveTimer( pTimer );
        }

        @pTimer = g_Scheduler.SetInterval( szFunction, flTime, iRepeat );
    }
}
