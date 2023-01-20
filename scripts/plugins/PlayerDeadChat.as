/*
DOWNLOAD:

scripts/plugins/mikk/PlayerDeadChat.as


INSTALL:

    "plugin"
    {
        "name" "PlayerDeadChat"
        "script" "PlayerDeadChat"
    }
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nGithub: github.com/Mikk155"
        "\nDescription: Make dead player's messages readable for dead players only."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
    );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @PlayerDeadChat::ClientSay );
}

namespace PlayerDeadChat
{
    HookReturnCode ClientSay( SayParameters@ pParams )
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