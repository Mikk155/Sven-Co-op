#include "utils/mapblacklist"

const string iszConfigFile = 'scripts/plugins/mikk/deadchat_players.txt';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

bool bInitialised;

void MapInit()
{
    mapblacklist( iszConfigFile, bInitialised );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( !bInitialised && pPlayer !is null && !pPlayer.IsAlive() && !pParams.ShouldHide )
    {
        const CCommand@ args = pParams.GetArguments();
        string FullSentence = pParams.GetCommand();

        if( !FullSentence.IsEmpty() )
        {
            pParams.ShouldHide = true;

            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pDead = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pDead !is null && !pDead.IsAlive() )
                {
                    g_PlayerFuncs.ClientPrint( pDead, HUD_PRINTTALK, "[DEAD CHAT] "+pPlayer.pev.netname+": "+FullSentence+"\n" );
                }
            }
        }
    }
    return HOOK_CONTINUE;
}