MPlayerFuncs m_PlayerFuncs;

final class MPlayerFuncs
{
    void ExecCommand( CBasePlayer@ pPlayer, const string_t m_iszCommand )
    {
        if( pPlayer is null )
            return;

        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( ';' + m_iszCommand + ';' );
        msg.End();

        m_Debug.Server( '[CPlayerFuncs::ExecCommand] Executed Cvar "' + m_iszCommand + '" for player "' + pPlayer.pev.netname + '"', DEBUG_LEVEL_ALMOST );
    }

    void ExecCommandAll( const string_t m_iszCommand )
    {
        NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
            msg.WriteString( ';' + m_iszCommand + ';' );
        msg.End();

        m_Debug.Server( '[CPlayerFuncs::ExecCommand] Executed Cvar "' + m_iszCommand + '" for all players', DEBUG_LEVEL_ALMOST );
    }

    void ShowMOTD( CBasePlayer@ pPlayer, const string szTitle, const string szMessage )
    {
        m_ScriptInfo.SetScriptInfo
        (
            {
                { 'script', 'ShowMOTD' },
                { 'description', 'Shows a MOTD Pop-up' },
                { 'author', 'Giegue' },
                { 'github', 'JulianR0' },
                { 'contact', 'www.steamcommunity.com/id/ngiegue' }
            }
        );

        if( pPlayer is null )
            return;

        NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        title.WriteString( szTitle );
        title.End();

        uint iChars = 0;
        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        for( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
            iChars++;
            if( iChars == 32 )
            {
                NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                message.WriteByte( 0 );
                message.WriteString( szSplitMsg );
                message.End();
                
                iChars = 0;
            }
        }

        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );
            NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
            fix.WriteByte( 0 );
            fix.WriteString( szSplitMsg );
            fix.End();
        }

        NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
        endMOTD.WriteByte( 1 );
        endMOTD.WriteString( "\n" );
        endMOTD.End();

        NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
        restore.End();
    }

    CBasePlayer@ FindPlayerBySteamID( string &in SteamID )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() && SteamID == string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) )
            {
                return @pPlayer;
            }
        }

        return null;
    }

    string GetSteamID( CBasePlayer@ pPlayer )
    {
        if( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) == 'BOT' )
            return 'BOT:' + string( pPlayer.entindex() );
        return g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
    }
}