class env_crystal : ScriptBaseEntity
{
    private int m_ilRadius = 128;
    private int m_ilType = 0;
    private int m_ilValue = 1;
    private CBeam@ pBorderBeam;

	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
        if( szKey == "radius" )
        {
            m_ilRadius = atoi( szValue );
            return true;
        }
        else if( szKey == "type" )
        {
            m_ilType= atoi( szValue );
            return true;
        }
        else if( szKey == "value" )
        {
            m_ilValue= atoi( szValue );
            return true;
        }
        else 
            return BaseClass.KeyValue( szKey, szValue );
    }

    void Precache()
    {
        g_Game.PrecacheModel( "sprites/laserbeam.spr" );
        g_Game.PrecacheGeneric( "sprites/laserbeam.spr" );

		g_SoundSystem.PrecacheSound( "weapons/shock_fire.wav" );
		g_Game.PrecacheGeneric( "sound/weapons/shock_fire.wav" );

        BaseClass.Precache();
    }

	void Spawn() 
	{
        self.Precache();
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_NOT;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		SetThink( ThinkFunction( this.FindEntity ) );
        self.pev.nextthink = g_Engine.time + 0.1f;

        BaseClass.Spawn();
	}

    void FindEntity()
    {
        for( int playerID = 1; playerID <= g_PlayerFuncs.GetNumPlayers(); playerID++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( playerID );
            
            if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                continue;

            if( ( self.pev.origin - pPlayer.pev.origin ).Length() <= m_ilRadius && self.FVisibleFromPos( pPlayer.pev.origin, self.pev.origin ) )
            {
                if( pPlayer.pev.health >= 0 && m_ilType == 0 )
                {
                    Beam( pPlayer );
                    pPlayer.TakeDamage( self.pev, self.pev, m_ilValue * 1.2, DMG_SHOCK | DMG_RADIATION );
                }
                else if( pPlayer.pev.health < pPlayer.pev.max_health && m_ilType == 1 )
                {
                    Beam( pPlayer );
                    pPlayer.pev.health = pPlayer.pev.health + m_ilValue;
                }
                else if( pPlayer.pev.armorvalue < pPlayer.pev.armortype && m_ilType == 2 )
                {
                    Beam( pPlayer );
                    pPlayer.pev.armorvalue = pPlayer.pev.armorvalue + m_ilValue;
                }
                else if( pPlayer.m_rgAmmo( g_PlayerFuncs.GetAmmoIndex( "uranium" ) ) < pPlayer.GetMaxAmmo( "uranium" ) && m_ilType == 3 )
                {                  
                    Beam( pPlayer );
                    pPlayer.GiveAmmo( m_ilValue, "uranium", pPlayer.GetMaxAmmo( "uranium" ) );
                }
            }
            else
            {
                if( pPlayer.pev.rendercolor == self.pev.rendercolor )
                {
                    pPlayer.pev.rendermode  = kRenderNormal;
                    pPlayer.pev.renderfx    = kRenderFxNone;
                    pPlayer.pev.renderamt   = 255;
                    pPlayer.pev.rendercolor = Vector(0,0,0); 
                }
            }
        }

        self.pev.nextthink = g_Engine.time + 0.1f;
    }

    void Beam( CBaseEntity@ pPlayer )
    {
        @pBorderBeam = g_EntityFuncs.CreateBeam( "sprites/laserbeam.spr", 30 );
        pBorderBeam.SetFlags( BEAM_POINTS );
        pBorderBeam.SetStartPos( self.pev.origin );
        pBorderBeam.SetEndPos( pPlayer.Center() );
        pBorderBeam.SetBrightness( 128 );
        pBorderBeam.SetScrollRate( 100 );
        pBorderBeam.LiveForTime( 0.10 );
        pBorderBeam.pev.rendercolor = self.pev.rendercolor == g_vecZero ? Vector( 255, 0, 0 ) : self.pev.rendercolor;

        if( pPlayer.pev.rendercolor == g_vecZero )
        {
            pPlayer.pev.rendermode  = kRenderNormal;
            pPlayer.pev.renderfx    = kRenderFxGlowShell;
            pPlayer.pev.renderamt   = 4;
            pPlayer.pev.rendercolor = self.pev.rendercolor;
        }
        
        return;   
    }
}

void RegisterEnvCrystal() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "env_crystal", "env_crystal" );
}