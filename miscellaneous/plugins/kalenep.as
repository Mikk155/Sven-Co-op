/*
Kez asked for this, i've upload it because the logic i've used for voting may be useful. Think Cubemath has something like that in ¿DD7?
*/

const float flVoteDelay = 10.0f;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/2ErNUQh6fE" );

    g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @PlayerPostRevive );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
}

string VotingFor = String::EMPTY_STRING;
dictionary gpVoteData;
CScheduledFunction@ gpVoteEnded = null;

CPlayerAtributes gpPlayerAtributes;

final class CPlayerAtributes
{
    float health = 1;
    float max_health = 1;
    float armorvalue = 0;
    float armortype = 0;
}

HookReturnCode PlayerAtributesChange( const string &in atr, int &in vl )
{
    if( atr == 'health' )
    {
        gpPlayerAtributes.health = float(vl);
        gpPlayerAtributes.max_health = float(vl);
    }
    else if( atr == 'armor' )
    {
        gpPlayerAtributes.armortype = float(vl);
        gpPlayerAtributes.armorvalue = float(vl);
    }
    else
    {
        return HOOK_CONTINUE;
    }

    PlayerSetAtributes();
    VotingFor = String::EMPTY_STRING;
    return HOOK_HANDLED;
}

HookReturnCode PlayerSetAtributes()
{
    if( g_PlayerFuncs.GetNumPlayers() == 0 )
    {
        return HOOK_CONTINUE;
    }

    for( int i = 1; i <= g_Engine.maxClients; i++ )
    {
        PlayerSetAtributes( g_PlayerFuncs.FindPlayerByIndex( i ) );
    }

    NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
        msg.WriteString( ';spk "buttons/bell1";' );
    msg.End();

    return HOOK_HANDLED;
}

