import os;
import sys;
import subprocess;

TestingRuntime: bool = True;

def InstallRequirements() -> None:
#
    RequirementFiles: list[str] = [
        os.path.join( 'utils', "requirements.txt" )
    ];

    print( "Installing Requirements..." );

    for RequirementFile in RequirementFiles:
    #
        RequirementFilePath: str = os.path.join( os.path.dirname( __file__ ), RequirementFile );

        try:
        #
            subprocess.check_call( [ sys.executable, "-m", "pip", "install", "-r", RequirementFilePath ] );
        #
        except Exception as e:
        #
            input( f"ERROR: Something went wrong installing requirements. Exception: {e}" );
            sys.exit(1);
        #
    #
#

if not TestingRuntime:
    InstallRequirements();

MyWorkspace: str = os.path.abspath( os.path.dirname( __file__ ) );

# Fix relative library importing by appending the directory to the sys path.
sys.path.append( MyWorkspace );

from utils.Path import Path;
Path.SetWorkspace( MyWorkspace );
del MyWorkspace;

from utils.Logger import Logger, LoggerSetLevel, LoggerLevel;
LoggerSetLevel( LoggerLevel.AllLoggers );
g_Logger: Logger = Logger( "Setup" );
