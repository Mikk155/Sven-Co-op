void RegisterGravGun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CGravGun", "weapon_gravgun" );
	g_ItemRegistry.RegisterWeapon( "weapon_gravgun", "hl_weapons", "" );
}

enum gravgun_e
{
	GRAVGUN_IDLE = 0,
	GRAVGUN_IDLE2,
	GRAVGUN_FIDGET,
	GRAVGUN_SPINUP,
	GRAVGUN_SPIN,
	GRAVGUN_FIRE,
	GRAVGUN_FIRE2,
	GRAVGUN_HOLSTER,
	GRAVGUN_DRAW
};

class CGravGun : ScriptBasePlayerWeaponEntity
{
    float m_flNextIdleTime;
    EHandle m_pCurrentEntity;
    bool m_bResetIdle;
    bool m_bFoundPotentialTarget;

	private CBasePlayer@ m_pPlayer
	{
		get const	{ return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set       	{ self.m_hPlayer = EHandle( @value ); }
	}

    //**********************************************
    //* Weapon spawn                               *
    //**********************************************
    void Spawn()
    {
        Precache();
        g_EntityFuncs.SetModel( self, self.GetW_Model( "models/gravitygun/w_gravitygun.mdl" ) );

        self.m_iDefaultAmmo = -1;
        self.m_iClip = -1;

        self.FallInit();// get ready to fall down.
    }

    //**********************************************
    //* Precache resources                         *
    //**********************************************
    void Precache()
    {
        g_Game.PrecacheModel( "models/gravitygun/v_gravitygun.mdl" );
        g_Game.PrecacheModel( "models/gravitygun/p_gravitygun.mdl" );
        g_Game.PrecacheModel( "models/gravitygun/w_gravitygun.mdl" );
    }

    //**********************************************
    //* Register weapon                            *
    //**********************************************
	bool GetItemInfo( ItemInfo& out info )
	{
        info.iMaxAmmo1  = -1;
		info.iMaxAmmo2	= -1;
        info.iMaxClip   = WEAPON_NOCLIP;
        info.iSlot      = 0;
        info.iPosition  = 7;
        info.iFlags     = 0;
        info.iWeight    = 22;

        return true;
    }


    //**********************************************
    //* Add the weapon to the player               *
    //**********************************************
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
			
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();

		return true;
	}

    //**********************************************
    //* Deploys the weapon                         *
    //**********************************************
	bool Deploy()
	{
        return self.DefaultDeploy( self.GetV_Model( "models/gravitygun/v_gravitygun.mdl" ), self.GetP_Model( "models/gravitygun/p_gravitygun.mdl" ), GRAVGUN_DRAW, "gauss" );
	}

    //**********************************************
    //* Holster the weapon                         *
    //**********************************************
	void Holster( int skiplocal /* = 0 */ )
	{	
		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5;		
		self.SendWeaponAnim( GRAVGUN_HOLSTER );

        g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "gravitygun/pulse.wav" );

