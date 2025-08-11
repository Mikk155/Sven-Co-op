from tasks.task import Task, Asset;

# Workspace and loggers are already setup from __main__
from utils.Path import Path;
from utils.Logger import Logger;

class Task_Example( Task ):

    logger = Logger( "Task Example" );

    def Run( self, assets: list[Asset] ) -> int:

        print( 'Run your code here.' );

        if 1 == 2:
            self.logger.critical( "ONE IS NOT TWO. SOMETHING BAD HAPPENED!" )
            return 1;

        return 0;

