void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "sex.com" );

    g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @throwable_grenade::PlayerPostThink );
}

namespace throwable_grenade
{
    HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer is null or !pPlayer.IsConnected() )
        {
            return HOOK_CONTINUE;
        }

        CBaseEntity@ pGrenade = null;
        CBaseEntity@ pEntity = null;
        CBaseEntity@ pOwner = null;

        bool bHasGrenade = ( pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_grenadethrow_hasgrenade' ).GetInteger() == 1 );

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'grenade' ) ) !is null )
        {
            @pOwner = g_EntityFuncs.Instance( pEntity.pev.owner );

            if( ( pEntity.pev.origin - pPlayer.pev.origin ).Length() <= 60 )
            {
                @pGrenade = pEntity;
                break;
            }
        }

        if( !bHasGrenade )
        {
            pPlayer.UnblockWeapons( pGrenade );
        }

        if( pGrenade !is null && !bHasGrenade && pGrenade.pev.FlagBitSet( FL_ONGROUND ) )
        {
            g_PlayerFuncs.PrintKeyBindingString( pPlayer, "Pickup grenade +use\n" );

            if( pPlayer.pev.button & IN_USE != 0  )
            {
                @pGrenade.pev.owner = pPlayer.edict();
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_grenadethrow_hasgrenade', 1 );
            }
        }
        if( pGrenade !is null && bHasGrenade )
        {
            pPlayer.BlockWeapons( pGrenade );
            g_PlayerFuncs.PrintKeyBindingString( pPlayer, "Throw +attack \n Roll +attack2\n" );

            g_EntityFuncs.SetOrigin( pGrenade, pPlayer.pev.origin );

            // make the grenade invisible
            pGrenade.pev.rendermode = kRenderTransTexture;

            if( pPlayer.pev.button & IN_ATTACK != 0 || pPlayer.pev.button & IN_ATTACK2 != 0 )
            {
                // Code by Giegue
                // https://github.com/JulianR0/TPvP/blob/master/src/map_scripts/hl_weapons/weapon_hlhandgrenade.as#L178
                Vector angThrow = pPlayer.pev.v_angle + pPlayer.pev.punchangle;
                if ( angThrow.x < 0 )
                    angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
                else
                    angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );
                
                float flVel = ( 90 - angThrow.x ) * 4;
                if ( flVel > 500 )
                    flVel = 500;

                g_EngineFuncs.MakeVectors( angThrow );
                
                Vector vecSrc = pPlayer.pev.origin + pPlayer.pev.view_ofs + g_Engine.v_forward * 16;
                
                Vector vecThrow = g_Engine.v_forward * flVel + pPlayer.pev.velocity;
                pGrenade.pev.velocity = vecThrow;
                g_EngineFuncs.VecToAngles( pGrenade.pev.velocity, pGrenade.pev.angles );

                // Idk, i just like how the grenade is thrown by attack2
                if( pPlayer.pev.button & IN_ATTACK != 0 )
                {
                    pGrenade.pev.origin = vecSrc;
                }
                // Render the grenade again
                pGrenade.pev.rendermode = kRenderNormal;

                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_grenadethrow_hasgrenade', 0 );

                // Make the player use "takecover" command
                NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                    msg.WriteString( ';takecover;' );
                msg.End();

                // I don't know how to apply animations to a player model, would be great toh
            }
        }
        return HOOK_CONTINUE;
    }
}