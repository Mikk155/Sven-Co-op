#include "fft"
#include "json"
#include "GameFuncs"
#include "EntityFuncs"
#include "CustomKeyValues"

json pJson;
CScheduledFunction@ pThink;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    GameFuncs::UpdateTimer( pThink, 'Think', 0.0, g_Scheduler.REPEAT_INFINITE_TIMES );

    pJson.load( 'plugins/mikk/svenfixes.json' );

    PluginUpdate();
}

void MapInit()
{
    // Actually i don't need a per-frame think but consider using checks for g_Engine.time
    GameFuncs::UpdateTimer( pThink, 'Think', 0.4f, g_Scheduler.REPEAT_INFINITE_TIMES );

    if( pJson.reload('plugins/mikk/svenfixes.json') != 1 )
    {
        PluginUpdate();
    }

    if( IsActive( "Satchel Stun" ) )
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'CSatchelCharge', 'svenfixes_satchel' );
        g_Game.PrecacheOther( 'svenfixes_satchel' );
    }
}

void MapStart()
{
}

void PluginUpdate()
{
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
    g_Hooks.RegisterHook( Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack );
    g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );

    #if ASLP
        g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @PlayerPostRevive );
        aslp = true;
    #endif
}

bool aslp;

enum ATTACK
{
    PRIMARY = 1,
    SECONDARY = 2,
    TERTIARY = 3,
};

HookReturnCode MapChange()
{
    return HOOK_CONTINUE;
}

float halfsecond;

// "active" is true and it's not a black-listed map
const bool IsActive( string szLabel )
{
    json js = json( pJson[ szLabel ] );
    array<string> sz = array<string>( js[ "map-blacklist" ] );
    return ( js[ "active", true ] && sz.find( string( g_Engine.mapname ) ) == -1 );
}

// Push the player forward to prevent getting that close
void PushForward( CBaseEntity@ pEntity )
{
    if( pEntity.pev.flags & FL_ONGROUND != 0 )
        pEntity.SetOrigin( pEntity.pev.origin + Vector( 0,0,10 ) );
    pEntity.pev.velocity = -g_Engine.v_forward * 300;
}

void Think()
{
    if( g_Engine.time > halfsecond )
    {
        CBaseEntity@ pEntity = null;

        if( IsActive( "gonome crouch spam" ) )
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_gonome" ) ) !is null )
            {
                CBaseMonster@ pGonome = cast<CBaseMonster@>( pEntity );

                if( pGonome !is null && pGonome.m_hEnemy.IsValid() )
                {
                    CBaseEntity@ pEnemy = pGonome.m_hEnemy.GetEntity();

                    if( pEnemy.IsPlayer() && ( pEnemy.pev.origin - pGonome.pev.origin ).Length() < 64
                    && ( pEnemy.pev.flags & FL_ONGROUND == 0 || pEnemy.pev.origin.z > pGonome.pev.origin.z ) )
                    {
                        PushForward( pEnemy );
                        // i were thinking like for 3 hours and didn't get a better result, so let's damage a bit x[
                        pEnemy.TakeDamage( pGonome.pev, pGonome.pev, g_EngineFuncs.CVarGetFloat( "sk_gonome_dmg_one_bite" ), DMG_LAUNCH | DMG_SLASH );
                    }
                }
            } @pEntity = null;
        }

        if( g_Game.GetGameVersion() == 525 )
        {
            if( IsActive( "hwgrunt crouch" ) )
            {
                while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_hwgrunt" ) ) !is null )
                {
                    CBaseMonster@ pHeavy = cast<CBaseMonster@>( pEntity );

                    if( pHeavy !is null && pHeavy.m_hEnemy.IsValid() )
                    {
                        CBaseEntity@ pEnemy = pHeavy.m_hEnemy.GetEntity();

                        if( pEnemy.IsPlayer() && pEnemy.IsAlive() && ( pEnemy.pev.origin - pHeavy.pev.origin ).Length() < 84 && pEnemy.pev.button & IN_DUCK != 0 )
                        {
                            PushForward( pEnemy );
                        }
                    }
                } @pEntity = null;
            }
        }
        else if( g_Game.GetGameVersion() == 525 )
        {
            if( IsActive( "grenade revivable" ) )
            {
                while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'grenade' ) ) !is null )
                {
                    g_EntityFuncs.DispatchKeyValue( pEntity.edict(), 'is_not_revivable', '1' );
                } @pEntity = null;
            }
        }

        halfsecond = g_Engine.time + 0.5f;
    }

}

HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::PRIMARY ); return HOOK_CONTINUE; }
HookReturnCode WeaponTertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::TERTIARY ); return HOOK_CONTINUE; }
HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::SECONDARY ); return HOOK_CONTINUE; }
HookReturnCode OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
{
    if( pPlayer is null || pWeapon is null )
        return HOOK_CONTINUE;

    switch( AttackMode )
    {
        case PRIMARY:
        {
            if( pWeapon.GetClassname() == 'weapon_tripmine' )
            {
                if( IsActive( "tripmine spam" ) )
                {
                    CBaseEntity@ pMine;
                    CBaseEntity@ LastMine;
                    int maxmines = int( pJson[ "tripmine spam", {} ][ "max mines" ] );

                    for( int i = 0; ( @pMine = g_EntityFuncs.FindEntityByClassname( pMine, "monster_tripmine" ) ) !is null; i++ )
                    {
                        if( i > maxmines )
                        {
                            g_EntityFuncs.FindEntityByClassname( null, "monster_tripmine" ).Killed( pPlayer.pev, GIB_NEVER );
                            break;
                        }
                    }
                }
            }
            else if( pWeapon.GetClassname() == 'weapon_satchel' )
            {
                if( g_CustomEntityFuncs.IsCustomEntity( 'svenfixes_satchel' ) )
                {
                    CBaseEntity@ pAnysatchel = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 100, 'monster_satchel', 'classname' );

                    if( pAnysatchel !is null )
                    {
                        CreateSatchel( pPlayer );
                    }
                    else
                    {
                        CBaseEntity@ pSatchels = null;

                        while( ( @pSatchels = g_EntityFuncs.FindEntityByClassname( pSatchels, 'svenfixes_satchel' ) ) !is null )
                        {
                            CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchels.pev.owner );

                            if( pOwner !is null && pOwner is pPlayer )
                            {
                                pSatchels.Use( null, null, USE_TOGGLE, 0 );
                            }
                        }
                    }
                }
            }
            break;
        }
        case SECONDARY:
        {
            if( pWeapon.GetClassname() == 'weapon_satchel' )
            {
                if( g_CustomEntityFuncs.IsCustomEntity( 'svenfixes_satchel' ) )
                {
                    CreateSatchel( pPlayer );
                }
            }
        }
        break;
        case TERTIARY:
        break;
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer ) { return OnObserverMode( pPlayer, OBS_NONE ); }
HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer ) { return OnObserverMode( pPlayer, OBS_ROAMING ); }
HookReturnCode OnObserverMode( CBasePlayer@ pPlayer, ObserverMode iMode )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    if( iMode == OBS_NONE )
    {
        if( IsActive( "observer presence" ) )
            pPlayer.pev.flags &= ~FL_NOTARGET;
    }
    else
    {
        if( IsActive( "observer presence" ) )
            pPlayer.pev.flags |= FL_NOTARGET;

        if( IsActive( "observer noises" ) )
            pPlayer.pev.movetype = MOVETYPE_NOCLIP;

        if( pPlayer.GetObserver().HasCorpse() && IsActive( "corpse sink" ) )
        {
            CBaseEntity@ pCorpse = null;

            while( ( @pCorpse = g_EntityFuncs.FindEntityByClassname( pCorpse, 'deadplayer' ) ) !is null )
            {
                if( pCorpse.pev.renderamt == pPlayer.entindex() )
                {
                    deadplayer_sinkCheckCorpse( EHandle( pCorpse ), pCorpse.pev.origin );
                    break;
                }
            }
        }
    }

    return HOOK_CONTINUE;
}

