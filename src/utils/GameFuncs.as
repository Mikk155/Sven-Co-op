namespace GameFuncs
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [PlayerFuncs::'+s+'] '+d+'\n' );}

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

    void UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
    {
        if( pTimer !is null )
        {
            g_Scheduler.RemoveTimer( pTimer );
        }

        @pTimer = g_Scheduler.SetInterval( szFunction, flTime, iRepeat );
    }
}
