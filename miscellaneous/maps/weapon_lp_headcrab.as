namespace weapon_lp_headcrab
{
    void MapInit()
    {
		m_EntityFuncs.CustomEntity( 'weapon_lp_headcrab' );
		g_ItemRegistry.RegisterWeapon( 'weapon_lp_headcrab', String::EMPTY_STRING );
		g_Game.PrecacheOther( 'weapon_lp_headcrab' );
        g_Game.PrecacheOther( "monster_headcrab" );
    }

    enum squeak_e
    {
        SQUEAK_IDLE1 = 0,
        SQUEAK_FIDGETFIT,
        SQUEAK_FIDGETNIP,
        SQUEAK_DOWN,
        SQUEAK_UP,
        SQUEAK_THROW
    };

    class weapon_lp_headcrab : ScriptBasePlayerWeaponEntity, LimitlessPotentialWeapon
    {
        private CBasePlayer@ m_pPlayer = null;
        private array<string> Sounds =
        {
            'headcrab/hc_idle1.wav',
            'headcrab/hc_idle2.wav',
            'headcrab/hc_idle3.wav',
            'headcrab/hc_idle4.wav',
            'headcrab/hc_idle5.wav',
            'headcrab/hc_attack1.wav',
            'headcrab/hc_attack2.wav',
            'headcrab/hc_attack3.wav'
        };

        int m_fJustThrown;

        void Spawn()
        {
            Precache();
            g_EntityFuncs.SetModel( self, "models/headcrab.mdl" );
			self.m_iClip = -1;
            self.m_bExclusiveHold = true;
            self.FallInit();
        }
        
        void Precache()
        {	
			self.PrecacheCustomModels();
            g_Game.PrecacheModel( "models/headcrab.mdl" );
            g_Game.PrecacheModel( "models/limitlesspotential/v2/v_headcrab.mdl" );
            g_Game.PrecacheModel( "models/limitlesspotential/v2/p_headcrab.mdl" );

			for( uint i = 0; i < Sounds.length(); i++ )
            {
				g_SoundSystem.PrecacheSound( Sounds[i] );
                g_Game.PrecacheGeneric( 'sound/' + Sounds[i] );
            }
        }

        bool GetItemInfo( ItemInfo& out info )
        {
			info.iMaxAmmo1 	= -1;
			info.iAmmo1Drop	= -1;
			info.iMaxAmmo2 	= -1;
			info.iAmmo2Drop	= -1;
			info.iMaxClip 	= WEAPON_NOCLIP;
			info.iSlot  	= 0;
			info.iPosition 	= 5;
			info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
			info.iFlags 	= 0;
			info.iWeight 	= 0;

            return true;
        }
        
        bool AddToPlayer( CBasePlayer@ pPlayer )
        {
            if( !BaseClass.AddToPlayer( pPlayer ) )
                return false;
            @m_pPlayer = pPlayer;
            return true;
        }
        
        bool Deploy()
        {
            g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "headcrab/hc_idle" + string( Math.RandomLong( 1, 5 ) ) + ".wav", 1, ATTN_NORM, 0, 105 );
            m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
            return self.DefaultDeploy( self.GetV_Model( "models/limitlesspotential/v2/v_headcrab.mdl" ), self.GetP_Model( "models/limitlesspotential/v2/p_headcrab.mdl" ), SQUEAK_UP, "headcrab" );
        }

		void Holster( int skipLocal = 0 )
		{
            self.SendWeaponAnim( SQUEAK_DOWN );
			BaseClass.Holster( skipLocal );
        }

        void PrimaryAttack()
        {
            if( m_fJustThrown == 1 )
                return;

            g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );
            TraceResult tr;
            Vector trace_origin;

            trace_origin = m_pPlayer.pev.origin;

            if( m_pPlayer.pev.button & IN_DUCK != 0 )
            {
                trace_origin = trace_origin - ( VEC_HULL_MIN - VEC_DUCK_HULL_MIN );
            }

            g_Utility.TraceLine( trace_origin + g_Engine.v_forward * 20, trace_origin + g_Engine.v_forward * 64, dont_ignore_monsters, null, tr );
            
            if ( tr.fAllSolid == 0 && tr.fStartSolid == 0 && tr.flFraction > 0.25 )
            {
                self.SendWeaponAnim( SQUEAK_THROW );
                m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

                CBaseEntity@ pSqueak = g_EntityFuncs.CreateEntity( 'monster_headcrab', null, true );
                Vector VecPos = m_pPlayer.pev.origin + m_pPlayer.GetAutoaimVector(0.0f) * 64;
                g_EntityFuncs.SetOrigin( pSqueak, VecPos );
                pSqueak.pev.angles.y = m_pPlayer.pev.v_angle.y;
                pSqueak.pev.velocity = g_Engine.v_forward * 200 + m_pPlayer.pev.velocity;
                pSqueak.SetClassification( CLASS_PLAYER_ALLY );
                @pSqueak.pev.owner = m_pPlayer.edict();
                cast<CBaseMonster@>(pSqueak).m_FormattedName = string( m_pPlayer.pev.netname ) + '\'s headcrab';
                pSqueak.pev.health = self.pev.health;

                g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "headcrab/hc_attack" + string( Math.RandomLong( 1, 3 ) ) + ".wav", 1, ATTN_NORM, 0, 105 );

                m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
                m_fJustThrown = 1;
                self.m_flTimeWeaponIdle = 0.3f;
                self.m_flNextPrimaryAttack = g_Engine.time + 1.5f;
            }
        }
        
        void WeaponIdle()
        {
            if ( self.m_flTimeWeaponIdle > g_Engine.time )
                return;

            if ( m_fJustThrown == 1 )
            {
                CBasePlayerItem@ pItem = m_pPlayer.HasNamedPlayerItem( "weapon_lp_headcrab" );

                if( pItem !is null )
                {
                    m_pPlayer.RemovePlayerItem( pItem );
                }
                return;
            }
            
            int iAnim;
            float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
            if ( flRand <= 0.75 )
            {
                iAnim = SQUEAK_IDLE1;
                self.m_flTimeWeaponIdle = g_Engine.time + 30.0 / 16 * ( 2 );
            }
            else if ( flRand <= 0.875 )
            {
                iAnim = SQUEAK_FIDGETFIT;
                self.m_flTimeWeaponIdle = g_Engine.time + 70.0 / 16.0;
            }
            else
            {
                iAnim = SQUEAK_FIDGETNIP;
                self.m_flTimeWeaponIdle = g_Engine.time + 80.0 / 16.0;
            }
            self.SendWeaponAnim( iAnim );
        }
    }
}