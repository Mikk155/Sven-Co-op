void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( 'Mikk' );
    g_Module.ScriptInfo.SetContactInfo( 'github.com/Mikk155' );
    g_Scheduler.SetInterval( "HWGRUNTTHINK", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void HWGRUNTTHINK()
{
    CBaseEntity@ pEntity = null;

    while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_hwgrunt" ) ) !is null )
    {
        CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);

        if(pMonster is null
        or pMonster.pev.deadflag != DEAD_NO
        or !pMonster.IsAlive()
        or pMonster.m_hEnemy.GetEntity() is null )
        {
            continue;
        }

        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pMonster.m_hEnemy.GetEntity() );

        if( pPlayer !is null
        and pPlayer.pev.button & IN_DUCK != 0
        and ( pMonster.pev.origin - pPlayer.pev.origin ).Length() <= 64 )
        {
            pPlayer.TakeDamage( pMonster.pev, pMonster.pev, 10, DMG_BULLET );
        }
    }
}