HookReturnCode PlayerSetAtributes( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        pPlayer.pev.health = ( gpPlayerAtributes.health > 0 ? gpPlayerAtributes.health :
                        pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_kalenep_health' ).GetFloat() );
        pPlayer.pev.armortype = ( gpPlayerAtributes.armortype > 0 ? gpPlayerAtributes.armortype :
                        pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_kalenep_armortype' ).GetFloat() );
        pPlayer.pev.max_health = ( gpPlayerAtributes.max_health > 0 ? gpPlayerAtributes.max_health :
                        pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_kalenep_max_health' ).GetFloat() );
        pPlayer.pev.armorvalue = ( gpPlayerAtributes.armorvalue > 0 ? gpPlayerAtributes.armorvalue :
                        pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_kalenep_armorvalue' ).GetFloat() );

        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_kalenep_health' ) )
             pPlayer.GetCustomKeyvalues().SetKeyvalue( '$f_kalenep_health', pPlayer.pev.health );
        if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_kalenep_armortype' ) )
             pPlayer.GetCustomKeyvalues().SetKeyvalue( '$f_kalenep_armortype', pPlayer.pev.armortype );
        if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_kalenep_max_health' ) )
             pPlayer.GetCustomKeyvalues().SetKeyvalue( '$f_kalenep_max_health', pPlayer.pev.max_health );
        if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_kalenep_armorvalue' ) )
             pPlayer.GetCustomKeyvalues().SetKeyvalue( '$f_kalenep_armorvalue', pPlayer.pev.armorvalue );

        PlayerSetAtributes( pPlayer );
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        PlayerSetAtributes( pPlayer );
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerVote( CBasePlayer@ pPlayer, const int &in vl )
{
    if( pPlayer !is null )
    {
        string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        gpVoteData[ SteamID ] = vl;
    }
    return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    const CCommand@ args = pParams.GetArguments();
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( VotingFor != String::EMPTY_STRING && ( atoi( args[0] ) > 0 or atoi( args[0] ) == -1 ) )
    {
        PlayerVote( pPlayer, atoi( args[0] ) );

        if( gpVoteData.getKeys().length() == uint( g_PlayerFuncs.GetNumPlayers() ) )
        {
            if( gpVoteEnded !is null )
            {
                @gpVoteEnded = null;
                g_Scheduler.RemoveTimer( gpVoteEnded );
            }
            VoteEnded();
        }
    }
    else if( VotingFor == String::EMPTY_STRING && args[0] == "/health" || args[0] == "/armor" )
    {
        string atr = args[0].SubString( 1, args[0].Length() );

        if( pPlayer !is null && g_PlayerFuncs.AdminLevel( pPlayer ) >= ADMIN_YES && ( atoi( args[1] ) > 0 or atoi( args[1] ) == -1 ) )
        {
            PlayerAtributesChange( atr, atoi( args[1] ) );
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Admin "+string(pPlayer.pev.netname)+" Updated \""+atr+"\" to \""+args[1]+"\"\n" );
        }
        else
        {

            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "A vote for changing \""+atr+"\" has started. write in chat the ammout of "+atr+" you want to vote for.\n" );
            VotingFor = atr;

            g_Scheduler.SetTimeout( "VoteEnded", flVoteDelay );
        }
    }
    return HOOK_CONTINUE;
}

dictionary playervotes;

int GetNearestValue( const array<string> &in KeyPair )
{
    dictionary votes;

    for( uint ui = 0; ui < KeyPair.length(); ui++ )
    {
        int voted = int( gpVoteData[ KeyPair[ ui ] ] );
        votes[ voted ] = int( votes[ voted ] ) + 1;
    }

    int voted=0;
    int most_voted=1;

    array<string> VotePair = votes.getKeys();
    array<int> VotedValues;

    for( uint ui = 0; ui < VotePair.length(); ui++ )
    {
        if( int( votes[ VotePair[ ui ] ] ) > most_voted )
        {
            voted = atoi( VotePair[ ui ] );
            most_voted = int( votes[ VotePair[ ui ] ] );
        }

        VotedValues.insertLast( atoi( VotePair[ ui ] ) );
    }

    if( most_voted != 1 )
    {
        return voted;
    }

    return GetAverageValue( VotedValues );
}

int GetDifference( int v1, int v2 )
{
    int maxNum = Math.max( v1, v2 );
    int minNum = Math.min( v1, v2 );

    float difference = Math.AngleDistance( maxNum, minNum );

    if( minNum == maxNum )
        return minNum;

    return int( minNum + ( difference / 2 ) );
}

array<int> SortValues( array<int> VotedValues )
{
    array<int> NewValues;

    VotedValues.sortAsc();

    int AverageValue = VotedValues[ 0 ];

    while( VotedValues.length() > 0 )
    {
        int ContextValue = GetDifference( VotedValues[ 0 ], VotedValues[ VotedValues.length() - 1 ] );

        NewValues.insertLast( ContextValue );

        VotedValues.removeAt( VotedValues.length() - 1 );
        if( VotedValues.length() > 0 )
            VotedValues.removeAt( 0 );
    }

    return( NewValues );
}

int GetAverageValue( array<int> VotedValues )
{
    VotedValues = SortValues( VotedValues );

    while( VotedValues.length() > 1 )
    {
        VotedValues = SortValues( VotedValues );
    }

    return VotedValues[0];
}

HookReturnCode VoteEnded()
{
    string SetType = VotingFor;
    VotingFor = String::EMPTY_STRING;

    const array<string> votes = gpVoteData.getKeys();

    if( votes.length() < 1 )
        return HOOK_HANDLED;

    if( g_PlayerFuncs.GetNumPlayers() > 1 && int( votes.length() ) < g_PlayerFuncs.GetNumPlayers() / 2 )
    {
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Vote failed." );
        gpVoteData.deleteAll();
        return HOOK_HANDLED;
    }

    PlayerAtributesChange( SetType, GetNearestValue( votes ) );

    gpVoteData.deleteAll();

    return HOOK_HANDLED;
}
