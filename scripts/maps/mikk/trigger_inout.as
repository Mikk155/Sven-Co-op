/*

INSTALL:

#include "mikk/trigger_inout"

void MapInit()
{
	RegisterCBaseTriggerInOut();
}
*/

#include "utils"

void RegisterCBaseTriggerInOut()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseTriggerInOut", "trigger_inout" );
}

enum CBaseInOut_flags
{
    SF_INOUT_START_OFF = 1 << 0,
    SF_INOUT_OUTREMOVE = 1 << 1,
    SF_INOUT_MTHREATED = 1 << 2,
    SF_INOUT_NOCLIENTS = 1 << 3,
    SF_INOUT_FMONSTERS = 1 << 4
}

class CBaseTriggerInOut : ScriptBaseEntity, UTILS::MoreKeyValues
{
    private bool MultiThreatState	= false;
    private bool OnePpInsideState	= false;
    private bool Toggle	= true;

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        ExtraKeyValues(szKey, szValue);

        return true;
    }

    void Spawn() 
    {
        self.Precache();

        self.pev.movetype   = MOVETYPE_NONE;
        self.pev.solid      = SOLID_NOT;
        self.pev.effects   |= EF_NODRAW;

        UTILS::SetSize( self, false );

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            Toggle = false;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

        if( self.pev.SpawnFlagBitSet( SF_INOUT_MTHREATED ) )
        {
            MultiThreatState = true;
        }

        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        switch(useType)
        {
            case USE_ON:
            {
                Toggle = true;
            }
            break;

            case USE_OFF:
            {
                Toggle = false;
            }
            break;

            default:
            {
                Toggle = !Toggle;
            }
            break;
        }
    }

    void TriggerThink() 
    {
        if( !Toggle || multisource() )
        {
            self.pev.nextthink = g_Engine.time + 0.5f;
            return;
        }

        float totalPlayers = 0.0f, playersTrigger = 0.0f, currentPercentage = 0.0f;

        if( !self.pev.SpawnFlagBitSet( SF_INOUT_NOCLIENTS ) )
        {
            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                {
                    continue;
                }

                if( MultiThreatState )
                {
                    if( UTILS::InsideZone( pPlayer, self ) )
                    {
                        if( pPlayer.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 0 )
                        {
                            UTILS::TriggerMode( self.pev.target, pPlayer);
                            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 1 );
                        }
                    }
                    else
                    {
                        if( pPlayer.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 1 )
                        {
                            UTILS::TriggerMode( self.pev.netname, pPlayer);

                            if( self.pev.SpawnFlagBitSet( SF_INOUT_OUTREMOVE ) )
                            {
                                SetThink( null );
                            }

                            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 0 );
                        }
                    }
                }
                else
                {
                    if( !UTILS::InsideZone( pPlayer, self ) )
                    {
                        playersTrigger = playersTrigger + 1.0f;
                    }
                    else
                    {
                        if( !OnePpInsideState )
                        {
                            UTILS::TriggerMode( self.pev.target, pPlayer);
                            OnePpInsideState = true;
                        }
                    }

                    totalPlayers = g_PlayerFuncs.GetNumPlayers();

                    if( totalPlayers > 0.0f ) 
                    {
                        currentPercentage = playersTrigger / totalPlayers + 0.00001f;

                        if( currentPercentage >= 1.00 && OnePpInsideState ) 
                        {
                            UTILS::TriggerMode( self.pev.netname, self);

                            if( self.pev.SpawnFlagBitSet( SF_INOUT_OUTREMOVE ) )
                            {
                                SetThink( null );
                            }

                            OnePpInsideState = false;
                        }
                    }
                }
            }
        }

        if( self.pev.SpawnFlagBitSet( SF_INOUT_FMONSTERS ) )
        {
			CBaseEntity@ pMonster = null;

            while( ( @pMonster = g_EntityFuncs.FindEntityByTargetname( pMonster, string( self.pev.message ) ) ) !is null )
            {
                if( UTILS::InsideZone( pMonster, self ) )
                {
                    if( pMonster.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 0 )
                    {
                        UTILS::TriggerMode( self.pev.target, pMonster);

                        pMonster.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 1 );
                    }
                }
                else
                {
                    if( pMonster.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 1 )
                    {
                        UTILS::TriggerMode( self.pev.netname, pMonster);
                        pMonster.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 0 );
                    }
                }
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
	}
}