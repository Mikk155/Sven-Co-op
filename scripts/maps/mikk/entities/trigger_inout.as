#include "utils"

void RegisterCBaseInOut( const string ClassName = "trigger_inout" )
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseInOut", ClassName );
}

enum CBaseInOut_flags
{
    SF_INOUT_START_OFF = 1 << 0,
    SF_INOUT_OUTREMOVE = 1 << 1,
    SF_INOUT_MTHREATED = 1 << 2,
    SF_INOUT_NOCLIENTS = 1 << 3,
    SF_INOUT_FMONSTERS = 1 << 4
}

class CBaseInOut : ScriptBaseEntity
{
    private bool MultiThreatState	= false;
    private bool OnePpInsideState	= false;
    private bool EntitToggleState	= false;

    bool KeyValue( const string& in szKey, const string& in szValue ) 
    {
        if( szKey == "minhullsize" ) 
        {
            g_Utility.StringToVector( self.pev.vuser1, szValue );
            return true;
        }
        else if( szKey == "maxhullsize" ) 
        {
            g_Utility.StringToVector( self.pev.vuser2, szValue );
            return true;
        }
        else
        {
            return BaseClass.KeyValue( szKey, szValue );
        }
    }

    void Spawn() 
    {
        self.Precache();

        self.pev.movetype   = MOVETYPE_NONE;
        self.pev.solid      = SOLID_NOT;
        self.pev.effects   |= EF_NODRAW;

        UTILS::SetSize( self );

        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        if( self.pev.SpawnFlagBitSet( SF_INOUT_START_OFF ) )
        {
            EntitToggleState = true;
        }
        else
        {
            SetThinks();
        }

        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        switch(useType)
        {
            case USE_ON:
            {
                SetThinks();
            }
            break;

            case USE_OFF:
            {
                SetThink( null );
            }
            break;

            default:
            {
                if( EntitToggleState )
                {
                    SetThinks();
                }
                else
                {
                    SetThink( null );
                }
                EntitToggleState = !EntitToggleState;
            }
            break;
        }
    }

    void SetThinks()
    {
        if( self.pev.SpawnFlagBitSet( SF_INOUT_MTHREATED ) )
        {
            MultiThreatState = true;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;
	}

    void TriggerThink() 
    {
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
                            UTILS::TriggerMode(self, self.pev.target, pPlayer);
                            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 1 );
                        }
                    }
                    else
                    {
                        if( pPlayer.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 1 )
                        {
                            UTILS::TriggerMode(self, self.pev.netname, pPlayer);

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
                            UTILS::TriggerMode(self, self.pev.target, pPlayer);
                            OnePpInsideState = true;
                        }
                    }

                    totalPlayers = g_PlayerFuncs.GetNumPlayers();

                    if( totalPlayers > 0.0f ) 
                    {
                        currentPercentage = playersTrigger / totalPlayers + 0.00001f;

                        if( currentPercentage >= 1.00 && OnePpInsideState ) 
                        {
                            UTILS::TriggerMode(self, self.pev.netname, self);

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
                        UTILS::TriggerMode(self, self.pev.target, pMonster);

                        pMonster.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 1 );
                    }
                }
                else
                {
                    if( pMonster.GetCustomKeyvalues().GetKeyvalue("$i_trigger_inout").GetFloat() == 1 )
                    {
                        UTILS::TriggerMode(self, self.pev.netname, pMonster);
                        pMonster.GetCustomKeyvalues().SetKeyvalue( "$i_trigger_inout", 0 );
                    }
                }
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
	}
}