#include '../../maps/mikk/as_utils'

#include 'cvars'
#include 'msg'
#include 'information'

#include 'funcs/func_barnacle_speed'
#include 'funcs/func_armor_vest'
#include 'funcs/func_zombie_uncrab'
#include 'funcs/func_alien_grunt'
#include 'funcs/func_alien_slave'
#include 'funcs/func_appearflags'
#include 'funcs/func_voltigore'
#include 'funcs/func_deathdrop'
#include 'funcs/func_player'
#include 'funcs/func_squad_alert'
#include 'funcs/func_monster_alert'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    // Hooks
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPreTraceAttack, @MonsterTraceAttack );
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPreKilled, @MonsterKilled );
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPostTakeDamage, @MonsterPostTakeDamage );
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPostCheckEnemy, @MonsterPostCheckEnemy );
    g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @PlayerPostRevive );
    g_Hooks.RegisterHook( Hooks::ASLP::Engine::Think_Post, @Think_Post );

    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );

    msg.PluginInit();
}

void MapInit()
{
    func_alien_grunt.MapInit();
    func_alien_slave.MapInit();
    g_DDD.Init();

    if( g_DDD.cooldown < ddd_cvars.votes_allowin )
        g_DDD.cooldown = ddd_cvars.votes_allowin;
}

void MapActivate()
{
    func_appearflags.MapActivate();

    UpdateDifficulty();
}

CDynamicDifficultyDeluxe g_DDD;

final class CDynamicDifficultyDeluxe
{
    int diff = 100;
    int cooldown = 0;
    bool voting = false;

    CScheduledFunction@ g_Think = null;

