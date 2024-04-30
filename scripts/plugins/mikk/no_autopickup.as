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

#include "../../mikk/json"
#include "../../mikk/Language"
#include "../../mikk/EntityFuncs"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( 'plugins/mikk/no_autopickup.json' );
}

void MapActivate()
{
    g_Hooks.RemoveHook( Hooks::Game::EntityCreated, @EntityCreated );
    g_Hooks.RemoveHook( Hooks::PickupObject::CanCollect, @CanCollect );

    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) < 1 )
    {
        g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
        g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
    }
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
        bool Facing = ( pOther.IsFacing( pPickup.pev, VIEW_FIELD_NARROW ) || !pJson[ 'RequiredLoS', true ] );
        bool CanTake = true; // -TODO https://github.com/Mikk155/Sven-Co-op/issues/30

        if( Facing && CanTake )
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

                Language::Print( cast<CBasePlayer@>( pOther ), pJson[ 'PickMeMessage', {} ], MKLANG::BIND, { { 'item', name } } );
            }
        }
        bResult = ( Facing && ( pOther.pev.button & IN_USE ) != 0 );
    }
    return HOOK_CONTINUE;
}
