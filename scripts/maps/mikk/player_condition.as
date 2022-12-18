/*
DOWNLOAD:

scripts/maps/mikk/player_condition.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/player_condition"

void MapInit()
{
    player_condition::Register();
}

*/

#include "utils"

namespace player_condition
{
    enum player_condition_flags
    {
        SF_INBUTT_EVERYWHERE = 1 << 0
    }

    class player_condition : ScriptBaseEntity, UTILS::MoreKeyValues
    {
		private int
			iconditions,
            Intersects,
            inbuttons,
            IsAlive,
			IsObserver,
            IsMoving,
            IsOnLadder,
            FlashlightIsOn,
            HasSuit,
            m_fLongJump;

        private string
            Intersects_target,
            HasNamedItem;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            if( szKey == "Intersects" ) Intersects = atoi( szValue );
            else if( szKey == "inbuttons" ) inbuttons = atoi( szValue );
            else if( szKey == "IsAlive" ) IsAlive = atoi( szValue );
            else if( szKey == "IsObserver" ) IsObserver = atoi( szValue );
            else if( szKey == "IsMoving" ) IsMoving = atoi( szValue );
            else if( szKey == "IsOnLadder" ) IsOnLadder = atoi( szValue );
            else if( szKey == "FlashlightIsOn" ) FlashlightIsOn = atoi( szValue );
            else if( szKey == "HasSuit" ) HasSuit = atoi( szValue );
            else if( szKey == "m_fLongJump" ) m_fLongJump = atoi( szValue );

            else if( szKey == "Intersects_target" ) Intersects_target = szValue;
            else if( szKey == "HasNamedItem" ) HasNamedItem = szValue;
            ExtraKeyValues(szKey, szValue);
            return true;
        }

        void Spawn()
        {
            self.pev.movetype     = MOVETYPE_NONE;
            self.pev.solid         = SOLID_NOT;
            self.pev.effects    |= EF_NODRAW;
            
            SetBoundaries();

			iconditions = 1;

            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void TriggerThink() 
        {
            if( master() )
            {
                self.pev.nextthink = g_Engine.time + 0.5f;
                return;
            }

            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null )
                    continue;

                if( Intersects == 1 && self.Intersects( pPlayer ) )
                    ConditionUp( pPlayer );
                
                if( IsAlive == 1 && pPlayer.IsAlive() )
                    ConditionUp( pPlayer );
                
                if( IsObserver == 1 && pPlayer.GetObserver().IsObserver() )
                    ConditionUp( pPlayer );
                
                if( IsMoving == 1 && pPlayer.IsMoving() )
                    ConditionUp( pPlayer );
                
                if( IsOnLadder == 1 && pPlayer.IsOnLadder() )
                    ConditionUp( pPlayer );
                
                if( FlashlightIsOn == 1 && pPlayer.FlashlightIsOn() )
                    ConditionUp( pPlayer );

                if( !string( Intersects_target ).IsEmpty() )
                {
                    CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, Intersects_target );
                    if( pEntity !is null && pEntity.Intersects( pPlayer ) )
                        ConditionUp( pPlayer );
                }
                
                if( !string( HasNamedItem ).IsEmpty() )
				{
					CBasePlayerItem@ pWeapon = pPlayer.HasNamedPlayerItem( HasNamedItem );
					if( pWeapon is null )
						ConditionUp( pPlayer );
				}
                
                if( HasSuit == 1 && pPlayer.HasSuit() )
                    ConditionUp( pPlayer );

                if( inbuttons > 0 && pPlayer.pev.button & inbuttons != 0 )
                    ConditionUp( pPlayer );

                if( m_fLongJump == 1 && pPlayer.m_fLongJump )
                    ConditionUp( pPlayer );

                if( pPlayer.GetCustomKeyvalues().GetKeyvalue( "$i_player_conditions" ).GetInteger() >= iconditions )
                    UTILS::Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );

                pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_player_conditions", 0 );
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }
    
    void ConditionUp( CBasePlayer@ pPlayer )
    {
        int iOld = pPlayer.GetCustomKeyvalues().GetKeyvalue( "$i_player_conditions" ).GetInteger();

        pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_player_conditions", iOld + 1 );
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_condition::player_condition", "player_condition" );
    }
}// end namespace