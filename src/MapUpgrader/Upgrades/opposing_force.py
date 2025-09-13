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

    assets.Copy( "maps/of*.bsp" );

    assets.Copy( "models/v_9mmar.mdl", f"models/{assets_directory}/v_9mmar.mdl" );
