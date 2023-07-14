void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );
}

HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
{
    if( pPlayer !is null && pWeapon.GetClassname() == 'weapon_medkit' )
    {
        CBaseEntity@ pGrenade = null;

        while( ( @pGrenade = g_EntityFuncs.FindEntityByClassname( pGrenade, 'grenade' ) ) !is null )
        {
            CBasePlayer@ pOwner = cast<CBasePlayer@>( g_EntityFuncs.Instance( pGrenade.pev.owner ) );

            if( pOwner !is null && pOwner is pPlayer && ( pGrenade.pev.origin - pPlayer.pev.origin ).Length() <= 60 )
            {
                g_EntityFuncs.DispatchKeyValue( pGrenade.edict(), 'is_not_revivable', 1 );
            }
        }
    }
    return HOOK_CONTINUE;
}