        //BaseClass.Holster( skipLocal );
	}

    void PrimaryAttack()
    {
        int idx = 0;
        bool isBspModel = false;

        if( m_pCurrentEntity.GetEntity() !is null )
        {
            Vector forward = m_pPlayer.GetAutoaimVector(0.0f);

            idx = m_pCurrentEntity.GetEntity().entindex();

            if( m_pCurrentEntity.GetEntity().IsBSPModel() )
                isBspModel = true;

            m_pCurrentEntity.GetEntity().pev.velocity = m_pPlayer.pev.velocity + forward * 512;
            m_pCurrentEntity = null;
            self.m_flTimeWeaponIdle = g_Engine.time;
        }
        else
        {
            CBaseEntity@ pEntity = GetEntity( 128, true ).GetEntity();

            TraceResult tr = g_Utility.GetGlobalTrace();

            if( pEntity !is null )
            {
                idx = pEntity.entindex();
                isBspModel = pEntity.IsBSPModel();

                g_WeaponFuncs.ClearMultiDamage();
                pEntity.TraceAttack( m_pPlayer.pev, 1, g_Engine.v_forward, tr, DMG_ENERGYBEAM );
                g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
                pEntity.pev.velocity = g_Engine.v_forward * 256;

                self.m_flTimeWeaponIdle = g_Engine.time;
            }      
        }

        g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "gravitygun/pulse.wav" );
        self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.4;
        m_flNextIdleTime = g_Engine.time + 2.0f;
    }

    void SecondaryAttack()
    {
        if( m_pCurrentEntity.GetEntity() !is null )
        {
            g_SoundSystem.StopSound( m_pPlayer.edict(), CHAN_WEAPON, "gravitygun/pulse.wav" );
            m_pCurrentEntity.GetEntity().pev.velocity = m_pPlayer.pev.velocity;
            m_pCurrentEntity = null;
        }
        else
        {
            m_pCurrentEntity = GetEntity( 128 , false ).GetEntity();

            if( m_pCurrentEntity.GetEntity() !is null )
            {
                m_pCurrentEntity.GetEntity().pev.origin.y += 0.2f;
                self.SendWeaponAnim(GRAVGUN_SPIN);
                g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "gravitygun/pulse.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH );
                self.m_flTimeWeaponIdle = g_Engine.time + 0.53f;
            }
        }

        self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.4;

        m_flNextIdleTime = g_Engine.time + 2.0f;

        if( m_pCurrentEntity.GetEntity() is null )
            self.SendWeaponAnim(GRAVGUN_FIRE);
    }

    void ItemPostFrame()
    {
        if( m_pCurrentEntity.GetEntity() !is null )
        {
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "gravitygun/mmmsoup.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH );
			
            m_pPlayer.GetAutoaimVector(0.0f);

            if( m_pCurrentEntity.GetEntity().IsBSPModel() )
            {
                m_pCurrentEntity.GetEntity().pev.velocity = ((m_pPlayer.pev.origin - m_pCurrentEntity.GetEntity().Center()) + g_Engine.v_forward * 86) * 35;
            }
            else
            {
                if( !m_pCurrentEntity.GetEntity().GetClassname().StartsWith( "weapon_", String::DEFAULT_COMPARE ) || !m_pCurrentEntity.GetEntity().GetClassname().StartsWith( "item_", String::DEFAULT_COMPARE ) )
                    m_pCurrentEntity.GetEntity().pev.velocity = ((m_pPlayer.pev.origin - m_pCurrentEntity.GetEntity().Center()) + g_Engine.v_forward * 86 + Vector(0, 0, 24)) * 35;
                else
                    m_pCurrentEntity.GetEntity().pev.velocity = ((m_pPlayer.pev.origin - m_pCurrentEntity.GetEntity().Center()) + g_Engine.v_forward * 86) * 35;
            }
        }

		BaseClass.ItemPostFrame();
	}

    EHandle GetEntity( float fldist, bool m_bTakeDamage )
    {
        TraceResult tr;

        Vector forward = m_pPlayer.GetAutoaimVector(0.0f);
        Vector vecSrc = m_pPlayer.GetGunPosition();
        Vector vecEnd = vecSrc + forward * fldist;
        CBaseEntity@ pEntity = null;

        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

        if( tr.pHit is null )
        {
            @pEntity = FindEntityForward( tr.vecEndPos ).GetEntity();
        }
        else
        {
            @pEntity = g_EntityFuncs.Instance( tr.pHit );
        } 

        if( m_bTakeDamage )
        {
            if( pEntity is null )
                return EHandle(null);

            if ((pEntity.IsBSPModel() && (pEntity.pev.movetype == MOVETYPE_PUSHSTEP || pEntity.pev.takedamage == DAMAGE_YES)))
            {
                return EHandle(pEntity);
            }
        }
        else
        {
            if( pEntity is null || (pEntity.IsBSPModel() && pEntity.pev.movetype != MOVETYPE_PUSHSTEP))
            {
                @pEntity = FindEntityForward( tr.vecEndPos ).GetEntity();
            }

            if ( pEntity is null || (pEntity.IsBSPModel() && pEntity.pev.movetype != MOVETYPE_PUSHSTEP))
                return EHandle(null);
        }
        if( pEntity is m_pPlayer )
            return EHandle(null);

        return EHandle(pEntity);
    }

    void WeaponIdle()
    {	
        CBaseEntity@ pPotentialTarget = null;

        if( m_flNextIdleTime > g_Engine.time )
            return;

        if( m_pCurrentEntity.GetEntity() is null )
        {
            @pPotentialTarget = GetEntity( 128, false ).GetEntity();

            if( m_bFoundPotentialTarget && pPotentialTarget is null )
            {
                m_bFoundPotentialTarget = false;
                m_bResetIdle = true;
            }
            else if( pPotentialTarget !is null && !m_bFoundPotentialTarget )
            {
                m_bResetIdle = true;
            }	
        }

        if( m_bResetIdle )
        {
            self.m_flTimeWeaponIdle = g_Engine.time;
            m_bResetIdle = false;
        }

        if( self.m_flTimeWeaponIdle > g_Engine.time )
            return;

        if( m_pCurrentEntity.GetEntity() !is null )
        {
            self.SendWeaponAnim(GRAVGUN_SPIN);
            self.m_flTimeWeaponIdle = g_Engine.time + 0.53;
        }
        else
        {
            if( pPotentialTarget !is null )
            {
                self.SendWeaponAnim(GRAVGUN_SPINUP);
                self.m_flTimeWeaponIdle = g_Engine.time + 1.0f;
                m_bFoundPotentialTarget = true;
            }
            else
            {
                int iAnim;
                float flRand = Math.RandomFloat( 0, 1 );
                if ( flRand <= 0.5 )
                {
                    iAnim = GRAVGUN_IDLE;
                    self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
                }
                else
                {
                    iAnim = GRAVGUN_IDLE2;
                    self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
                }
                self.SendWeaponAnim(iAnim);
            }
        }
    }

    EHandle FindEntityForward( Vector vecEndPos )
    {
        CBaseEntity@[] pEnts( 64 );
		Vector vecMin = vecEndPos + Vector( -8, -8, -8 ), vecMax = vecEndPos + Vector( 8, 8, 8 );
		int iEntitiesInBox = g_EntityFuncs.EntitiesInBox( @pEnts, vecMin, vecMax, 0 );

		for( int i = 0; i < iEntitiesInBox; i++ )
		{
            if( pEnts[i] !is null && !pEnts[i].IsPlayer() && pEnts[i].pev.classname != "worldspawn" )
            {
                return EHandle(pEnts[i]);
            }
        }   

        return EHandle(null);
    }
}    