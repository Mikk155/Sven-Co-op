from netapi.NET import *

def OnRegister() -> str:

    opfor: UpgradeContext = UpgradeContext();

    UpgradeContext.Mod = "gearbox";

    UpgradeContext.Title = "Opposing Force";

    UpgradeContext.Description = "Half-Life: Opposing-Force expansion";

    UpgradeContext.urls = [
        "https://store.steampowered.com/app/50/HalfLife_Opposing_Force/"
    ];

    UpgradeContext.Assets = {
        "Key": "Value"
    };

    UpgradeContext.maps = [
        # Boot camp
        "ofboot0",
        "ofboot1",
        "ofboot2",
        "ofboot3",
        "ofboot4",

        # intro
        "of0a0",

        #
        "of1a1",
        "of1a2",
        "of1a3",
        "of1a4",
        "of1a4b",
        "of1a5",
        "of1a5b",
        "of1a6",

        #
        "of2a1",
        "of2a1b",
        "of2a2",
        "of2a3",
        "of2a4",
        "of2a5",
        "of2a6",

        #
        "of3a1",
        "of3a1b",
        "of3a2",
        "of3a4",
        "of3a5",
        "of3a6",

        #
        "of4a1",
        "of4a2",
        "of4a3",
        "of4a4",
        "of4a5",

        #
        "of5a1",
        "of5a2",
        "of5a3",
        "of5a4",

        #
        "of6a1",
        "of6a2",
        "of6a3",
        "of6a4",
        "of6a4b",
        "of6a5",

        #
        "of7a0"
    ];

    return opfor.Serialize;
