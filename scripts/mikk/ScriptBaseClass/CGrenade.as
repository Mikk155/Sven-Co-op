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

#include "../UserMessages"

/*
    @prefix #include CGrenade
    @body #include "${1:../../}mikk/CGrenade"
    @description CGrenade como una class para heredar
*/
namespace CGrenade
{
    const string classname = 'as_grenade';

    bool blAutoRegister = Register();

    /*
        @prefix CGrenade CGrenade::Register
        @body CGrenade::Register()
        @description Registra la class CGrenade, en map_scripts esto es automatico sin embargo en plugins debes registrarla.
    */
    bool Register()
    {
        if( g_Engine.time > 1 ) {
            return false;
        }

        g_CustomEntityFuncs.RegisterCustomEntity( 'CGrenade::Class', classname );
        g_Game.PrecacheOther( classname );
        return g_CustomEntityFuncs.IsCustomEntity( classname );
    }

    /*
        @prefix CGrenade CGrenade::GetClass GetClass
        @body CGrenade::GetClass( CBaseEntity@ pEntity )
        @description Retorna la instancia de CGrenade
    */
    Class@ GetClass( CBaseEntity@ pEntity ) {
        return cast<Class>( CastToScriptClass( pEntity ) );
    }

    /*
        @prefix CGrenade CGrenade::GetEntity GetEntity
        @body CGrenade::GetEntity( Class@ pEntity )
        @description Retorna la entidad de CGrenade
    */
    CBaseEntity@ GetEntity( Class@ pEntity ) {
        return cast<CBaseEntity>( pEntity );
    }

    // Contact Grenade / Timed grenade / Satchel Charge
    class Class : ScriptBaseMonsterEntity
    {
        // Grenades flagged with this will be triggered when the owner calls detonateSatchelCharges
        int SF_DETONATE = ( 1 << 0 );

        int g_sModelIndexSmoke;
        int g_sModelIndexFireball;
        int g_sModelIndexWExplosion;

        float m_flNextAttack;

        void Precache()
        {
            g_sModelIndexSmoke = g_Game.PrecacheModel( "sprites/steam1.spr");// smoke
            g_sModelIndexFireball = g_Game.PrecacheModel( "sprites/zerogxplode.spr");// fireball
            g_sModelIndexWExplosion = g_Game.PrecacheModel( "sprites/WXplo1.spr");// underwater fireball
        }

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

        void UseSatchelCharges( entvars_t@ pevOwner, SATCHELCODE code )
        {
        /*
            edict_t *pentFind;
            edict_t *pentOwner;

            if ( !pevOwner )
                return;

            CBaseEntity	*pOwner = CBaseEntity::Instance( pevOwner );

            pentOwner = pOwner->edict();

            pentFind = FIND_ENTITY_BY_CLASSNAME( NULL, "grenade" );
            while ( !FNullEnt( pentFind ) )
            {
                CBaseEntity *pEnt = Instance( pentFind );
                if ( pEnt )
                {
                    if ( FBitSet( pEnt->pev->spawnflags, SF_DETONATE ) && pEnt->pev->owner == pentOwner )
                    {
                        if ( code == SATCHEL_DETONATE )
                            pEnt->Use( pOwner, pOwner, USE_ON, 0 );
                        else	// SATCHEL_RELEASE
                            pEnt->pev->owner = NULL;
                    }
                }
                pentFind = FIND_ENTITY_BY_CLASSNAME( pentFind, "grenade" );
            }
        */
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

            UserMessages::Explosion( pev.origin, ( iContents != CONTENTS_WATER ? g_sModelIndexFireball : g_sModelIndexWExplosion ), int( ( pev.dmg - 50 ) * 0.60 ), 15, TE_EXPLFLAG_NONE );

            CSoundEnt@ pSound = GetSoundEntInstance();
            pSound.InsertSound( bits_SOUND_COMBAT, pev.origin, NORMAL_EXPLOSION_VOLUME, 0.3, self );

            entvars_t@ pevOwner = null;

            if( g_EntityFuncs.Instance( pev.owner ) !is null )
                @pevOwner = pev.owner.vars;

            @pev.owner = null; // can't traceline attack owner if this is set

            g_WeaponFuncs.RadiusDamage( pev.origin, pev, pevOwner, pev.dmg, int( pev.dmg  ), CLASS_NONE, bitsDamageType );

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
                UserMessages::Smoke( pev.origin, g_sModelIndexSmoke, int( ( pev.dmg - 50) * 0.80 ), 12 );
            }
            g_EntityFuncs.Remove( self );
        }

