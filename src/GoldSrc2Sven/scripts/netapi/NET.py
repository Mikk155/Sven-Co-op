from netapi.Entity import Entity;
from netapi.Vector import Vector;
from netapi.Upgrade import Upgrade;
from netapi.Assets import Assets;
from netapi.Map import Map;
from netapi.Logger import Logger;
from netapi.ConsoleColor import ConsoleColor;
from netapi.CFG import CFG;
from netapi.MapUpgrades import MapUpgrades;
from netapi.IMapUpgrade import IMapUpgrade;

import functools;
from typing import Callable, Optional;

def deprecated( NewMethod: str, Critical: Optional[bool] = False, Exit: Optional[bool] = False ) -> Callable:

    '''
        Mark a method as deprecated.

        ``NewMethod``: Name of a new method that should be used.

        ``Critical`` if True, the method won't execute its code.

        ``Exit`` If True the program exit with error 1.
    '''

    def decorator( func ) -> Callable:

        @functools.wraps( func )

        def wrapper( *args, **kwargs ):

            if Critical:
    
                print( f"ERROR! {func.__name__} is DEPRECATED Use {NewMethod} instead!" );

                return None;

            print( f"WARNING! {func.__name__} is DEPRECATED Use {NewMethod} instead!" );

        return wrapper;

    return decorator;
