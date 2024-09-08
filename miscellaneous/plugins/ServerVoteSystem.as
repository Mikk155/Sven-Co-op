#include '../../mikk/as_utils'

// 2 minutes cooldown per players
const int m_iPlayerVoteCooldown = 5;
// Time for voting
const float m_fVoteTime = 20.0f;
// Percentage of players needed to vote yes
const double m_fPercentage = 66.0f;
// Time until the vote appears
const int m_iVoteAppearIn = 1;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    if( g_Cooldown !is null )
    {
        g_Scheduler.RemoveTimer( g_Cooldown );
    }

    @g_Cooldown = g_Scheduler.SetInterval( "Cooldown", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    mk.FileManager.GetMultiLanguageMessages( msg, 'scripts/plugins/mikk/ServerVoteSystem.ini' );
}

dictionary msg;

CScheduledFunction@ g_Cooldown = null;

void Cooldown()
{
    const array<string> Steamips = g_VoteMenu.votaron.getKeys();

    if( Steamips.length() > 0 )
    {
        for( uint i = 0; i < Steamips.length(); i++ )
        {
            int iold = int( g_VoteMenu.votaron[ Steamips[i] ] );

            if( iold > 0 )
            {
                g_VoteMenu.votaron[ Steamips[i] ] = iold - 1;
            }
            else
            {
                g_VoteMenu.votaron.delete( Steamips[i] );
            }
        }
    }
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( pPlayer !is null && pParams.GetArguments()[0] == "/vote" )
    {
        if( g_VoteMenu.voting == 1 )
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, dictionary( msg[ 'voting' ] ), CMKPlayerFuncs_PRINT_CHAT );
            return HOOK_CONTINUE;
        }

        g_VoteMenu.OpenSingleMenu( pPlayer );
    }
    return HOOK_CONTINUE;
}

CTextMenu@ g_Menu;

CVoteMenus g_VoteMenu;

class CVoteMenus
{
    void OpenSingleMenu( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && pPlayer.IsConnected() )
        {
            int eidx = pPlayer.entindex();

            @a_Votemenu[eidx] = null;

            if( a_Votemenu[eidx] is null )
            {
                @a_Votemenu[eidx] = CTextMenu( TextMenuPlayerSlotCallback( this.SingleCallBack ) );

                a_Votemenu[eidx].SetTitle( '\\y' + mk.PlayerFuncs.GetLanguage( pPlayer, dictionary( msg[ 'title' ] ) ) + '\\r \\n' );

                a_Votemenu[eidx].AddItem( '\\' + ( mk.FileManager.IsPluginInstalled( 'AntiClip', false ) ? 'w' :'d' ) + mk.PlayerFuncs.GetLanguage( pPlayer, ( atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip' ) ) == 1 ? dictionary( msg[ 'vote anticlip disable' ] ) : dictionary( msg[ 'vote anticlip enable' ] ) ) ) + '\\r' );
                a_Votemenu[eidx].AddItem( '\\w' + mk.PlayerFuncs.GetLanguage( pPlayer, dictionary( msg[ 'vote restart' ] ) ) + '\\r' );
                a_Votemenu[eidx].AddItem( '\\w' + mk.PlayerFuncs.GetLanguage( pPlayer, ( atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_antirush' ) ) == 1 ? dictionary( msg[ 'vote antirush disable' ] ) : dictionary( msg[ 'vote antirush enable' ] ) ) ) + '\\r' );
                a_Votemenu[eidx].AddItem( '\\w' + mk.PlayerFuncs.GetLanguage( pPlayer, dictionary( msg[ 'vote map' ] ) ) + '\\r' );

                a_Votemenu[eidx].Register();
                a_Votemenu[eidx].Open( 25, 0, pPlayer );
            }
        }
    }

    dictionary votaron;

    void SingleCallBack( CTextMenu@ CMenu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
    {
        if( pPlayer is null || pItem is null )
            return;

        string Choice = pItem.m_szName;

        string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

        if( votaron.exists( SteamID ) )
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, dictionary( msg[ 'cooldown' ] ), CMKPlayerFuncs_PRINT_CHAT, false, { {'$time$', string( int( votaron[ SteamID ] ) ) } } );
            return;
        }
        else if( g_VoteMenu.voting == 1 )
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, dictionary( msg[ 'voting' ] ), CMKPlayerFuncs_PRINT_CHAT );
            return;
        }

        dictionary@ pMessage = null;

        switch( iSlot )
        {
            case VOTEMENU_EXIT:
            {
                return;
            }
            case VOTEMENU_ANTICLIP:
            {
                if( !mk.FileManager.IsPluginInstalled( 'AntiClip', false ) )
                    @pMessage = dictionary( msg[ 'not installed' ] );
                break;
            }
        }

        if( pMessage !is null )
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, pMessage, CMKPlayerFuncs_PRINT_CHAT, false, { { '$plugin$', 'AntiClip' } } );
            return;
        }

        votaron[ SteamID ] = m_iPlayerVoteCooldown;
        mk.PlayerFuncs.PrintMessage( null, dictionary( msg[ 'vote incoming' ] ), CMKPlayerFuncs_PRINT_CHAT, true, { { '$time$', string( m_iVoteAppearIn ) } } );
        voting = 1;
        m_uiSlot = iSlot;
        g_Scheduler.SetTimeout( @this, 'VoteStart', float( m_iVoteAppearIn ), SteamID );
    }

    uint m_uiSlot;

