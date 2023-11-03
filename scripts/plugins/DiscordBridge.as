/*
#include '../maps/mikk/as_utils'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    g_EngineFuncs.DiscordToServer( "/api/channels/1142699914678239257/messages", "Authorization: Bot OTM4MjgzMTI0MTYzNDg5OTAz.GAPpUD.K9zgZZcDYYTmF1P20qgYXlWkH2XxRmlBTh319I\r\n" );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::ASLP::Discord::DiscordChatBridge, @DiscordChatBridge );
}

HookReturnCode DiscordChatBridge( discord_message@ pDiscord )
{
    discord_author@ pAuthor = pDiscord.author;

    if( pAuthor !is null )
    {
        string m_iszMessage = pDiscord.content;

        // username
        string m_iszUserName = pAuthor.username;

        // Modified nickname on the server.
        string m_iszGlobalName = pAuthor.global_name;

        if( !m_iszGlobalName.IsEmpty() && !m_iszMessage.IsEmpty() )
        {
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, '[Discord] ' + m_iszUserName + ': ' + m_iszMessage + '\n' );
        }
    }

    return HOOK_CONTINUE;
}

string m_iszPlayer;

HookReturnCode ClientSay( SayParameters@ pParams )
{
    const CCommand@ args = pParams.GetArguments();
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( pPlayer is null || pParams.ShouldHide == true )
        return HOOK_CONTINUE;

    const string m_iszMessage = args.GetCommandString();

    if( m_iszMessage.IsEmpty() )
        return HOOK_CONTINUE;

    string m_iszSendMessage;

    if( m_iszPlayer != pPlayer.pev.netname )
    {
        m_iszPlayer = pPlayer.pev.netname;

        if( !pPlayer.IsAlive() )
        {
            m_iszPlayer += ' :skull_crossbones:';
        }

        m_iszSendMessage = '**' + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) + ' ' + m_iszPlayer + ':**\\n';
    }

    m_iszSendMessage += m_iszMessage;

    if( m_iszSendMessage.Find( '@everyone' ) != String::INVALID_INDEX )
    {
        m_iszSendMessage.Replace( '@everyone', '<:PepePingREE:734516575012520057>' );
    }

    g_EngineFuncs.ServerToDiscord
    (
        "1169814356947636315/nu5XsEpsMKBOOXSeBo1erXcRP_QyhyrWpHjsQH6Lh4Qa75sI1F73E8jemzbyr_Uuv3BX",
        "{\"username\": \"" + g_EngineFuncs.CVarGetString( 'hostname' ) +
        "\",\"content\": \"" + m_iszSendMessage +
        "\",\"embeds\": [], \"attachments\": []}"
    );
    return HOOK_CONTINUE;
}

const string m_iszBotToken = 'MTEyNTAxOTQ1NTAzNTAyMzQ0MA.Gfl_oP.Dz0zZYcRDm2Y5I0Ec29OWtG_q90pqLy7SdSIIQ';
const string m_iszWebHook = '/api/webhooks/1169814356947636315/nu5XsEpsMKBOOXSeBo1erXcRP_QyhyrWpHjsQH6Lh4Qa75sI1F73E8jemzbyr_Uuv3BX';
const string m_iszChannelID = '1169815735254667325';
string m_iszBotName = g_EngineFuncs.CVarGetString( 'hostname' );
string m_iszBotMessage;
const string m_iszToDiscord = "{\"username\": \"" + m_iszBotName + "\",\"content\": \"" + m_iszBotMessage + "\",\"embeds\": [], \"attachments\": []}";
*/