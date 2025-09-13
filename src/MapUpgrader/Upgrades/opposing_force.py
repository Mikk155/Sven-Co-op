from netapi.NET import *

def register( context: UpgradeContext ) -> None:

    context.mod = "gearbox";

    context.title = "Opposing Force";

    context.description = "Half-Life: Opposing-Force expansion";

    context.urls = [
        "https://store.steampowered.com/app/50/HalfLife_Opposing_Force/"
    ];

def assets( assets: Assets ) -> None:

    assets.Copy( "maps/of*.bsp" );
