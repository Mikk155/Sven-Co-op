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

/*
*   -TODO
*   There should be a method checking for json instance on PrecacheOther
*   Then allow dictionary to pass KeyValueData as i pointed to Nero in #scripting (SC Devs) if found
*   Similary to the method that exist in HalfLife-Unified SDK wich pass string_t array of key and value but a dictionary instead
*/

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( "plugins/mikk/CustomPrecache.json" );
}

namespace PrecacheType
{
    const int NONE = -1;
    const int GENERIC = 0;
    const int MODEL = 1;
    const int SOUND = 2;
    const int ENTITY = 3;
}

void PrecacheArrayOf( array<string> szPrecache, const int &in szType = PrecacheType::NONE )
{
    if( szType == PrecacheType::NONE )
        return;

    for( uint ui = 0; ui < szPrecache.length(); ui++ )
    {
        switch( szType )
        {
            case PrecacheType::GENERIC:
            {
                g_Game.PrecacheGeneric( szPrecache[ui] );
                continue;
            }
            case PrecacheType::MODEL:
            {
                g_Game.PrecacheGeneric( szPrecache[ui] );
                g_Game.PrecacheModel( szPrecache[ui] );
                continue;
            }
            case PrecacheType::SOUND:
            {
                g_Game.PrecacheGeneric( 'sound/' + szPrecache[ui] );
                g_SoundSystem.PrecacheSound( szPrecache[ui] );
                continue;
            }
            case PrecacheType::ENTITY:
            {
                g_Game.PrecacheOther( szPrecache[ui] );
                continue;
            }
        }
    }
}

void ResizeArrayOf( const int &in szType /* uint &out iOut*/, array<string> &out szOut, array<string> szIn, const uint Index )
{
    // Stupid uint&out, i'll pass from wasting time and effor.
    // https://discord.com/channels/818989352411463731/818992669413212170/1242549771747459224
    uint iOut = 0;
    switch( szType )
    {
        case PrecacheType::GENERIC:
            iOut = IndexGeneric;
        break;
        case PrecacheType::MODEL:
            iOut = IndexModel;
        break;
        case PrecacheType::SOUND:
            iOut = IndexSound;
        break;
    }

    if( iOut == szIn.length() )
    {
        iOut = 0;
    }

    szOut.resize(0);

    for( uint ui = iOut, i = 0; ui < szIn.length() && i < Index; ui++, iOut++, i++ )
    {
        szOut.insertLast( szIn[ui] );
    }

    // Same Switch as above for the same stupid thing as explained above.
    switch( szType )
    {
        case PrecacheType::GENERIC:
            IndexGeneric = iOut;
        break;
        case PrecacheType::MODEL:
            IndexModel = iOut;
        break;
        case PrecacheType::SOUND:
            IndexSound = iOut;
        break;
    }
}

uint IndexSound = 0, IndexModel = 0, IndexGeneric = 0;

array<string> szSound, szModel, szGener;

string szMapName;

void MapInit()
{
    /*
    *   Should reload when it's a blacklisted map?
    *   Or would this blacklisted map be modified and reload should be before checking blacklist?
    *   Questions that takes out my desires to sleep.
    *   Let's do reload-check *even* if it's a blacklisted map :$
    */
    pJson.reload( 'plugins/mikk/CustomPrecache.json' );

    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) > 1 ) { return; }

    PrecacheArrayOf( array<string>( pJson[ "PrecacheOther" ] ), PrecacheType::ENTITY );
    PrecacheArrayOf( array<string>( pJson[ "PrecacheSound", {} ][ "Always Precache" ] ), PrecacheType::SOUND );
    PrecacheArrayOf( array<string>( pJson[ "PrecacheModel", {} ][ "Always Precache" ] ), PrecacheType::MODEL );
    PrecacheArrayOf( array<string>( pJson[ "PrecacheGeneric", {} ][ "Always Precache" ] ), PrecacheType::GENERIC );

    if( string( g_Engine.mapname ) != szMapName )
    {
        ResizeArrayOf( PrecacheType::SOUND, szSound, array<string>( pJson[ "PrecacheSound", {} ][ "Dynamic Precache" ] ), uint( pJson[ "PrecacheSound", {} ][ "Dynamic Assets", 3 ] ) );
        ResizeArrayOf( PrecacheType::MODEL, szModel, array<string>( pJson[ "PrecacheModel", {} ][ "Dynamic Precache" ] ), uint( pJson[ "PrecacheModel", {} ][ "Dynamic Assets", 3 ] ) );
        ResizeArrayOf( PrecacheType::GENERIC, szGener, array<string>( pJson[ "PrecacheGeneric", {} ][ "Dynamic Precache" ] ), uint( pJson[ "PrecacheGeneric", {} ][ "Dynamic Assets", 3 ] ) );

        szMapName = string( g_Engine.mapname );
    }

    PrecacheArrayOf( szSound, PrecacheType::SOUND );
    PrecacheArrayOf( szModel, PrecacheType::MODEL );
    PrecacheArrayOf( szGener, PrecacheType::GENERIC );
}
