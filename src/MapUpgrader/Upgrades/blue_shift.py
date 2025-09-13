from netapi.NET import *

def register( context: UpgradeContext ) -> None:

    context.mod = "bshift";
    context.title = "Blue Shift";
    context.description = "Half-Life: Blue-Shift expansion";
    context.urls = [ "https://store.steampowered.com/app/130/HalfLife_Blue_Shift/" ];

