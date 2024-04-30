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

#include "CGrenade"


enum SporeAnim
{
    SPORE_IDLE = 0
};

enum SporeType
{
    ROCKET = 1,
    GRENADE = 2
};

/*
    @prefix #include CSpore
    @body #include "${1:../../}mikk/CSpore"
    @description CSpore como una class para heredar
*/
namespace CSpore
{
    const string classname = 'as_spore';

    bool blAutoRegister = Register();

    /*
        @prefix CSpore CSpore::Register
        @body CSpore::Register()
        @description Registra la class CSpore, en map_scripts esto es automatico sin embargo en plugins debes registrarla.
    */
    bool Register()
    {
        if( g_Engine.time > 1 ) {
            return false;
        }

        g_CustomEntityFuncs.RegisterCustomEntity( 'CSpore::Class', classname );
        g_Game.PrecacheOther( classname );
        return g_CustomEntityFuncs.IsCustomEntity( classname );
    }

    /*
        @prefix CSpore CSpore::GetClass GetClass
        @body CSpore::GetClass( CBaseEntity@ pEntity )
        @description Retorna la instancia de CSpore
    */
    Class@ GetClass( CBaseEntity@ pEntity ) {
        return cast<Class>( CastToScriptClass( pEntity ) );
    }

    /*
        @prefix CSpore CSpore::GetEntity GetEntity
        @body CSpore::GetEntity( Class@ pEntity )
        @description Retorna la entidad de CSpore
    */
    CBaseEntity@ GetEntity( Class@ pEntity ) {
        return cast<CBaseEntity>( pEntity );
    }

    class Class : CGrenade::Class
    {
        SporeType m_SporeType;

        float m_flIgniteTime;
        float m_flSoundDelay;

        bool m_bPuked;
        bool m_bIsAI;

        int m_iBlow;
        int m_iBlowSmall;
        int m_iSpitSprite;
        int m_iTrail;

        EHandle m_hSprite;

        void Precache()
        {
            g_Game.PrecacheModel( "models/spore.mdl" );
            g_Game.PrecacheModel( "sprites/glow01.spr" );

            m_iBlow = g_Game.PrecacheModel( "sprites/spore_exp_01.spr" );
            m_iBlowSmall = g_Game.PrecacheModel( "sprites/spore_exp_c_01.spr" );
            m_iSpitSprite = m_iTrail = g_Game.PrecacheModel( "sprites/tinyspit.spr" );

            g_SoundSystem.PrecacheSound( "weapons/splauncher_impact.wav" );
            g_Game.PrecacheGeneric( 'sound/' + "weapons/splauncher_impact.wav" );
            g_SoundSystem.PrecacheSound( "weapons/splauncher_bounce.wav" );
            g_Game.PrecacheGeneric( 'sound/' + "weapons/splauncher_bounce.wav" );

            BaseClass.Precache();
        }

        void Spawn()
        {
            Precache();

            pev.movetype = ( m_SporeType == SporeType::GRENADE ? MOVETYPE_BOUNCE : MOVETYPE_FLY );
            pev.solid = SOLID_BBOX;
            g_EntityFuncs.SetModel( self, 'models/spore.mdl' );
            g_EntityFuncs.SetSize( pev, g_vecZero, g_vecZero );
            self.SetOrigin( pev.origin );

            g_Scheduler.SetTimeout( @this, 'FlyThink', 0.01 );
            //SetThink( ThinkFunction( self.FlyThink ) );

            if( m_SporeType == SporeType::GRENADE )
            {
                //SetTouch( TouchFunction( this.MyBounceTouch ) );

                if( !m_bPuked )
                {
                    pev.angles.x -= Math.RandomLong( -5, 5 ) + 30;
                }
            }
            else
            {
                //SetTouch( TouchFunction( this.RocketTouch ) );
            }

            g_EngineFuncs.MakeVectors( pev.angles );

            if( !m_bIsAI )
            {
                if( m_SporeType != SporeType::GRENADE )
                {
                    pev.velocity = g_Engine.v_forward * 1200;
                }

                pev.gravity = 1;
            }
            else
            {
                pev.gravity = 0.5;
                pev.friction = 0.7;
            }

            pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_spore' );

            m_flIgniteTime = g_Engine.time;

            pev.nextthink = g_Engine.time + 0.01;

            CSprite@ sprite = g_EntityFuncs.CreateSprite( 'sprites/glow01.spr', pev.origin, false );

            m_hSprite = sprite;

            sprite.SetTransparency( kRenderTransAdd, 180, 180, 40, 100, kRenderFxDistort );
            sprite.SetScale( 0.8 );
            sprite.SetAttachment( self.edict(), 0 );

            m_fRegisteredSound = false;

            m_flSoundDelay = g_Engine.time;
        }

        void BounceSound()
        {
            // Nothing
        }

