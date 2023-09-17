MMessage m_Message;

final class MMessage
{
    void Print( const string& in m_iszMessage, CBasePlayer@ pPlayer = null, int m_uiMessageType = MMessage_CONSOLE )
    {
        if( pPlayer !is null )
        {
            gPrintTo( m_iszMessage, pPlayer, m_uiMessageType );
            return;
        }

            
        for( int eidx = 2; eidx <= g_Engine.maxClients; eidx++ )
        {
            CBasePlayer@ pEveryone = g_PlayerFuncs.FindPlayerByIndex( eidx );

            if( pEveryone is null )
                continue;

            gPrintTo( m_iszMessage, pPlayer, m_uiMessageType );
        }
    }

    void gPrintTo( string m_iszMessage, CBasePlayer@ pPlayer = null, int m_uiMessageType = MMessage_CONSOLE )
    {
        if( pPlayer is null )
            return;

        if( m_uiMessageType == MMessage_CHAT )
        {
            while( m_iszMessage != '' )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD( MMessage_CHAT ), m_iszMessage.SubString( 0, 95 ) + ( m_iszMessage.Length() <= 95 ? '\n' : '-' ) );

                if( m_iszMessage.Length() <= 95 ) m_iszMessage = '';
                else m_iszMessage = m_iszMessage.SubString( 95, m_iszMessage.Length() );
            }
        }

        if( m_uiMessageType == MMessage_CONSOLE )
        {
            while( m_iszMessage != '' )
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD( MMessage_CONSOLE ), m_iszMessage.SubString( 0, 68 ) );

                if( m_iszMessage.Length() <= 68 ) m_iszMessage = '';
                else m_iszMessage = m_iszMessage.SubString( 68, m_iszMessage.Length() );
            }
        }

        // -todo debug limit
        if( m_uiMessageType == MMessage_CENTER )
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD( MMessage_CENTER ), m_iszMessage + '\n' );
        }

        if( m_uiMessageType == MMessage_NOTIFY )
        {
            g_PlayerFuncs.ClientPrint( pPlayer, HUD( MMessage_NOTIFY ), m_iszMessage + '\n' );
        }
    }
}

enum MMessage_TYPE
{
    MMessage_NOTIFY = 1,
    MMessage_CONSOLE = 2,
    MMessage_CHAT = 3,
    MMessage_CENTER = 4,
}