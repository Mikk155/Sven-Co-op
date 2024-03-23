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

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    Mikk.Hooks.RegisterHook( Hooks::Player::PlayerFlashLight, @PlayerFlashLight );

    pJson.load( "plugins/mikk/CustomFlashLight" );
}

json pJson;

HookReturnCode PlayerFlashLight( CBasePlayer@ pPlayer, const bool FlashlightIsOn, int&out m_iRechargeSpeed, int&out m_iConsumeSpeed )
{
    if( pPlayer !is null )
    {
        m_iRechargeSpeed = pJson[ 'speed recharge', 1 ];
        m_iConsumeSpeed = pJson[ 'speed consume', 1 ];
    }
    return HOOK_CONTINUE;
}