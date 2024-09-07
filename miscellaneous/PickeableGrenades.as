CPickeableGrenades pickable_grenades;

class CPickeableGrenades
{
    CCVar@ pickable_grenades_radius;

    void MapInit()
    {
        @pickable_grenades_radius = CCVar("pickable_grenades_radius", 80, "Pickup radius for hand grenades", ConCommandFlag::AdminOnly);
        g_CustomEntityFuncs.RegisterCustomEntity( 'CLimitlessPotentialHandGrenade', 'weapon_lp_handgrenade' );
        g_Game.PrecacheOther( 'weapon_lp_handgrenade' );
        @g_Think = g_Scheduler.SetInterval( @this, "RemapGrenades", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
        //m_FileSystem.GetKeyAndValue( m_iszMessageTextPath + 'weapon_lp_grenade_throw.txt', weapon_lp_grenade_throw, true );
        //m_FileSystem.GetKeyAndValue( m_iszMessageTextPath + 'weapon_lp_grenade_pickup.txt', weapon_lp_grenade_pickup, true );
    }

    //dictionary weapon_lp_grenade_throw, weapon_lp_grenade_pickup;

    CScheduledFunction@ g_Think = null;

    void RemapGrenades()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'grenade' ) ) !is null && pEntity.pev.friction == 0.8 )
        {
            CBaseEntity@ pOwner = g_EntityFuncs.Instance( pEntity.pev.owner );

            if( pOwner !is null )
            {/*
                CBaseEntity@ pGrenade = m_EntityFuncs.CreateEntity
                (
                    {
                        { 'origin', pEntity.pev.origin.ToString() },
                        { 'classname', 'weapon_lp_handgrenade' },
                        { 'dmgtime', string( pEntity.pev.dmgtime ) },
                        { 'velocity', pEntity.pev.velocity.ToString() }
                    }
                );*/
                CBaseEntity@ pGrenade = g_EntityFuncs.CreateEntity( 'weapon_lp_handgrenade', null, true );

                if( pGrenade !is null )
                {
                    g_EntityFuncs.SetOrigin( pGrenade, pEntity.pev.origin );
                    pGrenade.pev.dmgtime = pEntity.pev.dmgtime;
                    pGrenade.pev.velocity = pEntity.pev.velocity;
                    @pGrenade.pev.owner = @pOwner.edict();
                    g_EntityFuncs.Remove( pEntity );
                }
            }
        }
    }
}

class CLimitlessPotentialHandGrenade : ScriptBaseMonsterEntity
{
    bool m_fRegisteredSound = false;

    void Spawn()
    {
        Precache();
        
        self.pev.movetype = MOVETYPE_BOUNCE;
        self.pev.solid = SOLID_BBOX;
        self.m_bloodColor = DONT_BLEED;
        
        g_EntityFuncs.SetModel( self, "models/w_grenade.mdl" );
        g_EntityFuncs.SetSize( self.pev, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );

        self.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_hand_grenade' );
        self.pev.sequence = Math.RandomLong( 3, 6 );
        self.pev.framerate = 1.0;
        self.pev.gravity = 0.5;
        self.pev.friction = 0.8;

        m_fRegisteredSound = false;
        SetTouch( TouchFunction( BounceTouch ) );
        SetThink( ThinkFunction( TumbleThink ) );
        self.pev.nextthink = g_Engine.time + 0.1;
    }

    void Precache()
    {
        g_Game.PrecacheModel( "models/w_grenade.mdl" );
        
        g_SoundSystem.PrecacheSound( "weapons/grenade_hit1.wav" );
        g_SoundSystem.PrecacheSound( "weapons/grenade_hit2.wav" );
        g_SoundSystem.PrecacheSound( "weapons/grenade_hit3.wav" );
    }
    
    void BounceTouch( CBaseEntity@ pOther )
    {
        if ( pOther.edict() is self.pev.owner )
            return;
        
        if ( self.m_flNextAttack < g_Engine.time && self.pev.velocity.Length() > 100 )
        {
            entvars_t@ pevOwner = self.pev.owner.vars;
            if ( pevOwner !is null )
            {
                TraceResult tr = g_Utility.GetGlobalTrace();
                g_WeaponFuncs.ClearMultiDamage();
                pOther.TraceAttack( pevOwner, 1, g_Engine.v_forward, tr, DMG_CLUB );
                g_WeaponFuncs.ApplyMultiDamage( self.pev, pevOwner );
            }
            self.m_flNextAttack = g_Engine.time + 1.0; // debounce
        }

        Vector vecTestVelocity;
        
        vecTestVelocity = self.pev.velocity; 
        vecTestVelocity.z *= 0.45;
        
        if ( !m_fRegisteredSound && vecTestVelocity.Length() <= 60 )
        {
            CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
            CSoundEnt@ soundEnt = GetSoundEntInstance();
            soundEnt.InsertSound( bits_SOUND_DANGER, self.pev.origin, int( self.pev.dmg / 0.4 ), 0.3, pOwner );
            m_fRegisteredSound = true;
        }
        
        int bCheck = self.pev.flags;
        if ( ( bCheck &= FL_ONGROUND ) == FL_ONGROUND )
        {
            self.pev.velocity = self.pev.velocity * 0.8;
            
            self.pev.sequence = Math.RandomLong( 1, 1 ); // Really? Why not just use "1" instead? -Giegue
        }
        else
        {
            BounceSound();
        }
        
        self.pev.framerate = self.pev.velocity.Length() / 200.0;
        if ( self.pev.framerate > 1.0 )
            self.pev.framerate = 1;
        else if ( self.pev.framerate < 0.5 )
            self.pev.framerate = 0;
    }
    
