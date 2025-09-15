from netapi.NET import *

def register_context( context: Upgrade ) -> None:

    context.logger.info.WriteLine( "Called register_context" );

    context.mod = "bshift";
    context.title = "Blue Shift";
    context.description = "Half-Life: Blue-Shift expansion";
    context.urls = [ "https://store.steampowered.com/app/130/HalfLife_Blue_Shift/" ];

global assets_directory;
assets_directory: str = "mikk/bshift";

def install_assets( context: Assets ) -> None:

    global assets_directory;

    context.owner.logger.info.WriteLine( "Called install_assets" );

    # Textures
    context.install( "barney.wad" );

    # Skyboxes
    context.install( "gfx/env/*.tga", f"gfx/env/{assets_directory}/" );

    # Maps
    context.install( "maps/*.bsp" );

    # Music
    context.install( "media/*.mp3", f"sound/{assets_directory}/music/" );

    from shared.BlueShiftBSPConverter import FixBSP;

    for BSP in context.owner.maps:
        context.owner.logger.info.WriteLine( f"Updating offsets of map \"{BSP}\"" );
        FixBSP( BSP );

def upgrade_map( context: Map ) -> None:

    context.owner.logger.info.WriteLine( "Called upgrade_map" );

    for entity in context.entities:
        
        match entity.GetString( "classname" ):

            case "info_player_start":

                entity.SetString( "classname", "info_player_deathmatch" );
