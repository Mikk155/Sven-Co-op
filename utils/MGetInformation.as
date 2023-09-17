MGetInformation m_ScriptInfo;

class MGetInformation
{
    string GetFullInfo;

    void SetScriptInfo( dictionary m_dInfo )
    {
        string sWiki = string( m_dInfo[ 'wiki' ] );
        string sAscr = string( m_dInfo[ 'script' ] );
        string sAuth = string( m_dInfo[ 'author' ] );
        string sGith = string( m_dInfo[ 'github' ] );
        string sCont = string( m_dInfo[ 'contact' ] );
        string sDesc = string( m_dInfo[ 'description' ] );

        if( sAscr.IsEmpty() || GetFullInfo.Find( sAscr ) != Math.SIZE_MAX )
        {
            return;
        }

        GetFullInfo += '==========================\n';

        GetFullInfo += 'Script: ' + sAscr + '\n\n';

        GetFullInfo += 'Script Wiki: ' + ( !sWiki.IsEmpty() ? sWiki : 'github.com/Mikk155/Sven-Co-op/wiki/' + sAscr ) + '\n\n';

        if( !sDesc.IsEmpty() )
            GetFullInfo += 'Description: ' + sDesc + '\n\n';

        GetFullInfo += 'Author: ' + ( !sAuth.IsEmpty() ? sAuth : 'Mikk' ) + '\n\n';

        GetFullInfo += 'Author Github: github.com/' + ( sGith.IsEmpty() ? 'Mikk155' : sGith ) + '\n\n';

        GetFullInfo += 'Contact info: ' + ( sCont.IsEmpty() ? 'discord.gg/VsNnE3A7j8' : sCont ) + '\n\n';
    }
}

CClientCommand g_InformationCMD( "scriptinfo", "Shows information of initialised scripts", @GetScriptInfo );

void GetScriptInfo( const CCommand@ pArguments )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if( pPlayer !is null && m_ScriptInfo.GetFullInfo != '' )
    {
        m_Message.Print( 'Printed initialised scripts info at your console.', pPlayer, MMessage_CHAT );
        m_Message.Print( m_ScriptInfo.GetFullInfo, pPlayer, MMessage_CONSOLE );
        m_Message.Print( '==========================\n', pPlayer, MMessage_CONSOLE );
    }
}