    void Init()
    {
        if( g_Think is null )
        {
            @g_Think = g_Scheduler.SetInterval( @this, "Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
        }
    }

    void Think()
    {
        if( ddd_cvars.votes_cooldown >= 0 )
            g_DDD.cooldown--;
    }

    int cap( int icap )
    {
        if( icap > 100 ) icap = 100; else if( icap < 0 ) icap = 0; return icap;
    }

    bool IsActive( int idiff )
    {
        return( idiff > 0 && g_DDD.diff >= idiff );
    }
}

bool ShouldReturn( array<bool> m_abBools )
{
    if( ddd_cvars.disabled == 1 or g_DDD.diff == 0 )
        return true;

    for( uint ui = 0; ui < m_abBools.length(); ui++ )
        if( m_abBools[ui] == true )
            return true;

    return false;
}


HookReturnCode MonsterTraceAttack( TraceInfo@ pInfo )
{
    CBaseMonster@ pVictim = cast<CBaseMonster@>( pInfo.pVictim );

    if( ShouldReturn
    (
        {
            pVictim is null
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    CBaseEntity@ pInflictor = pInfo.pInflictor;
    float fdmg = pInfo.flDamage;
    Vector VecDir = pInfo.vecDir;
    TraceResult ptr = pInfo.ptr;
    int bitsDamageType = pInfo.bitsDamageType;

    if( func_armor_vest.condition( pVictim.GetClassname(), ptr.iHitgroup ) )
    {
        g_Utility.Sparks( ptr.vecEndPos );
        pInfo.flDamage = ( fdmg * func_armor_vest.reduction );
    }

    if( func_zombie_uncrab.MonsterTraceAttack( pVictim, ptr.iHitgroup ) )
    {
        float fDamagedCrab;
        m_CustomKeyValue.GetValue( pVictim, '$f_ddd_zcrabhealth', fDamagedCrab );
        m_CustomKeyValue.SetValue( pVictim, '$f_ddd_zcrabhealth', fDamagedCrab - pInfo.flDamage );

    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>( pDamageInfo.pVictim );

    if( ShouldReturn
    (
        {
            pPlayer is null,
            !pPlayer.IsConnected(),
            !pPlayer.IsAlive()
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    CBaseEntity@ pInflictor = pDamageInfo.pInflictor;
    CBaseEntity@ pAttacker = pDamageInfo.pAttacker;
    float flDamage = pDamageInfo.flDamage;
    int bitsDamageType = pDamageInfo.bitsDamageType;

    if( pInflictor !is null )
    {
        if( func_alien_grunt.punch( pPlayer, pInflictor ) )
        {
            func_alien_grunt.punchpush( pPlayer, pInflictor );
        }
        else if( func_alien_grunt.stun( pInflictor ) )
        {
            func_alien_grunt.stun( pPlayer, pInflictor );
        }
    }
    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer is null || !pPlayer.IsConnected() )
        return HOOK_CONTINUE;

    g_Scheduler.SetTimeout( 'ClientConnected', 4.0f, EHandle( pPlayer ) );

    return HOOK_CONTINUE;
}

void ClientConnected( EHandle hPlayer )
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

    if( pPlayer !is null )
    {
        m_Language.PrintMessage( pPlayer, msg.using_ddd, ML_CHAT );
    }
}

HookReturnCode MonsterKilled( CBaseMonster@ pMonster, entvars_t@ pevAttacker, int& out iGib )
{
    if( ShouldReturn
    (
        {
            pMonster is null,
            pMonster.HasMemory( bits_MEMORY_KILLED )
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    if( func_zombie_uncrab.MonsterKilled( pMonster ) > 0 )
    {
        func_zombie_uncrab.CreateHeadCrab( pMonster );
    }
    else if( func_voltigore.active( func_voltigore.enable_gib, func_voltigore.diff_gib )
    && pMonster.GetClassname() == 'monster_alien_voltigore' && g_DDD.diff >= Math.RandomLong( 0, 100 ) )
    {
        iGib = GIB_ALWAYS;
    }
    else if( func_deathdrop.can_drop_grenade( pMonster ) )
    {
        func_deathdrop.drop_grenade( pMonster );
    }
    return HOOK_CONTINUE;
}

HookReturnCode MonsterPostTakeDamage( DamageInfo@ pDamageInfo, int& out result )
{
    CBaseMonster@ pVictim = cast<CBaseMonster@>( pDamageInfo.pVictim );
    CBaseEntity@ pInflictor = pDamageInfo.pInflictor;
    CBaseEntity@ pAttacker = pDamageInfo.pAttacker;
    float flDamage = pDamageInfo.flDamage;
    int bitsDamageType = pDamageInfo.bitsDamageType;

    if( ShouldReturn
    (
        {
            pVictim is null,
            pInflictor is null
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    if( func_monster_alert.condition( pVictim, pInflictor ) )
    {
        pVictim.PushEnemy( pInflictor, pInflictor.pev.origin );
    }

    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
    if( ShouldReturn
    (
        {
            pPlayer is null,
            !pPlayer.IsConnected()
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    if( func_barnacle_speed.condition( pPlayer ) )
    {
        pPlayer.pev.origin.z += func_barnacle_speed.units();
    }
    return HOOK_CONTINUE;
}

HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result )
{
    if( pszKey == 'trigger_target' || pszKey == 'TriggerTarget' )
    {
        func_appearflags.MatchedMonsters[ string( pEntity.entindex() ) ] = pszValue;
    }
    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
{
    if( ShouldReturn
    (
        {
            pPlayer is null,
            !pPlayer.IsConnected(),
            !pPlayer.IsAlive()
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    func_player.UpdatePlayerHealth( pPlayer );

    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
    if( ShouldReturn
    (
        {
            pPlayer is null,
            !pPlayer.IsConnected(),
            !pPlayer.IsAlive()
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    func_player.UpdatePlayerHealth( pPlayer );

    return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if( ShouldReturn
    (
        {
            pPlayer is null,
            !pPlayer.IsConnected()
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    if( iGib != GIB_ALWAYS && func_player.active( func_player.enable_gib, func_player.diff_gib ) )
    {
        pPlayer.Killed( pAttacker.pev, GIB_ALWAYS );
    }

    return HOOK_CONTINUE;
}

HookReturnCode MonsterPostCheckEnemy( CBaseMonster@ pMonster, CBaseEntity@& out pEnemy )
{
    if( ShouldReturn
    (
        {
            pMonster is null
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    if( func_squad_alert.condition( pMonster ) )
    {
        func_squad_alert.MoveSquad( pMonster );
    }

    return HOOK_CONTINUE;
}

HookReturnCode Think_Post( CBaseEntity@ pOther, META_RES& out meta_result )
{
    if( ShouldReturn
    (
        {
            pOther is null
        }
    ) )
    {
        return HOOK_CONTINUE;
    }

    /*if( g_DDD.IsActive( projectiles.diff ) && projectiles.IsValid( pOther ) )
    {
        g_Scheduler.SetTimeout( @projectiles, pOther.GetClassname(), 0.0f, EHandle( pOther ) );
    }*/
    return HOOK_CONTINUE;
}

void SaveVote( const string &in m_iszNewDiff )
{
    g_DDD.diff = g_DDD.cap( atoi( m_iszNewDiff ) );

    UpdateDifficulty();

    NetworkMessage msg( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
        msg.WriteString( ';spk "buttons/bell1";' );
    msg.End();
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    const CCommand@ args = pParams.GetArguments();
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( g_DDD.voting )
    {
        if( g_Utility.IsStringInt( args[0] ) && atoi( args[0] ) >= 0 && atoi( args[0] ) <= 100 )
        {
            playervotes[ pPlayer.entindex() ] = atoi( args[0] );

            m_Language.PrintMessage( pPlayer, msg.diff_voted, ML_CHAT, false, { { '$diff$', string( atoi( args[0] ) ) } } );
        }

        return HOOK_CONTINUE;
    }

    if( args[0] == "/diff" or args[0] == "diff"  )
    {
        if( pPlayer !is null && pPlayer.IsConnected() )
        {
            CreateMenu( pPlayer );
        }
    }
    return HOOK_CONTINUE;
}

CTextMenu@ g_VoteMenu;

void CreateMenu( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null && pPlayer.IsConnected() )
    {
        @g_VoteMenu = CTextMenu( @MainCallback );

        g_VoteMenu.SetTitle( m_Language.GetLanguage( pPlayer, msg.vote_menu ) );

        g_VoteMenu.AddItem( m_Language.GetLanguage( pPlayer, msg.vote_showinfo ) );
        g_VoteMenu.AddItem( m_Language.GetLanguage( pPlayer, msg.vote_startvote ) );

        g_VoteMenu.Register();
        g_VoteMenu.Open( 25, 0, pPlayer );
    }
}

void MainCallback( CTextMenu@ CMenu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
    if( pItem !is null )
    {
        string Choice = pItem.m_szName;

        if( iSlot == 1 )
        {
            GetInformation( pPlayer );
        }
        else if( iSlot == 2 )
        {
            if( g_DDD.cooldown > 0 )
            {
                m_Language.PrintMessage( pPlayer, msg.vote_cooldown, ML_CHAT, false, { { '$cooldown$', string( g_DDD.cooldown ) } } );
            }
            else
            {
                g_DDD.voting = true;

                m_Language.PrintMessage( null, msg.vote_diffstarted, ML_CHAT, true );

                g_Scheduler.SetTimeout( 'VoteEnded', ddd_cvars.votes_time );
                g_DDD.cooldown = ddd_cvars.votes_cooldown;
            }
        }
    }
}

dictionary playervotes;

void VoteEnded()
{
    g_DDD.voting = false;

    const array<string> votes = playervotes.getKeys();

    if( votes.length() < 1 )
        return;

    if( g_PlayerFuncs.GetNumPlayers() > 1 && int( votes.length() ) < g_PlayerFuncs.GetNumPlayers() / 2 )
    {
        m_Language.PrintMessage( null, msg.vote_notenought, ML_CHAT, true );
        playervotes.deleteAll();
        return;
    }

    int allvotes = 0;

    for( uint ui = 0; ui < votes.length(); ui++ )
    {
        allvotes = allvotes + int( playervotes[ votes[ui] ] );
    }

    SaveVote( string( int( allvotes / votes.length() ) ) );

    playervotes.deleteAll();

    m_Language.PrintMessage( null, msg.diff_updated, ML_CHAT, true, { { '$diff$', string( g_DDD.diff ) } } );
}

void UpdateDifficulty()
{
    func_player.UpdateDifficulty();
    func_alien_grunt.UpdateDifficulty();
    func_alien_slave.UpdateDifficulty();


    while( hDiff.GetEntity() is null )
    {
        hDiff = m_EntityFuncs.CreateEntity
        (
            {
                { 'targetname', 'DynamicDifficultyDeluxe' },
                { 'classname', 'info_target' },
                { '$i_difficulty', '0' },
                { '$s_difficulty', '0' }
            }
        );
    }

    g_EntityFuncs.DispatchKeyValue( hDiff.GetEntity().edict(), '$i_difficulty', g_DDD.diff );
}

EHandle hDiff;