namespace Server
{
    bool IsPluginInstalled( const string&in plugin_name, bool case_sensitive = false )
    {
        array<string>@ pluginList = g_PluginManager.GetPluginList();

        if( case_sensitive )
        {
            return ( pluginList.find( plugin_name ) >= 0 );
        }

        string plugin_name_lowercase =  plugin_name.ToLowercase();

        for( uint ui = 0; ui < pluginList.length(); ui++ )
        {
            if( pluginList[ui].ToLowercase() == plugin_name_lowercase )
            {
                return true;
            }
        }
        return false;
    }
}
