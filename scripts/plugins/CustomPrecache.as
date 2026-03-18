/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

#include "../mikk155/meta_api"
#include "../mikk155/meta_api/json"

int g_DynamicPrecacheMax = 5;
int g_LastIndexPrecaching = 0;
dictionary g_AlwaysPrecache;
dictionary g_DynamicPrecache;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    meta_api::NoticeInstallation();

    g_Hooks.RegisterHook( Hooks::Game::MapChange, MapChangeHook( function( const string &in mapname )
    {
        if( mapname != string( g_Engine.mapname ) )
        {
            g_LastIndexPrecaching += g_DynamicPrecacheMax;

            if( g_LastIndexPrecaching >= g_DynamicPrecache.getSize() + g_DynamicPrecacheMax )
                g_LastIndexPrecaching = 0;
        }
        return HOOK_CONTINUE;
    } ) );

    dictionary data;
    meta_api::json::Deserialize( "scripts/plugins/CustomPrecache.json", data );
    g_AlwaysPrecache = cast<dictionary>( data[ "AlwaysPrecached" ] );
    g_DynamicPrecache = cast<dictionary>( data[ "DynamicPrecache" ] );
    data.get( "MaxDynamicPrecache", g_DynamicPrecacheMax );
}

enum PrecacheType
{
    Dictionary = 0,
    Generic,
    Model,
    Sound,
    Entity
};

void Precache( const string&in asset, const dictionaryValue&in type )
{
    switch( PrecacheType( int( type ) ) )
    {
        case PrecacheType::Generic:
        {
            g_Game.PrecacheGeneric( asset );

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "Precached generic %1\n", asset );
#endif
            break;
        }
        case PrecacheType::Model:
        {
            g_Game.PrecacheModel( asset );

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "Precached model %1\n", asset );
#endif
            break;
        }
        case PrecacheType::Sound:
        {
            string buffer;
            snprintf( buffer, "sound/%1", asset );

            g_Game.PrecacheGeneric( buffer );
            g_SoundSystem.PrecacheSound( asset );

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "Precached sound %1\n", buffer );
#endif
            break;
        }
        case PrecacheType::Entity:
        {
            g_Game.PrecacheOther( asset );

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "Precached entity %1\n", asset );
#endif
            break;
        }
        case PrecacheType::Dictionary:
        default:
        {
            dictionary keyvalues = cast<dictionary>( type );

            auto entity = g_EntityFuncs.CreateEntity( asset, keyvalues, false );
            entity.Precache();
            entity.pev.flags |= FL_KILLME;

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "Precached entity {\n\"classname\" \"%1\"\n", asset );

            array<string>@ keyNames = keyvalues.getKeys();

            for( uint ui = 0; ui < keyNames.length(); ui++ )
            {
                string keyName = keyNames[ui];
                g_Game.AlertMessage( at_console, "\"%1\" \"%2\"\n", keyName, string( keyvalues[ keyName ] ) );
            }

            g_Game.AlertMessage( at_console, "}\n" );
#endif
            break;
        }
    }
}

void MapInit()
{
    array<string>@ assets = g_AlwaysPrecache.getKeys();
    uint size = assets.length();

    for( uint ui = 0; ui < size; ui++ )
    {
        string asset = assets[ui];

        Precache( asset, g_AlwaysPrecache[ asset ] );
    }


    @assets = g_DynamicPrecache.getKeys();
    size = assets.length();

    int current = 0;
    for( uint ui = g_LastIndexPrecaching; ui < size; ui++ )
    {
        string asset = assets[ui];

        Precache( asset, g_DynamicPrecache[ asset ] );

        current++;

        if( current >= g_DynamicPrecacheMax )
            break;
    }
}