        void BounceTouch( CBaseEntity@ pOther )
        {
            // don't hit the guy that launched this grenade
            if ( pOther.edict() is pev.owner )
                return;

            // only do damage if we're moving fairly fast
            if( m_flNextAttack < g_Engine.time && pev.velocity.Length() > 100 )
            {
                entvars_t@ pevOwner = pev.owner.vars;

                if( pevOwner !is null )
                {
                    TraceResult tr = g_Utility.GetGlobalTrace();
                    g_WeaponFuncs.ClearMultiDamage();
                    pOther.TraceAttack( pevOwner, 1, g_Engine.v_forward, tr, DMG_CLUB );
                    g_WeaponFuncs.ApplyMultiDamage( pev, pevOwner );
                }
                m_flNextAttack = g_Engine.time + 1.0; // debounce
            }

            Vector vecTestVelocity;
            // pev.avelocity = Vector (300, 300, 300);

            // this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
            // or thrown very far tend to slow down too quickly for me to always catch just by testing velocity.
            // trimming the Z velocity a bit seems to help quite a bit.
            vecTestVelocity = pev.velocity;
            vecTestVelocity.z *= 0.45;

            if ( !m_fRegisteredSound && vecTestVelocity.Length() <= 60 )
            {
                //ALERT( at_console, "Grenade Registered!: %f\n", vecTestVelocity.Length() );

                // grenade is moving really slow. It's probably very close to where it will ultimately stop moving.
                // go ahead and emit the danger sound.

                // register a radius louder than the explosion, so we make sure everyone gets out of the way
                CSoundEnt@ pSound = GetSoundEntInstance();
                pSound.InsertSound( bits_SOUND_DANGER, pev.origin, int(pev.dmg / 0.4), 0.3, self );
                m_fRegisteredSound = true;
            }

            if( pev.flags & FL_ONGROUND != 0 )
            {
                // add a bit of static friction
                pev.velocity = pev.velocity * 0.8;

                pev.sequence = Math.RandomLong( 1, 1 );
            }
            else
            {
                // play bounce sound
                BounceSound();
            }
            pev.framerate = pev.velocity.Length() / 200.0;
            if (pev.framerate > 1.0)
                pev.framerate = 1;
            else if (pev.framerate < 0.5)
                pev.framerate = 0;
        }

        void SlideTouch( CBaseEntity@ pOther )
        {
            // don't hit the guy that launched this grenade
            if( pOther is null || pOther.edict() is pev.owner )
                return;

            // pev.avelocity = Vector (300, 300, 300);

            if( pev.flags & FL_ONGROUND != 0 )
            {
                // add a bit of static friction
                pev.velocity = pev.velocity * 0.95;

                if( pev.velocity.x != 0 || pev.velocity.y != 0 )
                {
                    // maintain sliding sound
                }
            }
            else
            {
                BounceSound();
            }
        }

        //
        // Contact grenade, explode when it touches something
        //
        void ExplodeTouch( CBaseEntity@ pOther )
        {
            TraceResult tr;
            Vector vecSpot;// trace starts here!

            @pev.enemy = pOther.edict();

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
            pSound.InsertSound( bits_SOUND_DANGER, pev.origin + pev.velocity * 0.5, int(pev.velocity.Length()), 0.2, self );

            pev.nextthink = g_Engine.time + 0.2;

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
            pev.nextthink = g_Engine.time + 1;
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
            pev.nextthink = g_Engine.time;
        }

        void TumbleThink()
        {
            if( !self.IsInWorld() )
            {
                g_EntityFuncs.Remove( self );
                return;
            }

            self.StudioFrameAdvance();
            pev.nextthink = g_Engine.time + 0.1;

            if( pev.dmgtime - 1 < g_Engine.time)
            {
                CSoundEnt@ pSound = GetSoundEntInstance();
                pSound.InsertSound( bits_SOUND_DANGER, pev.origin+ pev.velocity * (pev.dmgtime - g_Engine.time), 400, 0.1, self );
            }

            if( pev.dmgtime <= g_Engine.time )
            {
                SetThink( ThinkFunction( this.Detonate ) );
            }
            if( pev.waterlevel != 0)
            {
                pev.velocity = pev.velocity * 0.5;
                pev.framerate = 0.2;
            }
        }

        void BounceSound()
        {
            g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, 'weapons/grenade_hit' + string( Math.RandomLong( 1, 3 ) ) +'.wav', 0.25, ATTN_NORM );
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

