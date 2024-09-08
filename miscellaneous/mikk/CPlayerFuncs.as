// Better be using these instead of integers because they will change at any moment.-Mikk
enum CMKPlayerFuncs_enum
{
    CMKPlayerFuncs_ALL_PLAYERS = 0,
    CMKPlayerFuncs_PRINT_CHAT,
    CMKPlayerFuncs_PRINT_BIND,
    CMKPlayerFuncs_PRINT_HUD,
    CMKPlayerFuncs_PRINT_CONSOLE,
    CMKPlayerFuncs_PRINT_CENTER,
    CMKPlayerFuncs_PRINT_NOTIFY,
};

class CMKPlayerFuncs
{
    string FixValue( dictionaryValue@ pValue )
    {
        return string( string_t( string( pValue ) ) );
    }

    string GetLanguage( CBasePlayer@ pPlayer, dictionary@ g_Languages )
    {
        if( pPlayer !is null )
        {
            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$s_language' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$s_language', 'english' );
            }

            string m_iszLanguage = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$s_language' ).GetString();

            if( string( g_Languages[ m_iszLanguage ] ) != '' )
            {
                return FixValue( g_Languages[ m_iszLanguage ] );
            }
            return FixValue( g_Languages[ m_iszLanguage ] );
        }
        return String::EMPTY_STRING;
    }

    void ScheduledPrint( CBasePlayer@ pPlayer, dictionary g_Message, CMKPlayerFuncs_enum MSG_ENUM = CMKPlayerFuncs_PRINT_CHAT, dictionary@ rArgs = null )
    {
        PrintMessage( pPlayer, g_Message, MSG_ENUM, false, rArgs );
    }

    void PrintMessage( CBasePlayer@ pCaller, dictionary g_Message, CMKPlayerFuncs_enum MSG_ENUM = CMKPlayerFuncs_PRINT_CHAT, bool bAllPlayers = false, dictionary@ rArgs = null )
    {
        if( bAllPlayers )
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null && pPlayer !is pCaller )
                {
                    ScheduledPrint( pPlayer, g_Message, MSG_ENUM, rArgs );
                }
            }
            return;
        }

        if( pCaller is null )
        {
            return;
        }

        string iszMessageString = mk.PlayerFuncs.GetLanguage( pCaller, g_Message );

        if( rArgs !is null )
        {
            const array<string> Args = rArgs.getKeys();

            for( uint i = 0; i < Args.length(); i++ )
            {
                iszMessageString.Replace( Args[i], string( rArgs[ Args[i] ] ) );
            }
        }

        switch( MSG_ENUM )
        {
            case CMKPlayerFuncs_PRINT_CHAT:
            {
                string m_iszMessage = iszMessageString;

                // HACK for max limit chars
                while( m_iszMessage != '' )
                {
                    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTTALK, m_iszMessage.SubString( 0, 95 ) + ( m_iszMessage.Length() <= 95 ? '\n' : '-' ) );

                    if( m_iszMessage.Length() <= 95 )
                    {
                        m_iszMessage = '';
                    }
                    else
                    {
                        m_iszMessage =  ' -' + m_iszMessage.SubString( 95, m_iszMessage.Length() );
                    }
                }
                break;
            }
            case CMKPlayerFuncs_PRINT_BIND:
            {
                g_PlayerFuncs.PrintKeyBindingString( pCaller, iszMessageString + '\n' );
                break;
            }
            case CMKPlayerFuncs_PRINT_HUD:
            {
                g_PlayerFuncs.HudMessage( pCaller, textParams( g_Message ), iszMessageString + "\n" );
                break;
            }
            case CMKPlayerFuncs_PRINT_CONSOLE:
            {
                string m_iszMessage = iszMessageString;

                // HACK for max limit chars
                while( m_iszMessage != '' )
                {
                    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, m_iszMessage.SubString( 0, 126 ) + ( m_iszMessage.Length() <= 126 ? '\n' : '-' ) );

                    if( m_iszMessage.Length() <= 126 )
                    {
                        m_iszMessage = '';
                    }
                    else
                    {
                        m_iszMessage = ' -' + m_iszMessage.SubString( 126, m_iszMessage.Length() );
                    }
                }
                break;
            }
            case CMKPlayerFuncs_PRINT_CENTER:
            {
                g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCENTER, iszMessageString + '\n' );
                break;
            }
            case CMKPlayerFuncs_PRINT_NOTIFY:
            {
                g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTNOTIFY, iszMessageString + '\n' );
                break;
            }
        }
    }

    HUDTextParams textParams( dictionary g_Params )
    {
        HUDTextParams pParams;

        pParams.channel = ( g_Params.exists( 'channel' ) ? atoi( string( g_Params['channel'] ) ) : 3 );
        pParams.x = ( g_Params.exists( 'x' ) ? atof( string( g_Params['x'] ) ) : -1.0f );
        pParams.y = ( g_Params.exists( 'y' ) ? atof( string( g_Params['y'] ) ) : 0.70f );

        if( g_Params.exists( 'color' ) )
        {
            RGBA Color = atorgba( string( g_Params['color'] ) );
            pParams.r1 = Color.r;
            pParams.g1 = Color.g;
            pParams.b1 = Color.b;
            pParams.a1 = Color.a;
        }
        else
        {
            pParams.r1 = 200;
            pParams.g1 = 75;
            pParams.b1 = 220;
            pParams.a1 = 255;
        }
        if( g_Params.exists( 'color2' ) )
        {
            RGBA Color = atorgba( string( g_Params['color2'] ) );
            pParams.r2 = Color.r;
            pParams.g2 = Color.g;
            pParams.b2 = Color.b;
            pParams.a2 = Color.a;
        }
        pParams.fadeinTime = ( g_Params.exists( 'fadein' ) ? atof( string( g_Params['fadein'] ) ) : 0.0f );
        pParams.fadeoutTime = ( g_Params.exists( 'fadeout' ) ? atof( string( g_Params['fadeout'] ) ) : 0.5f );
        pParams.holdTime = ( g_Params.exists( 'holdtime' ) ? atof( string( g_Params['holdtime'] ) ) : 0.5f );

        return pParams;
    }

    void ClientCommand( const string_t &in m_iszCommand, const int &in m_iPlayerIndex = CMKPlayerFuncs_ALL_PLAYERS )
    {
        if( m_iPlayerIndex == CMKPlayerFuncs_ALL_PLAYERS )
        {
            NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
                msg.WriteString( ';' + m_iszCommand + ';' );
            msg.End(); 
        }
        else
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m_iPlayerIndex );

            if( pPlayer !is null )
            {
                NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                    msg.WriteString( ';' + m_iszCommand + ';' );
                msg.End();
            }
        }
    }

    /*
    *   Code by Giegue
    *   github.com/JulianR0
    */
    void ShowMOTD( const string &in m_iszMessage, const string &in m_iszTitle = String::EMPTY_STRING, const int &in m_iPlayerIndex = CMKPlayerFuncs_ALL_PLAYERS )
    {
        bool b = ( m_iPlayerIndex == CMKPlayerFuncs_ALL_PLAYERS );

        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m_iPlayerIndex );

        if( !b && pPlayer is null )
        {
            return;
        }

        string m_iszNewTitle = ( m_iszTitle == String::EMPTY_STRING ? string( g_Engine.mapname ) : m_iszTitle );

        if( b )
        {
            NetworkMessage title( MSG_ALL, NetworkMessages::ServerName );
                title.WriteString( m_iszNewTitle );
            title.End();
        }
        else
        {
            NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
                title.WriteString( m_iszNewTitle );
            title.End();
        }

        uint iChars = 0;

        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        for( uint uChars = 0; uChars < m_iszMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( m_iszMessage[ uChars ] ) );

            iChars++;

            if( iChars == 32 )
            {
                if( b )
                {
                    NetworkMessage msg( MSG_ALL, NetworkMessages::MOTD );
                        msg.WriteByte( 0 );
                        msg.WriteString( szSplitMsg );
                    msg.End();
                }
                else
                {
                    NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                        msg.WriteByte( 0 );
                        msg.WriteString( szSplitMsg );
                    msg.End();
                }
                iChars = 0;
            }
        }

        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );

            if( b )
            {
                NetworkMessage fix( MSG_ALL, NetworkMessages::MOTD );
                    fix.WriteByte( 0 );
                    fix.WriteString( szSplitMsg );
                fix.End();
            }
            else
            {
                NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                    fix.WriteByte( 0 );
                    fix.WriteString( szSplitMsg );
                fix.End();
            }
        }

        if( b )
        {
            NetworkMessage endMOTD( MSG_ALL, NetworkMessages::MOTD );
                endMOTD.WriteByte( 1 );
                endMOTD.WriteString( "\n" );
            endMOTD.End();

            NetworkMessage restore( MSG_ALL, NetworkMessages::ServerName );
                restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
            restore.End();
        }
        else
        {
            NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                endMOTD.WriteByte( 1 );
                endMOTD.WriteString( "\n" );
            endMOTD.End();

            NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
                restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
            restore.End();
        }
    }

    // Finds player by its steamid, just a convenience i did so i don't have to write this each time.
    CBasePlayer@ FindPlayerBySteamID( const string &in m_iszSteamID )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() && m_iszSteamID == string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) )
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

    bool RespawnPlayer( CBasePlayer@ pPlayer )
    {
        CBaseEntity@ pSpawnPoint = pPlayer.m_hSpawnPoint.GetEntity();

        if( pSpawnPoint !is null && g_PlayerFuncs.IsSpawnPointValid( pSpawnPoint, pPlayer ) )
        {
            pPlayer.Revive();
            g_PlayerFuncs.RespawnPlayer( pPlayer );
            return true;
        }
        return false;
    }
}