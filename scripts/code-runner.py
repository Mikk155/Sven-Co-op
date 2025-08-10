'''
MIT License

Copyright (c) 2025 Mikk

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
'''

import os;
import sys

MyWorkspace: str = os.path.abspath( os.path.dirname( os.path.dirname( __file__ ) ) );

# Fix relative library importing by appending the directory to the sys path.
sys.path.append( MyWorkspace );

# Now we're safe to import more stuff
from utils.Path import Path;
Path.SetWorkspace( MyWorkspace );

# We don't need this anymore. Path stores it on 'workspace' in the global scope
del MyWorkspace;

from utils.Logger import Logger, LoggerSetLevel, LoggerLevel;

LoggerSetLevel( LoggerLevel.Trace );
LoggerSetLevel( LoggerLevel.Debug );
LoggerSetLevel( LoggerLevel.Information );
LoggerSetLevel( LoggerLevel.Warning );

g_Logger: Logger = Logger( "Code Runner" );

if not "-file" in sys.argv:
#
    g_Logger.critical( "No \"-file\" argument provided!", Exit=True );
#

if len(sys.argv) == sys.argv.index( "-file" ) + 1:
#
    g_Logger.critical( "No argument provided after \"-file\"", Exit=True );
#

PathFile: str = sys.argv[ sys.argv.index( "-file" ) + 1 ];

if not os.path.exists( PathFile ):
#
    g_Logger.critical( "Unexistent path <c>{}<>", PathFile, Exit=True );
#

# We want the folder directory
if os.path.isfile( PathFile ):
#
    PathFile = os.path.dirname( PathFile );
#

PathPackage: str = os.path.join( PathFile, "assets.json" );

if not os.path.exists( PathPackage ):
#
    g_Logger.critical( "Unexistent package file <c>{}<>", PathPackage, Exit=True );
#

PathSvenCoop: str = Path.enter( "steamapps", "common", "Sven Co-op", "svencoop_addon", CurrentDir= Path.GetSteamInstallation() );
PathSources: str = Path.enter( "src" );

class Asset:

    def __init__( self, path: str ) -> None:
    #
        self.paths: list[str] = path.split( "/" );
    #

    @property
    def Relative( self ) -> str:
    #
        return os.path.relpath( self.Source, PathSources );
    #

    @property
    def Source( self ) -> str:
    #
        return Path.enter( *self.paths, CurrentDir=PathSources, CreateIfNoExists=True, SupressWarning=True );
    #

    @property
    def Destination( self ) -> str:
    #
        return Path.enter( *self.paths, CurrentDir=PathSvenCoop, CreateIfNoExists=True, SupressWarning=True );
    #

    @property
    def IsValid( self ) -> bool:
    #
        return os.path.exists( self.Source );
    #

AssetsInstallationList: list[Asset] = [];

def InstallAssets( AssetsPath: str ):

    from utils.jsonc import jsonc;

    AssetsPackage: dict = jsonc( file_path=os.path.join( PathSources, AssetsPath ), sensitive=True, fnoutput=g_Logger.trace );

    for asset_path in AssetsPackage[ "assets" ]:
    #
        asset = Asset( asset_path );

        if asset.IsValid:
        #
            AssetsInstallationList.append( asset );
        #
        else:
        #
            g_Logger.error( "Unexistent asset <g>{}<>", asset_path );
        #
    #

    for Include in AssetsPackage.get( "includes", [] ):
    #
        g_Logger.info( "Including <g>{}<>", Include );
        InstallAssets( Include );
    #

InstallAssets( os.path.relpath( PathPackage, PathSources ) );

del PathPackage;

import shutil;

for asset in AssetsInstallationList:
#
    g_Logger.info( "Installing <g>{}<>", asset.Relative );

    if os.path.exists( asset.Source ):
    #
        shutil.copy( asset.Source, asset.Destination );
    #
    else:
    #
        g_Logger.error( "Unextistent defined asset <c>{}<>", asset.Relative );
    #
#

del AssetsInstallationList;
