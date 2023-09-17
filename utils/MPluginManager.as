MPluginManager m_PluginManager;

final class MPluginManager
{
    bool IsPluginInstalled( string m_iszPluginName )
    {
        array<string> PluginsList = g_PluginManager.GetPluginList();

        for( uint ui = 0; ui < PluginsList.length(); ui++ )
        {
            if( PluginsList[ui].ToLowercase() == m_iszPluginName.ToLowercase() )
            {
                m_Debug.Server( "[MPluginManager::IsPluginInstalled] Plugin '" + m_iszPluginName + "' is installed." );
                return true;
            }
        }
        m_Debug.Server( "[MPluginManager::IsPluginInstalled] Plugin '" + m_iszPluginName + "' is NOT installed." );
        return false;
    }
}