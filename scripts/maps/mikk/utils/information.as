CGetInformation g_ScriptInfo;

class CGetInformation
{
    string ScriptName( string& in iszScript = '' )
    {
        return ( !iszScript.IsEmpty() ? '\nScript: ' + iszScript + '\n' : '' );
    }

    string Description( string& in iszDescription = '' )
    {
        return ( !iszDescription.IsEmpty() ? '\nDescription: ' + iszDescription + '\n' : '' );
    }

    string Wiki( string& in iszPage = '' )
    {
        return ( !iszPage.IsEmpty() ? '\nScript Wiki: ' + 'https://github.com/Mikk155/Sven-Co-op/wiki/' + iszPage + '\n' : '' );
    }

    string Author( string& in iszAuthor = '' )
    {
        return ( !iszAuthor.IsEmpty() ? '\nScript Author: ' + iszAuthor + '\n' : '' );
    }

    string GetDiscord()
    {
        return '\nDiscord Server: ' + 'discord.gg/VsNnE3A7j8' + '\n';
    }

    string GetGithub( string& in iszUser = '' )
    {
        return '\nAuthor Github: github.com/' + ( !iszUser.IsEmpty() ? iszUser : 'Mikk155' ) + '\n';
    }
    
    void SetInformation( string& in iszInformation = '' )
    {
        if( iszInformation != '' )
        {
            strInformation.insertLast( '==========================\n' + iszInformation + '\n' );
        }
    }
    array<string> strInformation();
}

CClientCommand g_InformationCMD( "scriptinfo", "Shows information of initialised scripts", @GetScriptInfo );

void GetScriptInfo( const CCommand@ pArguments )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    string iszInfo;

    for (uint i = 0; i < g_ScriptInfo.strInformation.length(); i++)
    {
        iszInfo = iszInfo + g_ScriptInfo.strInformation[i];
    }

    if( iszInfo != '' )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[GetScriptInfo] Printed initialised scripts info at your console.\n" );

        while( iszInfo != '' )
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  iszInfo.SubString( 0, 68 ) );

            if( iszInfo.Length() <= 68 ) iszInfo = '';
            else iszInfo = iszInfo.SubString( 68, iszInfo.Length() );
        }
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE,  '==========================\n' );
    }
}