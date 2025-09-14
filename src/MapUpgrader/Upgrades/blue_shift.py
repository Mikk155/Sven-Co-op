from netapi.NET import *

def register( context: UpgradeContext ) -> None:

    context.mod = "bshift";
    context.title = "Blue Shift";
    context.description = "Half-Life: Blue-Shift expansion";
    context.urls = [ "https://store.steampowered.com/app/130/HalfLife_Blue_Shift/" ];

global assets_directory;
assets_directory: str = "mikk/bshift";

def assets( assets: Assets ) -> None:

    global assets_directory;

    # Textures
    assets.install( "barney.wad" );

    # Skyboxes
    assets.install( "gfx/env/*.tga", f"gfx/env/{assets_directory}/" );

    # Maps
    assets.install( "maps/*.bsp" );

    # Music
    assets.install( "media/*.mp3", f"sound/{assets_directory}/music/" );
