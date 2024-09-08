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

// actionsounds radius (radius)

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    Mikk.Utility.UpdateTimer( pThink, "Think", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES );
    pJson.load('plugins/mikk/ActionSounds.json');
}

json pJson;

int radius = 1024;

Vector VecPos;

void SetPos( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
        VecPos = pPlayer.pev.origin;
    else
        VecPos = g_vecZero;
}

void SPK( string sfx )
{
    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

        if( pPlayer !is null && pPlayer.IsConnected() )
        {
            if( radius == 0 || ( VecPos - pPlayer.pev.origin ).Length() < radius )
            {
                m_PlayerFuncs.ExecCommand( pPlayer, 'spk "' + sfx + '"' );
            }
        }
    }
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if( pPlayer !is null )
    {
        SetPos(pPlayer);

        if( !pJson[ 'PlayerKilled', {} ][ pAttacker.pev.classname ].IsEmpty() )
        {
            SPK( pJson[ 'PlayerKilled', {} ][ pAttacker.pev.classname ] );
        }

        else if( !sniper.IsEmpty() && pAttacker !is null && pAttacker.pev.classname == 'monster_male_assassin' && pAttacker.pev.weapons >= 8
        or !sniper.IsEmpty() && pAttacker !is null && pAttacker.pev.classname == 'monster_human_grunt' && pAttacker.pev.weapons >= 128 )
        {
            SPK( sniper, x );
        }
        else if( sfx_gibbed.length() > 0 && iGib == GIB_ALWAYS )
        {
            SPK( sfx_gibbed[Math.RandomLong(0,sfx_gibbed.length()-1)], x );
        }
        else if( sfx_killed.length() > 0 )
        {
            SPK( sfx_killed[Math.RandomLong(0,sfx_killed.length()-1)], x );
        }
    }
}

CClientCommand CMD( "actionsounds", "Set actionsounds mode", @Command, ConCommandFlag::AdminOnly );

void Command( const CCommand@ args )
{
    CBasePlayer@ g_ConCommandSystem.GetCurrentPlayer();

    if( args[1] == "radius" )
    {
        radius = atoi( args[2] );
    }
}

CScheduledFunction@ pThink;

void Think()
{
}