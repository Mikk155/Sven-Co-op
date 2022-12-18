/*
DOWNLOAD:

scripts/maps/mikk/player_deadchat.as


INSTALL:

#include "mikk/player_deadchat"
OR:
as a plugin. see scripts/maps/mikk/plugins/PlayerDeadChat.as
*/

namespace player_deadchat
{
    CScheduledFunction@ g_PlayerDeadChat = g_Scheduler.SetTimeout( "InitPlayerDeadChat", 0.0f );

    void InitPlayerDeadChat()
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( "player_talk" ) )
        {
            g_Hooks.RemoveHook( Hooks::Player::ClientSay, @DeathChatClientSay );

            g_Hooks.RegisterHook( Hooks::Player::ClientSay, @DeathChatClientSay );
        }
    }

    HookReturnCode DeathChatClientSay( SayParameters@ pParams )
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();

        if( pPlayer.IsAlive() )
            return HOOK_CONTINUE;

        const CCommand@ args = pParams.GetArguments();
        string FullSentence = pParams.GetCommand();

        pParams.ShouldHide = true;

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pDeadPlayers = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( !pDeadPlayers.IsAlive() )
            {
                g_PlayerFuncs.ClientPrint( pDeadPlayers, HUD_PRINTTALK, "[DEAD] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
            }
        }
        return HOOK_CONTINUE;
    }
}
// End of namespace