        void IgniteThink()
        {
            SetThink( null );
            SetTouch( null );

            if( m_hSprite.GetEntity() !is null )
            {
                g_EntityFuncs.Remove( m_hSprite );
                m_hSprite = null;
            }

            g_SoundSystem.EmitSound( self.edict(), CHAN_WEAPON, "weapons/splauncher_impact.wav", VOL_NORM, ATTN_NORM);

            const Vector vecDir = pev.velocity.Normalize();

            TraceResult tr;

            g_Utility.TraceLine( pev.origin, pev.origin + vecDir * ( m_SporeType == SporeType::GRENADE ? 64 : 32 ), dont_ignore_monsters, self.edict(), tr );

            g_Utility.DecalTrace( tr, DECAL_SPORESPLAT1 + Math.RandomLong( 0, 2 ) );

            NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                m.WriteByte( TE_SPRITE_SPRAY );
                m.WriteCoord( pev.origin.x );
                m.WriteCoord( pev.origin.y );
                m.WriteCoord( pev.origin.z );
                m.WriteCoord( tr.vecPlaneNormal.x );
                m.WriteCoord( tr.vecPlaneNormal.y );
                m.WriteCoord( tr.vecPlaneNormal.z );
                m.WriteShort( m_iSpitSprite );
                m.WriteByte( 100 );
                m.WriteByte( 40 );
                m.WriteByte( 180 );
            m.End();

            UserMessages::DynamicLight( pev.origin, RGBA( 15, 220, 40, 10 ), 5, 10 );

            NetworkMessage m2( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                m2.WriteByte( TE_SPRITE );
                m2.WriteVector( pev.origin );
                m2.WriteShort( ( Math.RandomLong( 0, 1 ) == 1 ? m_iBlow : m_iBlowSmall ) );
                m2.WriteByte( 20 );
                m2.WriteByte( 128 );
            m2.End();

            NetworkMessage m3( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                m3.WriteByte( TE_SPRITE_SPRAY );
                m3.WriteCoord( pev.origin.x );
                m3.WriteCoord( pev.origin.y );
                m3.WriteCoord( pev.origin.z );
                m3.WriteCoord( Math.RandomFloat( -1, 1 ) );
                m3.WriteCoord( 1 );
                m3.WriteCoord( Math.RandomFloat( -1, 1 ) );
                m3.WriteShort( m_iTrail );
                m3.WriteByte( 2 );
                m3.WriteByte( 20 );
                m3.WriteByte( 80 );
            m3.End();

            g_WeaponFuncs.RadiusDamage( pev.origin, pev, pev.owner.vars, pev.dmg, 200, CLASS_NONE, DMG_ALWAYSGIB | DMG_BLAST );

            // Not originally on the code but i wanted to add it anyways
            CSoundEnt@ pSound = GetSoundEntInstance();
            pSound.InsertSound( bits_SOUND_COMBAT, pev.origin, int( pev.dmg / 0.4 ), 0.3, self );

            self.SUB_Remove();
        }

        void FlyThink()
        {
            const float flDelay = m_bIsAI ? 4.0 : 2.0;

            if( m_SporeType != SporeType::GRENADE || ( g_Engine.time <= m_flIgniteTime + flDelay ) )
            {
                NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                    m.WriteByte( TE_SPRITE_SPRAY );
                    m.WriteVector( pev.origin );
                    m.WriteVector( pev.velocity.Normalize() );
                    m.WriteShort( m_iTrail );
                    m.WriteByte( 2 );
                    m.WriteByte( 20 );
                    m.WriteByte( 80 );
                m.End();
            }
            else
            {
                //SetThink( ThinkFunction( this.IgniteThink ) );
                g_Scheduler.SetTimeout( @this, 'IgniteThink', 0.03 );
                return;
            }

            pev.nextthink = g_Engine.time + 0.03;
        }

        void GibThink()
        {
            //Nothing
        }

        void RocketTouch( CBaseEntity@ pOther )
        {
            if( pOther.pev.takedamage != DAMAGE_NO )
            {
                pOther.TakeDamage( pev, pev.owner.vars, pev.dmg, DMG_GENERIC );
            }

            IgniteThink();
        }

        void Touch( CBaseEntity@ pOther )
        {
            if( m_SporeType == SporeType::GRENADE )
            {
                MyBounceTouch(pOther);
            }
            else
            {
                RocketTouch(pOther);
            }
        }

        void MyBounceTouch( CBaseEntity@ pOther )
        {
            if( pOther.pev.takedamage == DAMAGE_NO )
            {
                if( pOther.edict() !is pev.owner )
                {
                    if( g_Engine.time > m_flSoundDelay )
                    {
                        CSoundEnt@ pSound = GetSoundEntInstance();
                        pSound.InsertSound( bits_SOUND_DANGER, pev.origin, int( pev.dmg / 0.4 ), 0.3, self );

                        m_flSoundDelay = g_Engine.time + 1.0;
                    }

                    if( ( pev.flags & FL_ONGROUND ) != 0 )
                    {
                        pev.velocity = pev.velocity * 0.5;
                    }
                    else
                    {
                        g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/splauncher_bounce.wav", 0.25, ATTN_NORM, 0, PITCH_NORM );
                    }
                }
            }
            else
            {
                pOther.TakeDamage( pev, pev.owner.vars, pev.dmg, DMG_GENERIC );

                IgniteThink();
            }
        }
    }

    Class@ CreateSpore( const Vector& in vecOrigin, const Vector& in vecAngles, CBaseEntity@ pOwner, SporeType sporeType, bool bIsAI, bool bPuked )
    {
        Class@ pSpore = GetClass( g_EntityFuncs.Create( classname, vecOrigin, g_vecZero, true ) );

        if( pSpore is null )
            return null;

        pSpore.m_SporeType = sporeType;

        if( bIsAI )
        {
            pSpore.pev.velocity = vecAngles;
            pSpore.pev.angles = Math.VecToAngles( vecAngles );
        }
        else
        {
            pSpore.pev.angles = vecAngles;
        }

        pSpore.m_bIsAI = bIsAI;
        pSpore.m_bPuked = bPuked;
        @pSpore.pev.owner = pOwner.edict();
        pSpore.pev.origin = vecOrigin;
        pSpore.Spawn();

        return @pSpore;
    }
}
