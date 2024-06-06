#include "fft"
#include "json"
#include "Language"
#include "EntityFuncs"
#include "CustomKeyValues"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
    g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );

    pJson.load( 'plugins/mikk/no_autopickup.json' );
}

bool bRemoved;

void MapActivate()
{
    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) > 0 )
    {
        g_Hooks.RemoveHook( Hooks::Game::EntityCreated, @EntityCreated );
        g_Hooks.RemoveHook( Hooks::PickupObject::CanCollect, @CanCollect );
        bRemoved = true;
        return;
    }

    if( bRemoved )
    {
        g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
        g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
        bRemoved = false;
    }

}

json pJson;

HookReturnCode EntityCreated( CBaseEntity@ pEntity )
{
    if( pEntity is null)
        return HOOK_CONTINUE;

    if( pEntity.GetClassname().StartsWith( 'item_' )
        or pEntity.GetClassname().StartsWith( 'ammo_' )
            or pEntity.GetClassname().StartsWith( 'weapon_' ) ){
                if( array<string>( pJson[ "blacklist items" ] ).find( pEntity.GetClassname() ) < 0 ) {
                    ckvd[ pEntity, '$f_no_autopickup_wait', g_Engine.time + 1.0f ];
            }
    }

    return HOOK_CONTINUE;
}

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult  )
{
    if( pPickup !is null && pOther !is null && pOther.IsPlayer() && g_Engine.time > float( ckvd[ pPickup, '$f_no_autopickup_wait' ] ) )
    {
        bool Facing = ( pOther.IsFacing( pPickup.pev, VIEW_FIELD_NARROW ) || !pJson[ 'RequiredLoS', true ] );
        bool CanTake = true; // -TODO https://github.com/Mikk155/Sven-Co-op/issues/30

        if( Facing && CanTake )
        {
            if( pJson[ 'MessagePlayer', false ] )
            {
                string name = String::EMPTY_STRING;

                json pNames = pJson[ "item names", {} ];
                if( pNames.exists( pPickup.GetClassname() ) )
                {
                    name = string( pNames[ pPickup.GetClassname() ] );
                }
                else {
                    array<string> str = pPickup.GetClassname().Split( '_' );
                    if( str.length() > 2 )
                        for( uint u = 1; u < str.length(); u++ )
                            name += ( u == 1 ? '' : '_' ) + str[u];
                    else if( str.length() == 2 )
                        name = str[1];
                }

                Language::Print( cast<CBasePlayer@>( pOther ), pJson[ 'PickMeMessage', {} ], MKLANG::BIND, { { 'item', name } } );
            }
        }
        bResult = ( Facing && ( pOther.pev.button & IN_USE ) != 0 );
    }
    return HOOK_CONTINUE;
}
