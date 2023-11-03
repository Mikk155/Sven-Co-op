#include '../../maps/mikk/as_utils'

/*
*   svenfixes.
*   This plugin fixes the next bugs:
*
*   Gonome:
*       By spaming duck key while in range of a gonome's melee attack, gonome won't attack you -Fixed
*
*   Heavy grunt:
*       By holding duck key while in range of a heavy grunt's melee attack, heavy's minigun's bullets won't hit you -Fixed
*
*   Players:
*       By reviving, players will lose their gravity if it was changed -Fixed
*       By being spectators, players will make swim noises -Fixed
*       By being spectators, players will trigger monsters with SF_MONSTER_WAIT_TILL_SEEN flag set -Fixed
*
*   Tripmines:
*       By placing lot of tripmines and then explode them causes the server to crash -Fixed
*
*   Grenades:
*       By attempting to revive a grenade, players standing above them will gain velocity -Fixed
*
*   Satchel:
*       By throwing and pickup a satchel charge, you can "stun" monsters -Fixed
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver );
    g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @PlayerPostRevive );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );
    g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver );
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPostCheckEnemy, @MonsterPostCheckEnemy );
}

void MapInit()
{
    g_CustomEntityFuncs.RegisterCustomEntity( 'CSatchelCharge', 'lp_satchel' );
    g_Game.PrecacheOther( 'lp_satchel' );
}

HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
{
    if( pPlayer is null || pWeapon is null )
        return HOOK_CONTINUE;

    if( pWeapon.GetClassname() == 'weapon_tripmine' )
    {
        CBaseEntity@ pMine = null;

        for( int i = 0; ( @pMine = g_EntityFuncs.FindEntityInSphere( pMine, pPlayer.pev.origin, 128, 'monster_tripmine', 'classname' ) ) !is null; i++ )
        {
            if( i > 10 )
            {
                pMine.Killed( pPlayer.pev, GIB_NEVER );
            }
        }
    }
    else if( pWeapon.GetClassname() == 'weapon_satchel' )
    {
        FixSatchel( pPlayer, true );
    }
    return HOOK_CONTINUE;
}

HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
{
    if( pPlayer is null || pWeapon is null )
        return HOOK_CONTINUE;

    if( pWeapon.GetClassname() == 'weapon_medkit' )
    {
        CBaseEntity@ pGrenade = null;

        while( ( @pGrenade = g_EntityFuncs.FindEntityInSphere( pGrenade, pPlayer.pev.origin, 200, 'grenade', 'classname' ) ) !is null && pGrenade.IsRevivable() )
        {
            g_EntityFuncs.DispatchKeyValue( pGrenade.edict(), 'is_not_revivable', '1' );
        }
    }
    else if( pWeapon.GetClassname() == 'weapon_satchel' )
    {
        FixSatchel( pPlayer );
    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	if( pPlayer !is null )
    {
        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_fix_lost_gravity', pPlayer.pev.gravity );
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null )
    {
        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_fix_lost_gravity', pPlayer.pev.gravity );
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null )
    {
        pPlayer.pev.gravity = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_fix_lost_gravity' ).GetFloat();
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer )
{
	if( pPlayer is null )
		return HOOK_CONTINUE;

    pPlayer.pev.movetype = MOVETYPE_NOCLIP;
    pPlayer.pev.flags |= FL_NOTARGET;

    if( pPlayer.GetObserver().HasCorpse() )
    {
        CBaseEntity@ pCorpse = null;

        // Not in sphere, observers can spectate a player as soon as they're dead. instead check it's movetype
        while( ( @pCorpse = g_EntityFuncs.FindEntityByClassname( pCorpse, 'deadplayer' ) ) !is null && pCorpse.pev.movetype != MOVETYPE_NONE )
        {
            pCorpse.pev.movetype = MOVETYPE_NONE;
            pCorpse.pev.solid = SOLID_NOT;
            pCorpse.pev.origin.z += 32;
        }
    }

	return HOOK_CONTINUE;
}

HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer )
{
	if( pPlayer is null )
		return HOOK_CONTINUE;

    pPlayer.pev.flags &= ~FL_NOTARGET;

	return HOOK_CONTINUE;
}

HookReturnCode MonsterPostCheckEnemy( CBaseMonster@ pMonster, CBaseEntity@ pEnemy )
{
    if( pMonster is null )
        return HOOK_CONTINUE;

    if( pMonster.GetClassname() == 'monster_gonome' && pEnemy !is null && pEnemy.IsPlayer() && ( pEnemy.pev.origin - pMonster.pev.origin ).Length() < 64 && pEnemy.pev.flags & FL_ONGROUND == 0 )
    {
        pEnemy.pev.velocity.z = 100;
    }
    else if( pMonster.GetClassname() == 'monster_hwgrunt' && pEnemy !is null && pEnemy.IsPlayer() && ( pEnemy.pev.origin - pMonster.pev.origin ).Length() < 84 && pEnemy.pev.flags & FL_DUCKING != 0 )
    {
        pEnemy.pev.velocity = g_Engine.v_forward * ( ( 90 - ( pMonster.pev.v_angle + pMonster.pev.punchangle ).x ) * 4 ) + pEnemy.pev.velocity;
    }
    return HOOK_CONTINUE;
}

void FixSatchel( CBasePlayer@ pPlayer, bool bIsPrimary = false )
{
    if( !g_CustomEntityFuncs.IsCustomEntity( 'lp_satchel' ) )
        return;

    CBaseEntity@ pSatchel = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 100, 'monster_satchel', 'classname' );

    if( bIsPrimary && pSatchel is null )
    {
        CBaseEntity@ pSatchels = null;

        while( ( @pSatchels = g_EntityFuncs.FindEntityByClassname( pSatchels, 'lp_satchel' ) ) !is null )
        {
            CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchels.pev.owner );

            if( pOwner !is null && pOwner is pPlayer )
            {
                pSatchels.Use( null, null, USE_TOGGLE, 0.0f );
            }
        }
        return;
    }

    if( pSatchel is null )
        return;

    CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchel.pev.owner );

    if( pOwner is null )
        return;

    CBaseEntity@ lpSatchel = g_EntityFuncs.Create( 'lp_satchel', pSatchel.pev.origin, pSatchel.pev.angles, false, pOwner.edict() );

    if( lpSatchel is null )
        return;

    lpSatchel.pev.velocity = pSatchel.pev.velocity;

    g_EntityFuncs.Remove( pSatchel );
}

class CSatchelCharge : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{
		Precache();

		// motor
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;

		g_EntityFuncs.SetModel( self, "models/w_satchel.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) ); // Uses point-sized, and can be stepped over

		SetTouch( TouchFunction( SatchelSlide ) );
		SetThink( ThinkFunction( SatchelThink ) );
        SetUse( UseFunction( Use ) );
		self.pev.nextthink = g_Engine.time + 0.1;

		self.pev.gravity = 0.5;
		self.pev.friction = 0.8;

		self.pev.dmg = g_EngineFuncs.CVarGetFloat( 'sk_plr_satchel' );
		self.pev.sequence = 1;
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/w_satchel.mdl" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce3.wav" );
	}

	void SatchelSlide( CBaseEntity@ pOther )
	{
		// don't hit the guy that launched this grenade
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		if ( pOther == pOwner )
			return;

		pev.gravity = 1; // normal gravity now

		// HACKHACK - on ground isn't always set, so look for ground underneath
		TraceResult tr;
		g_Utility.TraceLine( pev.origin, pev.origin - Vector( 0, 0, 10 ), ignore_monsters, self.edict(), tr );

		if ( tr.flFraction < 1.0 )
		{
			// add a bit of static friction
			pev.velocity = pev.velocity * 0.95;
			pev.avelocity = pev.avelocity * 0.9;
		}

		// play sliding sound, volume based on velocity
		int bCheck = pev.flags;
		if ( ( bCheck &= FL_ONGROUND ) != FL_ONGROUND && pev.velocity.Length2D() > 10 )
		{
            CSoundEnt@ pSound = GetSoundEntInstance();
            pSound.InsertSound( bits_SOUND_PLAYER, pev.origin, 400, 0.3, self );
            g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/g_bounce" + string( Math.RandomLong( 1, 3 ) ) + ".wav", 1, ATTN_NORM );
		}
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
        if( pActivator !is null && pActivator is g_EntityFuncs.Instance( pev.owner ) )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

            CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon>( pPlayer.HasNamedPlayerItem( 'weapon_satchel' ) );

            if( pPlayer !is null && pWeapon !is null )
            {
                int Satchels = 0;

                CBaseEntity@ pSatchels = null;

                while( ( @pSatchels = g_EntityFuncs.FindEntityByClassname( pSatchels, self.GetClassname() ) ) !is null )
                {
                    if( pSatchels !is self && g_EntityFuncs.Instance( pSatchels.pev.owner ) is pPlayer )
                    {
                        Satchels++;
                    }
                }

                switch( Satchels )
                {
                    case 0:
                    {
                        pPlayer.RemovePlayerItem( pWeapon );
                        pPlayer.GiveNamedItem( 'weapon_satchel', 0, int( 1 + pPlayer.m_rgAmmo( pWeapon.PrimaryAmmoIndex() ) ) );
                        pPlayer.SelectItem( 'weapon_satchel' );
                        break;
                    }

                    default:
                    {
                        pPlayer.GiveAmmo( 1, 'Satchel Charge', pPlayer.GetMaxAmmo( 'Satchel Charge' ), true );
                        break;
                    }
                }

		        g_EntityFuncs.Remove( self );
            }
        }
        else
        {
            CSoundEnt@ pSound = GetSoundEntInstance();
            pSound.InsertSound( bits_SOUND_DANGER, pev.origin, 400, 0.3, self );

            g_Scheduler.SetTimeout( @this, 'Detonate', 0.7f );
        }
	}

    void Detonate()
    {
        TraceResult tr;
        Vector vecSpot; // trace starts here!

        vecSpot = pev.origin + Vector( 0, 0, 8 );
        g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, self.edict(), tr );

        g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), pev.owner, int( pev.dmg ), false );
        g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );

        g_EntityFuncs.Remove( self );
    }

	void SatchelThink()
	{
        switch( self.pev.waterlevel )
        {
            case 0:
            {
			    self.pev.movetype = MOVETYPE_BOUNCE;
                break;
            }
            case 3:
            {
                self.pev.movetype = MOVETYPE_FLY;
                self.pev.velocity = self.pev.velocity * 0.8;
                self.pev.avelocity = self.pev.avelocity * 0.9;
                self.pev.velocity.z += 8;
                break;
            }
            default:
            {
                if( self.pev.velocity == g_vecZero )
                {
                    self.pev.solid = SOLID_NOT;
                    SetTouch( null );
                    SetThink( null );
                }
                else
                {
                    self.pev.velocity.z -= 8;
                }
                break;
            }
        }
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}
