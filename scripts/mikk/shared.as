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

#include "fft"
#include "json"
#include "Hooks"
#include "Language"
#include "Reflection"
#include "PlayerFuncs"
#include "EntityFuncs"

MKShared Mikk;

class MKShared
{
    /*@
        @prefix Mikk.GetDiscord Discord
        @body Mikk
        Get discord server invite
    */
    string GetDiscord()
    {
        return 'discord.gg/sqK7F3kZfn';
    }

    /*@
        @prefix Mikk.GetContactInfo Contact
        @body Mikk
        Get contact info
    */
    string GetContactInfo()
    {
        return GetDiscord() + " | github.com/Mikk155";
    }

    MKHooks Hooks;
    MKLanguage Language;
    MKPlayerFuncs PlayerFuncs;
    MKEntityFuncs EntityFuncs;

    MKShared()
    {
        Hooks = MKHooks();
        Language = MKLanguage();
        PlayerFuncs = MKPlayerFuncs();
        EntityFuncs = MKEntityFuncs();
    }

    /*@
        @prefix Mikk.UpdateTimer UpdateTimer
        @body Mikk
        Clears and sets a CScheduledFunction@ function with the given parameters
    */
    void UpdateTimer( CScheduledFunction@ &out pTimer, string &in szFunction, float flTime, int iRepeat = 0 )
    {
        if( pTimer !is null )
        {
            g_Scheduler.RemoveTimer( pTimer );
        }

        @pTimer = g_Scheduler.SetInterval( szFunction, flTime, iRepeat );
    }

    /*@
        @prefix Mikk.IsPluginInstalled IsPluginInstalled Plugin Installed IsInstalled
        @body Mikk
        Return whatever the given plugin name is installed on the server.
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
}

/*@
    @prefix CKV CustomKeyValue
    Return the value of the given CustomKeyValue,
    if m_iszValue is given it will update the value,
    return String::INVALID_INDEX if the given entity is null,
    return String::EMPTY_STRING if the given entity doesn't have the custom key value
*/
string CustomKeyValue( CBaseEntity@ pEntity, const string&in m_iszKey, const string&in m_iszValue = String::EMPTY_STRING )
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
