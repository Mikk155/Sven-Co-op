from netapi.NET import *

def OnRegister() -> str:

    bshift: UpgradeContext = UpgradeContext();

    UpgradeContext.Mod = "bshift";
    UpgradeContext.Title = "Blue Shift";
    UpgradeContext.Description = "Half-Life: Blue-Shift expansion";
    UpgradeContext.urls = [ "https://store.steampowered.com/app/130/HalfLife_Blue_Shift/" ];
    UpgradeContext.maps = [];

    return bshift.Serialize;
