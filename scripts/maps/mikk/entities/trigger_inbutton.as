#include "utils"
void RegisterTriggerInButtons()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "trigger_inbutton", "trigger_inbutton" );
}

class trigger_inbutton : ScriptBaseEntity, MLAN::MoreKeyValues
{
    private bool toggle	= false;
    private int pevButton = IN_USE;

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        SexKeyValues(szKey, szValue);

        return true;
    }

    void Spawn()
    {
        self.pev.movetype 	= MOVETYPE_NONE;
        self.pev.solid 		= SOLID_NOT;
        self.pev.effects	|= EF_NODRAW;
		
        UTILS::SetSize( self );

        g_EntityFuncs.SetOrigin( self, self.pev.origin );

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            toggle = true;
        }
        else
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;
        }

        SetButton();

        BaseClass.Spawn();
	}
	
    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if( toggle )
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
        else
        {
            SetThink( null );
        }
        toggle = !toggle;
    }
	
    void TriggerThink() 
    {
        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

            string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "+", ""+self.pev.netname } } );

            if( UTILS::InsideZone( pPlayer, self ) )
            {
                g_PlayerFuncs.PrintKeyBindingString(pPlayer, ReadLanguage+'\n');

                if( pPlayer.pev.button & pevButton != 0)
                {
                    UTILS::TriggerMode(self, self.pev.target, pPlayer);
                }
            }
        }
        self.pev.nextthink = g_Engine.time + 0.3f;
    }
	
    void SetButton()
    {
        if( self.pev.netname == "+showscores" ) { pevButton = IN_SCORE; } // (32768) Used by client.dll for when scoreboard is held down
        else if( self.pev.netname == "+alt1" ) { pevButton = IN_ALT1; } // (16384) Tertiary attack
        else if( self.pev.netname == "+reload" ) { pevButton = IN_RELOAD; } // (8192) Reload
        else if( self.pev.netname == "+forward" ) { pevButton = IN_RUN; } // (4096) Run/Walk
        else if( self.pev.netname == "+attack2" ) { pevButton = IN_ATTACK2; } // (2048) Secondary attack
        else if( self.pev.netname == "+moveright" ) { pevButton = IN_MOVERIGHT; } // (1024) Move right
        else if( self.pev.netname == "+moveleft" ) { pevButton = IN_MOVELEFT; } // (512) Move left
        else if( self.pev.netname == "+right" ) { pevButton = IN_RIGHT; } // (256)
        else if( self.pev.netname == "+left" ) { pevButton = IN_LEFT; } // (128)
        else if( self.pev.netname == "+cancelselect" ) { pevButton = IN_CANCEL; } // (64)
        else if( self.pev.netname == "+back" ) { pevButton = IN_BACK; } // (16) Move backward
        else if( self.pev.netname == "+forward" ) { pevButton = IN_FORWARD; } // (8) Move forward
        else if( self.pev.netname == "+duck" ) { pevButton = IN_DUCK; } // (4) Duck
        else if( self.pev.netname == "+jump" ) { pevButton = IN_JUMP; } // (2) Jump
        else if( self.pev.netname == "+attack" ) { pevButton = IN_ATTACK; } // (1) Primary attack
        else { pevButton = IN_USE; } // (32) Use
    }
}