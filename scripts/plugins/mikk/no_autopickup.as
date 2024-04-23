//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
    g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );

    pJson.load( 'plugins/mikk/no_autopickup.json' );
}

json pJson;

HookReturnCode EntityCreated( CBaseEntity@ pEntity )
{
    if( pEntity is null )
        return HOOK_CONTINUE;

    if( pEntity.GetClassname().StartsWith( 'item_' )
        or pEntity.GetClassname().StartsWith( 'ammo_' )
            or pEntity.GetClassname().StartsWith( 'weapon_' ) ){
                CustomKeyValue( pEntity, '$f_no_autopickup_wait', g_Engine.time + 1.0f );
    }

    return HOOK_CONTINUE;
}

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult  )
{
    if( pPickup !is null && pOther !is null && pOther.IsPlayer() && g_Engine.time > CustomKeyValue( pPickup, '$f_no_autopickup_wait' ) )
    {
        bool b = ( pOther.IsFacing( pPickup.pev, VIEW_FIELD_NARROW ) || !pJson[ 'RequiredLoS', true ] );

        if( b )
        {
            if( pJson[ 'MessagePlayer', false ] )
            {
                string name = String::EMPTY_STRING;

                array<string> str = pPickup.GetClassname().Split( '_' );

                if( str.length() > 2 )
                {
                    for( uint u = 1; u < str.length(); u++ )
                    {
                        name += ( u == 1 ? '' : '_' ) + str[u];
                    }
                }
                else if( str.length() == 2 )
                {
                    name = str[1];
                }

                Mikk.Language.Print( cast<CBasePlayer@>( pOther ), pJson[ 'PickMeMessage', {} ], MKLANG::BIND, { { 'item', name } } );
            }
        }
        bResult = ( ( pOther.pev.button & IN_USE ) != 0 && b );
    }
    return HOOK_CONTINUE;
}