    void VoteStart( string SteamID )
    {
        switch( m_uiSlot )
        {
            case VOTEMENU_ANTICLIP:
            {
                int state = atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip' ) );

                StartGlobalVote( SteamID, ( state == 1 ? dictionary( msg[ 'vote anticlip disable' ] ) : dictionary( msg[ 'vote anticlip enable' ] ) ) );
                break;
            }
            case VOTEMENU_RESTART:
            {
                StartGlobalVote( SteamID, dictionary( msg[ 'vote restart' ] ) );
                break;
            }
            case VOTEMENU_ANTIRUSH:
            {
                int state = atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_antirush' ) );

                StartGlobalVote( SteamID, ( state == 1 ? dictionary( msg[ 'vote antirush disable' ] ) : dictionary( msg[ 'vote antirush enable' ] ) ) );
                break;
            }
            case VOTEMENU_MAP:
            {
                StartGlobalVote( SteamID, dictionary( msg[ 'vote map' ] ) );
                break;
            }
        }
    }

    int yes, no, voting;

    // Menus need to be defined globally when the plugin is loaded or else paging doesn't work.
    // Each player needs their own menu or else paging breaks when someone else opens the menu.
    // These also need to be modified directly (not via a local var reference). - Wootguy
    array<CTextMenu@> a_Votemenu = 
    {
        null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        null
    };

    void StartGlobalVote( string SteamID, dictionary@ msg_get_title )
    {
        CBasePlayer@ pCaller = mk.PlayerFuncs.FindPlayerBySteamID( SteamID );

        if( pCaller !is null )
        {
            mk.PlayerFuncs.PrintMessage( null, dictionary( msg[ 'vote caller' ] ), CMKPlayerFuncs_PRINT_CHAT, true, { { '$name$', string( pCaller.pev.netname ) } } );
        }

        for( int i = 1; i <= g_Engine.maxClients; i++ ) 
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                int eidx = pPlayer.entindex();

                @a_Votemenu[eidx] = null;

                if( a_Votemenu[eidx] is null )
                {
                    @a_Votemenu[eidx] = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );

                    a_Votemenu[eidx].SetTitle( '\\y' + mk.PlayerFuncs.GetLanguage( pPlayer, msg_get_title ) + '\\w\n' );

                    a_Votemenu[eidx].AddItem( '\\g' + mk.PlayerFuncs.GetLanguage( pPlayer, dictionary( msg[ 'vote yes' ] ) ) + '\\w\n' );
                    a_Votemenu[eidx].AddItem( '\\r' + mk.PlayerFuncs.GetLanguage( pPlayer, dictionary( msg[ 'vote no' ] ) ) + '\\w\n' );

                    a_Votemenu[eidx].Register();
                }
                a_Votemenu[eidx].Open( int( m_fVoteTime ), 0, pPlayer );
            }
        }
        @g_Results = g_Scheduler.SetTimeout( @this, 'Results', m_fVoteTime + 3.0f );
    }

    CScheduledFunction@ g_Results = null;

    void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
    {
        if( iSlot == 1 ) yes++; else no++;

        if( PercentageOfVotes( yes ) >= m_fPercentage || PercentageOfVotes( no ) > m_fPercentage )
        {
            Results();
        }
    }

    double PercentageOfVotes( int m_ivote )
    {
        return double( double( double(m_ivote / double( g_PlayerFuncs.GetNumPlayers())) * 100) );
    }

    void Results()
    {
        g_Scheduler.RemoveTimer( g_Results );

        bool VotePassed = ( PercentageOfVotes( yes ) >= m_fPercentage );

        yes = no = voting = 0;

        if( VotePassed )
        {
            mk.PlayerFuncs.ClientCommand( 'spk "buttons/bell1.wav"' );
            mk.PlayerFuncs.PrintMessage( null, dictionary( msg[ 'vote passed' ] ), CMKPlayerFuncs_PRINT_CHAT, true );
        }
        else
        {
            mk.PlayerFuncs.ClientCommand( 'spk "limitlesspotential/cs/wrong.wav"' );
            mk.PlayerFuncs.PrintMessage( null, dictionary( msg[ 'vote failed' ] ), CMKPlayerFuncs_PRINT_CHAT, true );
            return;
        }

        switch( m_uiSlot )
        {
            case VOTEMENU_ANTICLIP:
            {
                int state = atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_plugin_anticlip' ) );
                g_ConCommandSystem.ServerCommand( '.AntiClip enable ' + ( state == 1 ? '0' : '1' ) );
                break;
            }
            case VOTEMENU_RESTART:
            {
                mk.PlayerFuncs.ClientCommand( 'spk "limitlesspotential/cs/restart.wav"' );
                mk.EntityFuncs.CreateEntity
                (
                    {
                        { 'classname', 'player_loadsaved' },
                        { 'targetname', 'ReloadLevel' },
                        { 'loadtime', '1.5f' }
                    }
                ).Use( null, null, USE_ON, 0.0f );
                break;
            }
            case VOTEMENU_ANTIRUSH:
            {
                int state = atoi( mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_antirush' ) );
                mk.EntityFuncs.CustomKeyValue( g_EntityFuncs.Instance( 0 ), '$s_antirush', ( state == 1 ? '0' : '1' )  );
                break;
            }
            case VOTEMENU_MAP:
            {
                NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION, null );
                message.End();
                g_Scheduler.SetTimeout( @this, 'ChangeLevel', 4.0f );
                break;
            }
        }
    }

    void ChangeLevel()
    {
        g_EngineFuncs.ChangeLevel( 'lp_mapvote' );
    }
}

enum CVoteMenus_e
{
    VOTEMENU_EXIT = 0,
    VOTEMENU_ANTICLIP,
    VOTEMENU_RESTART,
    VOTEMENU_ANTIRUSH,
    VOTEMENU_MAP
}