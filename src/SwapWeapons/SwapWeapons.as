#include "fft"
#include "json"
#include "Language"

/*  INSTALLATION:

#include "SwapWeapons"

void MapInit()
{
    // maps/path/to/file.json or alternativelly a json-syntax writted here
    SwapWeapons::config ='maps/SwapWeapons.json';

    // Initialise
    SwapWeapons::MapInit();
}
*/

namespace SwapWeapons
{
    string config;

    json pJson;
    json Messages;
    json ItemNames;
    array<string> szClasses;

    void MapInit()
    {
        if( pJson.load( config ) == 0 )
        {
            Messages = pJson[ 'message', {} ];
            ItemNames = pJson[ 'item names', {} ];

            pJson = pJson[ ( pJson.exists( string( g_Engine.mapname ) ) ? string( g_Engine.mapname ) : 'Classes' ), {} ];

            szClasses = pJson.getKeys();

            if( szClasses.length() < 1 )
            {
                g_Game.AlertMessage( at_console, "[SwapWeapons] No classes detected in the json configuration!" + '\n' );
                return;
            }

            g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
        }
    }

    HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult  )
    {
        if( pPickup is null || pOther is null || !pOther.IsPlayer() )
            return HOOK_CONTINUE;

        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

        if( pPlayer is null )
            return HOOK_CONTINUE;

        for( uint ui = 0; ui < szClasses.length(); ui++ )
        {
            array<string> szClass = array<string>( pJson[ szClasses[ ui ] ] );

            if( szClass.find( pPickup.GetClassname() ) < 0 )
                continue;

            for( uint ui2 = 0; ui2 < szClass.length(); ui2++ )
            {
                if( szClass[ui2] == pPickup.GetClassname() )
                    continue;

                CBasePlayerItem@ pItem = pPlayer.HasNamedPlayerItem( szClass[ui2] );

                if( pItem !is null )
                {
                    Language::Print( pPlayer, Messages, MKLANG::HUDMSG,
                    {
                        { 'gun2', GetWeaponName( pPickup.GetClassname() ) },
                        { 'gun1', GetWeaponName( szClass[ui2] ) }
                    });
                    bResult = false;
                    return HOOK_CONTINUE;
                }
            }
        }
 
        return HOOK_CONTINUE;
    }

    string GetWeaponName( string name )
    {
        if( ItemNames.exists( name ) )
        {
            name = string( ItemNames[ name ] );
        }
        else {
            array<string> str = name.Split( '_' );
            if( str.length() > 2 )
                for( uint u = 1; u < str.length(); u++ )
                    name += ( u == 1 ? '' : '_' ) + str[u];
            else if( str.length() == 2 )
                name = str[1];
        }
        return name;
    }
}