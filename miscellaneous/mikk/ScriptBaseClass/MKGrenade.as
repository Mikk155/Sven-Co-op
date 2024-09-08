/***
 *
 *	Copyright (c) 1996-2001, Valve LLC. All rights reserved.
 *
 *	This product contains software technology licensed from Id
 *	Software, Inc. ("Id Technology").  Id Technology (c) 1996 Id Software, Inc.
 *	All Rights Reserved.
 *
 *   Use, distribution, and modification of this source code and/or resulting
 *   object code is restricted to non-commercial enhancements to products from
 *   Valve LLC.  All other use, distribution, or modification is prohibited
 *   without written permission from Valve LLC.
 *
 ****/

MKGrenade@ ShootContact( edict_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity )
{
    MKGrenade@ pGrenade = cast<MKGrenade>( CastToScriptClass( g_EntityFuncs.Create( 'mk_grenade', vecStart, g_vecZero, true ) ) );

    if( pGrenade is null )
        return;

	pGrenade.Spawn();
	// contact grenades arc lower
	pGrenade.pev.gravity = 0.5;// lower gravity since grenade is aerodynamic and engine doesn't know it.
    g_EntityFuncs.SetOrigin( pGrenade.pev, VecStart );
	pGrenade.pev.velocity = vecVelocity;
	pGrenade.pev.angles = g_Utility.VecToAngles( pGrenade.pev.velocity );
	pGrenade.pev.owner = pevOwner;

	// make monsters afaid of it while in the air
	pGrenade.SetThink( ThinkFunction( this.DangerSoundThink ) );
	pGrenade.pev.nextthink = g_Engine.time;

	// Tumble in air
	pGrenade.pev.avelocity.x = Math.RandomFloat( -100, -500 );

	// Explode on contact
	pGrenade.SetTouch( TouchFunction( this.ExplodeTouch ) );

    pGrenade.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_hand_grenade' );

	return @pGrenade;
}

// Grenades flagged with this will be triggered when the owner calls detonateSatchelCharges
const int SF_DETONATE = ( 1 << 0 );

int g_sModelIndexSmoke = -1;
int g_sModelIndexFireball = -1;
int g_sModelIndexWExplosion = -1;

// Contact Grenade / Timed grenade / Satchel Charge
class MKGrenade : ScriptBaseMonsterEntity
{
    void Spawn()
    {
        Precache();

        pev.movetype = MOVETYPE_BOUNCE;
        pev.solid = SOLID_BBOX;

        g_EntityFuncs.SetModel( self, "models/grenade.mdl" );
        g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );

