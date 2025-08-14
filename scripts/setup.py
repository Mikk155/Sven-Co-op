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

PathSvenCoop: str = Path.enter( "steamapps", "common", "Sven Co-op", CurrentDir= Path.GetSteamInstallation() );
PathPluginsAddon: str = Path.enter( "svencoop_addon", "default_plugins.txt", CurrentDir=PathSvenCoop, CreateIfNoExists=True, SupressWarning=True );

MPManagerHeader: str = '''\n
\t"plugin"
\t{
\t\t"name" "MKExtension"
\t\t"script" "MKExtension/main"
\t\t"concommandns" "mke"
\t}\n
''';

if not os.path.exists( PathPluginsAddon ):
#
    with open( PathPluginsAddon, "w" ) as default_plugins:
    #
        g_Logger.info( "Generating <c>{}<>", PathPluginsAddon );
        default_plugins.write( '''"plugins"\n{{{}}}'''.format( MPManagerHeader ) );
    #
#
else:
#
    with open( PathPluginsAddon, "r" ) as default_plugins:
    #
        Content: str = default_plugins.read();

        if Content.find( "\"script\" \"MPManager\"" ) == -1:
        #
            g_Logger.info( "Updating <c>{}<>", PathPluginsAddon );

            IndexEnd: int = Content.rfind( "}" );

            Content = Content[ : IndexEnd - 1 ] + MPManagerHeader + Content[ IndexEnd ];

            with open( PathPluginsAddon, "w" ) as default_plugins_write:
            #
                default_plugins_write.write( Content );
            #
        #
    #
#

del PathPluginsAddon;
