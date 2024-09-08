#include 'mikk/as_register'

namespace lp_items
{
    array<ItemMapping@> g_ItemMappings;
    array<EHandle> Renders;

    void MapInit()
    {
	    g_ClassicMode.SetItemMappings( @g_ItemMappings );
        g_ClassicMode.ForceItemRemap( true );

        g_ClassicMode.EnableMapSupport();
g_ClassicMode.SetShouldRestartOnChange( false );

        Renders.resize(0);

        while( Renders.length() < uint( g_Engine.maxClients ) )
        {
            dictionary k =
            {
                { 'classname', 'env_render_individual' },
                { 'spawnflags', '73' },
                { 'targetname', 'II_RenderingItems' },
                { 'renderamt', '90' },
                { 'rendermode', '2' }
            };

            CBaseEntity@ pRender = g_EntityFuncs.CreateEntity( 'env_render_individual', k, true );

            if( pRender !is null )
            {
                Renders.insertLast( @pRender );
            }
        }

        string line, key, value;

        File@ pFile = g_FileSystem.OpenFile( 'scripts/maps/lp_items/' + string( g_Engine.mapname ) + '.gir', OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Game.AlertMessage( at_console, 'Can NOT open ' + '"scripts/maps/lp_items/' + string( g_Engine.mapname ) + '.gir"' + ' Opening global_items_replace.\n' );
            @pFile = g_FileSystem.OpenFile( 'scripts/maps/lp_items/global_items_replace.gir', OpenFile::READ );
        }

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Game.AlertMessage( at_console, 'Can NOT open ' + '"scripts/maps/lp_items/global_items_replace.gir"' + '\n' );
            return;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' and line[1] == '/' )
            {
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            g_Game.AlertMessage( at_console, 'Added item mapping from "' + key + '" To "' + value + '"\n' );
            g_ItemMappings.insertLast( ItemMapping( key, value ) );
        }
        pFile.Close();
    }
}