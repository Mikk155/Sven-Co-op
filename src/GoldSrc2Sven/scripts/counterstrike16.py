from netapi.NET import *

def register_context( context: Upgrade ) -> None:

    context.mod = "cstrike";
    context.title = "Counter-Strike";
    context.description = "Counter-Strike";
    context.urls = [ "" ];

global assets_directory;
assets_directory: str = "mikk/bshift";

def install_assets( context: Assets ) -> None:

    pass;

def upgrade_map( context: Map ) -> None:

    context.upgrade.CS16Upgrades;
