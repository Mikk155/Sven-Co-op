bool DisallowVotes = false;
bool tempdisablevotes = false;
int DifficultyVoted = 0;

namespace DDDVOTE
{
    void VOTE( CBasePlayer@ pPlayer, const string strMessagerName, float flVoteTime, float flVotePercentage, int iDifficulty, int VoteType, float flVoteCooldown )
    {
    /*    if( tempdisablevotes )
        {
            MLANGUAGE::MSG( pPlayer, "tempdisablevote", iDifficulty, flVoteTime, "", strMessagerName );

            if( VoteType == 2 )
            {
                MLANGUAGE::MSG( pPlayer, "tempdisablevote2", iDifficulty, flVoteTime, "", strMessagerName );
            }
            return;
        }
		else
        {
            if( DisallowVotes )
            {
                MLANGUAGE::MSG( pPlayer, "oncooldown", flVoteCooldown, "", "", strMessagerName );
                return;
            }
		    else
            {
                DisallowVotes = true;
                tempdisablevotes = true;
            }
        }*/

        // Replace difficulty with the voted
        DifficultyVoted = iDifficulty;

        if( g_PlayerFuncs.GetNumPlayers() == 1 )
        {
            VotePassed();

            return;
		}

        MLANGUAGEALL::MSG( "vote_start", iDifficulty, string( pPlayer.pev.netname ), "", strMessagerName );

        // Casual vote
        if( VoteType == 0 )
        {
            VOTE::StartVote( flVoteTime, flVotePercentage, iDifficulty );
        }
        // Vote menu
        else if( VoteType == 1 )
        {
            VOTEMENU::StartVote( flVoteTime, flVotePercentage, iDifficulty );
        }
        // Chat vote
        else if( VoteType == 2 )
        {
            VOTECHAT::StartVote( flVoteTime, flVotePercentage, iDifficulty );
            MLANGUAGE::MSG( pPlayer, "yupdiff", iDifficulty, "", "", strMessagerName );
        }

        g_Scheduler.SetTimeout( "VoteEnded", 1.0f );
    }

    void VotePassed()
    {
        DIFFYCALLBACK::Diff( DifficultyVoted );
        tempdisablevotes = false;
    }

    void VoteEnded()
    {
        DisallowVotes = false;
    }
}

namespace VOTE
{
    void StartVote( float flVoteTime, float flVotePercentage, int iDifficulty )
    {
        Vote vote( "DDD", "Change difficulty to" + string( iDifficulty ) + " Percent?", flVoteTime, flVotePercentage );
        vote.SetYesText( "Yes" );
        vote.SetNoText( "Don't change" );
        vote.SetVoteBlockedCallback( @VoteBlockedTryLater );
        vote.SetVoteEndCallback( @VoteEndCallBack );
        vote.Start();
    }

    void VoteBlockedTryLater( Vote@ pVote, float flTime )
    {
        g_Scheduler.SetTimeout( "StartVote", flTime );
    }

    void VoteEndCallBack( Vote@ pVote, bool bResult, int iVoters )
    {
        if ( bResult )
        {
            DDDVOTE::VotePassed();
        }
    }
}

namespace VOTEMENU
{
    void StartVote( float flVoteTime, float flVotePercentage, int iDifficulty )
    {
    }
}

namespace VOTECHAT
{
    void StartVote( float flVoteTime, float flVotePercentage, int iDifficulty )
    {
    }
}