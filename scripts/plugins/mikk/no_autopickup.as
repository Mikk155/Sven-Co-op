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
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );

    pJson.load( 'plugins/mikk/no_autopickup.json' );
    pItems = pJson[ 'ItemList', {} ];
}

json pItems;
json pJson;

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult  )
{
    if( pPickup !is null && pOther !is null && pOther.IsPlayer() && ( pPickup.pev.flags & FL_ONGROUND ) != 0 )
    {
        for( uint ui = 0; ui < pItems.length(); ui++ )
        {
            if( pPickup.GetClassname() == pItems[ui,''] || pItems[ui,''].EndsWith( '*' )
                    && pPickup.GetClassname().StartsWith( pItems[ui, ''].SubString( 0, pItems[ui, ''].Length() - 1 ) ) ) {

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

                bResult = ( ( pOther.pev.button & IN_USE ) != 0 );
            }
        }
    }
    return HOOK_CONTINUE;
}