// This is a hack to prevent using metamod :#
HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    if( string( ckvd[ pPlayer, "svenfixes_gravity" ] ) != String::EMPTY_STRING && IsActive( "revive lose gravity" ) )
        pPlayer.pev.gravity = float( ckvd[ pPlayer, "svenfixes_gravity" ] );

    if( bool( ckvd[ pPlayer, "svenfixes_longjump" ] ) && IsActive( "revive lose longjump" ) )
    {
        pPlayer.m_fLongJump = true;
        g_EngineFuncs.GetPhysicsKeyBuffer( pPlayer.edict() ).SetValue( "slj", "1" );
    }

    return HOOK_CONTINUE;
}

bool TrackRevive(){ return ( IsActive( "revive lose gravity" ) ); }

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    if( !aslp && TrackRevive() )
    {
        // Player just revived. update ckvd
        if( bool( ckvd[ pPlayer, "svenfixes_revived" ] ) )
        {
            if( pPlayer.IsAlive() )
            {
                ckvd[ pPlayer, "svenfixes_revived", false ];
                PlayerPostRevive( pPlayer );
            }
        }
        else if( pPlayer.GetObserver().HasCorpse() || ( !pPlayer.IsAlive() && !pPlayer.GetObserver().IsObserver() ) )
        {
            ckvd[ pPlayer, "svenfixes_revived", true ];
        }
    }

    if( IsActive( "strip longjump" ) && pPlayer.m_fLongJump && g_EntityFuncs.FindEntityByClassname( null, 'player_weaponstrip' ) !is null && !pPlayer.HasSuit() )
    {
        pPlayer.m_fLongJump = false;
        g_EngineFuncs.GetPhysicsKeyBuffer( pPlayer.edict() ).SetValue( "slj", "0" );
    }

    return HOOK_CONTINUE;
}

array<string> GravityModifiers =
{
    "trigger_effect",
    "trigger_gravity",
    "trigger_copyvalue",
    "trigger_changevalue"
};

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    if( pPlayer.m_fLongJump && IsActive( "revive lose longjump" ) )
        ckvd[ pPlayer, "svenfixes_longjump", true ];

    if( IsActive( "revive lose gravity" ) )
    {
        for( uint ui = 0; ui < GravityModifiers.length(); ui++ )
        {
            if( g_EntityFuncs.FindEntityByClassname( null, GravityModifiers[ui] ) !is null || pPlayer.pev.gravity != 1.0 )
            {
                ckvd[ pPlayer, "svenfixes_gravity", pPlayer.pev.gravity ];
                break;
            }
        }
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
    if( pDamageInfo.pVictim is null )
        return HOOK_CONTINUE;

    CBaseEntity@ pVictim = pDamageInfo.pVictim;
    CBaseEntity@ pInflictor = pDamageInfo.pInflictor;
    CBaseEntity@ pAttacker = pDamageInfo.pAttacker;

    if( ( pDamageInfo.bitsDamageType & DMG_CRUSH ) != 0 && pDamageInfo.flDamage > 0 && IsActive( "elevator friendly kill" ) )
    {
        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

            if( pPlayer !is null && pPlayer.IsConnected()
            && pPlayer.IsAlive() && pPlayer !is pVictim
            && pPlayer.pev.origin.z > pVictim.pev.origin.z
            && ( pPlayer.pev.origin - pVictim.pev.origin ).Length() < 74 )
            {
                pPlayer.TakeDamage( pInflictor.pev, pAttacker.pev, pDamageInfo.flDamage, pDamageInfo.bitsDamageType );
                Vector VecPos = pPlayer.pev.origin;
                pPlayer.SetOrigin( pVictim.pev.origin );
                pVictim.SetOrigin( VecPos );
                pDamageInfo.flDamage = 0;
                return HOOK_HANDLED;
            }
        }
    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    ckvd[ pPlayer, "svenfixes_revived", false ]; // We've been respawned, do not call Revive!

    if( bool( ckvd[ pPlayer, "svenfixes_longjump" ] ) )
        ckvd[ pPlayer, "svenfixes_longjump", false ];

    if( string( ckvd[ pPlayer, "svenfixes_gravity" ] ) != String::EMPTY_STRING && IsActive( "revive lose gravity" ) )
        ckvd[ pPlayer, "svenfixes_gravity", pPlayer.pev.gravity ];

    return HOOK_CONTINUE;
}