        pev.dmg = 100;
        m_fRegisteredSound = false;
    }

    void Precache()
    {
        g_sModelIndexSmoke = g_Game.PrecacheModel( "sprites/steam1.spr");// smoke
        g_sModelIndexFireball = g_Game.PrecacheModel( "sprites/zerogxplode.spr");// fireball
        g_sModelIndexWExplosion = g_Game.PrecacheModel( "sprites/WXplo1.spr");// underwater fireball
    }

    MKGrenade@ ShootTimed( entvars_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity, float flTime )
    {
        return this;
    }


    MKGrenade@ ShootSatchelCharge( entvars_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity )
    {
        return this;
    }

	void UseSatchelCharges( entvars_t@ pevOwner, SATCHELCODE code )
    {

    }

	void Explode( Vector vecSrc, Vector vecAim )
    {
    	TraceResult tr;
        g_Utility.TraceLine( pev.origin, pev.origin + Vector( 0, 0, -32 ), ignore_monsters, self.edict(), tr );

        Explode( tr, DMG_BLAST );
    }

	void Explode( TraceResult pTrace, int bitsDamageType )
    {
        float flRndSound;// sound randomizer

        pev.solid = SOLID_NOT;// intangible

        pev.takedamage = DAMAGE_NO;

        // Pull out of the wall a bit
        if( pTrace.flFraction != 1.0 )
        {
            pev.origin = pTrace.vecEndPos + (pTrace.vecPlaneNormal * (pev.dmg - 24) * 0.6);
        }

        int iContents = g_EngineFuncs.PointContents( pev.origin );

        if( g_sModelIndexFireball == -1 || g_sModelIndexFireball == -1 )
        {
            g_Game.AlertMessage( at_console, 'MKGrenade Attempted to use a model that is not precached! returning...\n' );
            return;
        }

        Mikk.UserMessages.Entity.Explosion( pev.origin, ( iContents != CONTENTS_WATER ? g_sModelIndexFireball : g_sModelIndexWExplosion ), int(( pev.dmg - 50 ) * 0.60), 15, TE_EXPLFLAG_NONE );

        CSoundEnt@ pSound = GetSoundEntInstance();
        pSound.InsertSound( bits_SOUND_COMBAT, pev.origin, NORMAL_EXPLOSION_VOLUME, 0.3, self );

        entvars_t@ pevOwner = null;

        if( g_EntityFuncs.Instance( pev.owner ) !is null )
            @pevOwner = pev.owner.vars;

        @pev.owner = null; // can't traceline attack owner if this is set

        g_WeaponFuncs.RadiusDamage( pev.origin, pev, pevOwner, pev.dmg, int( ( pev.dmg - 50 ) * 0.60 ), CLASS_NONE, bitsDamageType );

        g_Utility.DecalTrace( pTrace, ( Math.RandomFloat( 0, 1 ) < 0.5 ? DECAL_SCORCH1 : DECAL_SCORCH2 ) );

        flRndSound = Math.RandomFloat( 0 , 1 );

        g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, 'weapons/debris' + string( Math.RandomLong( 1, 3 ) ) +'.wav', 0.55, ATTN_NORM );

        pev.effects |= EF_NODRAW;
		SetThink( ThinkFunction( this.Smoke ) );
        pev.velocity = g_vecZero;
        pev.nextthink = g_Engine.time + 0.3;

        if( iContents != CONTENTS_WATER )
        {
            int sparkCount = Math.RandomLong(0,3);
            for ( int i = 0; i < sparkCount; i++ )
                g_EntityFuncs.Create( 'spark_shower', pev.origin, pTrace.vecPlaneNormal, false );
        }
    }

	void Smoke()
    {
        if( g_EngineFuncs.PointContents( pev.origin ) == CONTENTS_WATER )
        {
            g_Utility.Bubbles( pev.origin - Vector( 64, 64, 64 ), pev.origin + Vector( 64, 64, 64 ), 100 );
        }
        else
        {
            Mikk.UserMessages.Entity.Smoke( pev.origin, g_sModelIndexSmoke, int((pev.dmg - 50) * 0.80), 12 );
        }
        g_EntityFuncs.Remove( self );
    }

	void BounceTouch( CBaseEntity@ pOther )
    {
        // don't hit the guy that launched this grenade
        if ( pOther.edict() is pev.owner )
            return;

        // only do damage if we're moving fairly fast
        if( m_flNextAttack < g_Enginetime && pev.velocity.Length() > 100 )
        {
            entvars_t *pevOwner = VARS( pev->owner );
            if (pevOwner)
            {
                TraceResult tr = UTIL_GetGlobalTrace( );
                ClearMultiDamage( );
                pOther->TraceAttack(pevOwner, 1, gpGlobals->v_forward, &tr, DMG_CLUB );
                ApplyMultiDamage( pev, pevOwner);
            }
            m_flNextAttack = gpGlobals->time + 1.0; // debounce
        }

        Vector vecTestVelocity;
        // pev->avelocity = Vector (300, 300, 300);

        // this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
        // or thrown very far tend to slow down too quickly for me to always catch just by testing velocity.
        // trimming the Z velocity a bit seems to help quite a bit.
        vecTestVelocity = pev->velocity;
        vecTestVelocity.z *= 0.45;

        if ( !m_fRegisteredSound && vecTestVelocity.Length() <= 60 )
        {
            //ALERT( at_console, "Grenade Registered!: %f\n", vecTestVelocity.Length() );

            // grenade is moving really slow. It's probably very close to where it will ultimately stop moving.
            // go ahead and emit the danger sound.

            // register a radius louder than the explosion, so we make sure everyone gets out of the way
            CSoundEnt::InsertSound ( bits_SOUND_DANGER, pev->origin, pev->dmg / 0.4, 0.3 );
            m_fRegisteredSound = TRUE;
        }

        if (pev->flags & FL_ONGROUND)
        {
            // add a bit of static friction
            pev->velocity = pev->velocity * 0.8;

            pev->sequence = RANDOM_LONG( 1, 1 );
        }
        else
        {
            // play bounce sound
            BounceSound();
        }
        pev->framerate = pev->velocity.Length() / 200.0;
        if (pev->framerate > 1.0)
            pev->framerate = 1;
        else if (pev->framerate < 0.5)
            pev->framerate = 0;
    }

	void SlideTouch( CBaseEntity@ pOther )
    {

    }

    //
    // Contact grenade, explode when it touches something
    //
	void ExplodeTouch( CBaseEntity@ pOther )
    {
        TraceResult tr;
        Vector vecSpot;// trace starts here!

        pev.enemy = pOther.edict();

        vecSpot = pev.origin - pev.velocity.Normalize() * 32;
        g_Utility.TraceLine( vecSpot, vecSpot + pev.velocity.Normalize() * 64, ignore_monsters, self.edict(), tr );

        Explode( tr, DMG_BLAST );
    }

	void DangerSoundThink()
    {
        if( !self.IsInWorld() )
        {
            g_EntityFuncs.Remove( self );
            return;
        }

        CSoundEnt@ pSound = GetSoundEntInstance();
        pSound.InsertSound( bits_SOUND_DANGER, pev.origin + pev.velocity * 0.5, pev.velocity.Length(), 0.2, self );

        pev.nextthink = gpGlobals.time + 0.2;

        if( pev.waterlevel != 0 )
        {
            pev.velocity = pev.velocity * 0.5;
        }
    }

	void PreDetonate()
    {
        CSoundEnt@ pSound = GetSoundEntInstance();
        pSound.InsertSound( bits_SOUND_DANGER, pev.origin, 400, 0.3, self );

	    SetThink( ThinkFunction( this.Detonate ) );
	    pev.nextthink = gpGlobals.time + 1;
    }

	void Detonate()
    {

        TraceResult tr;
        Vector vecSpot;// trace starts here!


        vecSpot = pev.origin + Vector ( 0 , 0 , 8 );
        g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ),  ignore_monsters, self.edict(), tr );

        Explode( tr, DMG_BLAST );
    }

    // Timed grenade, this think is called when time runs out.
	void DetonateUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
	    SetThink( ThinkFunction( this.Detonate ) );
	    pev.nextthink = gpGlobals.time;
    }

	void TumbleThink()
    {

    }


	void BounceSound()
    {
    }

	int	BloodColor()
    {
        return DONT_BLEED;
    }

    void Killed( entvars_t@ pevAttacker, int iGib )
    {
        Detonate();
    }

	bool m_fRegisteredSound;// whether or not this grenade has issued its DANGER sound to the world sound list yet.
}