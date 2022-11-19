/*

INSTALL:
#include "mikk/player_inbutton"

void MapInit()
{
    RegisterPlayerInButtons();
}

*/

#include "utils"

void RegisterPlayerInButtons()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "player_inbutton", "player_inbutton" );
}

class player_inbutton : ScriptBaseEntity, UTILS::MoreKeyValues
{
    private bool Toggle	= true;

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        ExtraKeyValues(szKey, szValue);

        return true;
    }

    void Spawn()
    {
        self.pev.movetype 	= MOVETYPE_NONE;
        self.pev.solid 		= SOLID_NOT;
        self.pev.effects	|= EF_NODRAW;
		
        UTILS::SetSize( self, false );

        if( string( self.pev.netname ).IsEmpty() ) self.pev.netname = "32";

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            Toggle = false;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

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

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            if( self.pev.SpawnFlagBitSet( 2 ) )
            {
                if( pPlayer.pev.button & atoi( self.pev.netname ) != 0)
                    UTILS::TriggerMode( self.pev.target, pPlayer, 0.0f );
            }
            else
            {
                if( UTILS::InsideZone( pPlayer, self ) )
                {
                    UTILS::TriggerMode( self.pev.message, pPlayer, 0.0f );

                    if( pPlayer.pev.button & atoi( self.pev.netname ) != 0)
                        UTILS::TriggerMode( self.pev.target, pPlayer, 0.0f );
                }
            }
        }
        self.pev.nextthink = g_Engine.time + 0.3f;
    }
}