    Class@ ShootContact( edict_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity )
    {
        Class@ pGrenade = GetClass( g_EntityFuncs.Create( classname, vecStart, g_vecZero, true ) );

        if( pGrenade is null )
            return null;

        pGrenade.Spawn();
        // contact grenades arc lower
        pGrenade.pev.gravity = 0.5;// lower gravity since grenade is aerodynamic and engine doesn't know it.
        g_EntityFuncs.SetOrigin( GetEntity(pGrenade), vecStart );
        pGrenade.pev.velocity = vecVelocity;
        pGrenade.pev.angles = Math.VecToAngles( pGrenade.pev.velocity );
        @pGrenade.pev.owner = pevOwner;

        // make monsters afaid of it while in the air
        pGrenade.SetThink( ThinkFunction( pGrenade.DangerSoundThink ) );
        pGrenade.pev.nextthink = g_Engine.time;

        // Tumble in air
        pGrenade.pev.avelocity.x = Math.RandomFloat( -100, -500 );

        // Explode on contact
        pGrenade.SetTouch( TouchFunction( pGrenade.ExplodeTouch ) );

        pGrenade.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_9mmAR_grenade' );

        return @pGrenade;
    }

    Class@ ShootTimed( edict_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity, float time )
    {
        Class@ pGrenade = GetClass( g_EntityFuncs.Create( classname, vecStart, g_vecZero, true ) );

        if( pGrenade is null )
            return null;

        pGrenade.Spawn();
        g_EntityFuncs.SetOrigin( GetEntity(pGrenade), vecStart );
        pGrenade.pev.velocity = vecVelocity;
        pGrenade.pev.angles = Math.VecToAngles( pGrenade.pev.velocity );
        @pGrenade.pev.owner = pevOwner;

        pGrenade.SetTouch( TouchFunction( pGrenade.BounceTouch ) ); // Bounce if touched

        // Take one second off of the desired detonation time and set the think to PreDetonate. PreDetonate
        // will insert a DANGER sound into the world sound list and delay detonation for one second so that
        // the grenade explodes after the exact amount of time specified in the call to ShootTimed().

        pGrenade.pev.dmgtime = g_Engine.time + time;
        pGrenade.SetThink( ThinkFunction( pGrenade.TumbleThink ) );
        pGrenade.pev.nextthink = g_Engine.time + 0.1;

        if( time < 0.1 )
        {
            pGrenade.pev.nextthink = g_Engine.time;
            pGrenade.pev.velocity = Vector( 0, 0, 0 );
        }

        pGrenade.pev.sequence = Math.RandomLong( 3, 6 );
        pGrenade.pev.framerate = 1.0;

        // Tumble through the air
        // pGrenade.pev.avelocity.x = -400;

        pGrenade.pev.gravity = 0.5;
        pGrenade.pev.friction = 0.8;

        g_EntityFuncs.SetModel( GetEntity(pGrenade), "models/w_grenade.mdl" );
        pGrenade.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_hand_grenade' );

        return @pGrenade;
    }
}



/*
Class@ ShootSatchelCharge( entvars_t@ pevOwner, const Vector& in vecStart, const Vector& in vecVelocity )
{
	CGrenade *pGrenade = GetClassPtr( (CGrenade *)NULL );
	pGrenade->pev->movetype = MOVETYPE_BOUNCE;
	pGrenade->pev->classname = MAKE_STRING( "grenade" );

	pGrenade->pev->solid = SOLID_BBOX;

	SET_MODEL(ENT(pGrenade->pev), "models/grenade.mdl");	// Change this to satchel charge model

	UTIL_SetSize(pGrenade->pev, Vector( 0, 0, 0), Vector(0, 0, 0));

	pGrenade->pev->dmg = 200;
	UTIL_SetOrigin( pGrenade->pev, vecStart );
	pGrenade->pev->velocity = vecVelocity;
	pGrenade->pev->angles = g_vecZero;
	pGrenade->pev->owner = ENT(pevOwner);

	// Detonate in "time" seconds
	pGrenade->SetThink( &CGrenade::SUB_DoNothing );
	pGrenade->SetUse( &CGrenade::DetonateUse );
	pGrenade->SetTouch( &CGrenade::SlideTouch );
	pGrenade->pev->spawnflags = SF_DETONATE;

	pGrenade->pev->friction = 0.9;

	return pGrenade;
}*/
