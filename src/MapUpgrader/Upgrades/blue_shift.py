from netapi.NET import *

def OnRegister( context: UpgradeContext ) -> None:

    context.Mod = "bshift";
    context.Title = "Blue Shift";
    context.Description = "Half-Life: Blue-Shift expansion";
    context.urls = [ "https://store.steampowered.com/app/130/HalfLife_Blue_Shift/" ];