    void TumbleThink()
    {
        if ( !self.IsInWorld() )
        {
            CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
            UpdateOnRemove();
            g_EntityFuncs.Remove( pThis );
            return;
        }

        CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
        
        self.StudioFrameAdvance();
        self.pev.nextthink = g_Engine.time + 0.1;
        
        if ( self.pev.dmgtime - 1 < g_Engine.time )
        {
            CSoundEnt@ soundEnt = GetSoundEntInstance();
            soundEnt.InsertSound( bits_SOUND_DANGER, self.pev.origin + self.pev.velocity * ( self.pev.dmgtime - g_Engine.time ), 400, 0.1, pOwner );
        }
        
        if ( self.pev.dmgtime <= g_Engine.time )
        {
            SetThink( ThinkFunction( Detonate ) );
        }
        if ( self.pev.waterlevel != 0 )
        {
            self.pev.velocity = self.pev.velocity * 0.5;
            self.pev.framerate = 0.2;
        }

        if( bUsing )
        {
            Vector VecPos = pOwner.pev.origin + cast<CBasePlayer@>(pOwner).GetAutoaimVector(0.0f) * 64;

            g_EntityFuncs.SetOrigin( self, VecPos );

            g_PlayerFuncs.PrintKeyBindingString( cast<CBasePlayer@>(pOwner), 'Press +attack to throw grenade' + '\n' );
            // m_Language.PrintMessage( cast<CBasePlayer@>(pOwner), lp_handgrenade.weapon_lp_grenade_throw, ML_BIND, false, { { '$args$', '+attack' } } );

            if( pOwner.pev.button & IN_ATTACK != 0 )
            {
                self.pev.velocity = pOwner.pev.velocity + cast<CBasePlayer@>(pOwner).GetAutoaimVector(0.0f) * 512;
                cast<CBasePlayer@>(pOwner).UnblockWeapons( self );
                bUsing = false;
            }
        }
        else if( self.pev.flags & FL_ONGROUND != 0 )
        {
            for( int i = 1; i <= g_Engine.maxClients; i++ ) 
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

                if( pPlayer !is null && pPlayer.IsConnected() && ( self.pev.origin - pPlayer.pev.origin ).Length() < pickable_grenades.pickable_grenades_radius.GetInt() )
                {
                    g_PlayerFuncs.PrintKeyBindingString( pPlayer, 'Hold +use to pick up grenade' + '\n' );
                    //m_Language.PrintMessage( pPlayer, lp_handgrenade.weapon_lp_grenade_pickup, ML_BIND, false, { { '$args$', '+use' } } );

                    if( pPlayer.pev.button & IN_USE != 0 )
                    {
                        @self.pev.owner = pPlayer.edict();

                        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                            msg.WriteString( ';' + 'takecover' + ';' );
                        msg.End();

                        pPlayer.BlockWeapons( self );

                        bUsing = true;
                    }
                }
            }
        }
    }

    void UpdateOnRemove()
    {
        CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );
        
        if( pOwner !is null && pOwner.IsPlayer() )
        {
            cast<CBasePlayer@>(pOwner).UnblockWeapons( self );
        }

        BaseClass.UpdateOnRemove();
    }
    
    private bool bUsing;

    void Detonate()
    {
        CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
        
        TraceResult tr;
        Vector vecSpot; // trace starts here!
        
        vecSpot = self.pev.origin + Vector ( 0, 0, 8 );
        g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, self.edict(), tr );
        
        g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), self.pev.owner, int( self.pev.dmg ), false ); // Effect
        g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );

        UpdateOnRemove();

        g_EntityFuncs.Remove( pThis );
    }
    
    void BounceSound()
    {
        switch ( Math.RandomLong( 0, 2 ) )
        {
            case 0:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/grenade_hit1.wav", 0.25, ATTN_NORM ); break;
            case 1:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/grenade_hit2.wav", 0.25, ATTN_NORM ); break;
            case 2:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/grenade_hit3.wav", 0.25, ATTN_NORM ); break;
        }
    }
}