void deadplayer_sinkCheckCorpse( EHandle hCorpse, Vector VecPos )
{
    CBaseEntity@ pCorpse = hCorpse.GetEntity();

    if( pCorpse !is null )
    {
        TraceResult tr;
        g_Utility.TraceLine( pCorpse.pev.origin, pCorpse.pev.origin, ignore_monsters, pCorpse.edict(), tr );

        // Call repeated times until the position changes or it gets on ground
        if( tr.fInOpen == 1 && ( pCorpse.pev.flags & FL_ONGROUND ) == 0 )
        {
            g_Scheduler.SetTimeout( 'deadplayer_sinkCheckCorpse', 0.1f, EHandle( pCorpse ), VecPos );
        }
        else if( pCorpse.pev.origin.z > VecPos.z - 100 )
        {
            VecPos.z += 20;
            g_EntityFuncs.SetOrigin( pCorpse, VecPos );
            g_EngineFuncs.DropToFloor( pCorpse.edict() );
            pCorpse.pev.movetype = MOVETYPE_NONE;
            pCorpse.pev.solid = SOLID_NOT;
        }
    }
}

class CSatchelCharge : ScriptBasePlayerAmmoEntity
{
    void Spawn()
    {
        Precache();

        // motor
        self.pev.movetype = MOVETYPE_BOUNCE;
        self.pev.solid = SOLID_SLIDEBOX;

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
        g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );
    }

    void SatchelSlide( CBaseEntity@ pOther )
    {
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

                g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_WEAPON, "items/gunpickup2.wav", 0.5f, ATTN_NONE );

                g_EntityFuncs.Remove( self );
            }
        }
        else
        {
            CSoundEnt@ pSound = GetSoundEntInstance();
            pSound.InsertSound( bits_SOUND_DANGER, pev.origin, 400, 0.3, self );

            TraceResult tr;
            Vector vecSpot; // trace starts here!

            vecSpot = pev.origin + Vector( 0, 0, 8 );
            g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, self.edict(), tr );

            g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), pev.owner, int( pev.dmg ), false );
            g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );

            g_EntityFuncs.Remove( self );
        }
    }

    void SatchelThink()
    {
        switch( self.pev.waterlevel )
        {
            case WATERLEVEL_DRY:
            case WATERLEVEL_FEET:
            case WATERLEVEL_WAIST:
            {
                self.pev.movetype = MOVETYPE_BOUNCE;
                break;
            }
            case WATERLEVEL_HEAD:
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

void CreateSatchel( CBasePlayer@ pPlayer )
{
    CBaseEntity@ pSatchel = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 100, 'monster_satchel', 'classname' );

    if( pSatchel !is null )
    {
        CBaseEntity@ pOwner = g_EntityFuncs.Instance( pSatchel.pev.owner );

        if( pOwner !is null )
        {
            CBaseEntity@ lpSatchel = g_EntityFuncs.Create( 'svenfixes_satchel', pSatchel.pev.origin, pSatchel.pev.angles, false, pOwner.edict() );

            if( lpSatchel !is null )
            {
                lpSatchel.pev.velocity = pSatchel.pev.velocity;
                g_EntityFuncs.Remove( pSatchel );
            }
        }
    }
}