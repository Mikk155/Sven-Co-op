from netapi.NET import *

def register( context: UpgradeContext ) -> None:

    context.mod = "gearbox";

    context.title = "Opposing Force";

    context.description = "Half-Life: Opposing-Force expansion";

    context.urls = [
        "https://store.steampowered.com/app/50/HalfLife_Opposing_Force/"
    ];

global assets_directory;
assets_directory: str = "mikk/opfor";

def assets( assets: Assets ) -> None:

    global assets_directory;

    # Textures
    assets.install( "OPFOR.WAD", "opfor.wad" );
    # Decals are hardcoded so the game itself must support these texture entries in their decals.wad
    # assets.install( "DECALS.WAD", "decals.wad" );

    # Skyboxes
    assets.install( "gfx/env/*.tga", f"gfx/env/{assets_directory}/" );

    # Maps
    assets.install( "maps/of*.bsp" );

    # Music
    assets.install( "media/*.mp3", f"sound/{assets_directory}/music/" );
    # -TODO If the target game is Seven Kewp this script or either the program should detect it
    # And so to update mp3 files to wav as lack of client fmod?
