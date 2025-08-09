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
import sys;

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

from utils.jsonc import jsonc;
AssetsPackage: dict = jsonc(
    file_path=PathPackage,
    schema_validation=jsonc(
        Path.enter(
            "schemas",
            "assets.json"
        )
    ),
    sensitive=True,
    fnoutput=g_Logger.info
);
del PathPackage;

PathSvenCoop: str = Path.enter( "steamapps", "common", "Sven Co-op", CurrentDir= Path.GetSteamInstallation() );
PathSources: str = Path.enter( "src" );

from enum import IntEnum

class ASSET( IntEnum ):
    ABS_SOURCE = 0;
    ABS_SVEN = 1;
    RELATIVE = 2;

RelativeAssetsPath: list[tuple[ASSET]] = [];

for Root, _, Files in os.walk( PathFile ):
#
    for File in Files:
    #
        if File == "assets.json":
        #
            continue;
        #

        AssetType: str = AssetsPackage[ "type" ];

        if AssetType == "metamod":
        #
            continue;
        #

        PathAbsoluleToSource: str = os.path.join( Root,  File );
        PathRelative: str = os.path.relpath( PathAbsoluleToSource, PathSources );
        PathAbsoluleToSven: str = Path.enter(
            "svencoop_addon",
            "scripts",
            "plugins" if AssetType == "plugin" else "maps",
            PathRelative,
            SupressWarning=True,
            CreateIfNoExists=True,
            CurrentDir=PathSvenCoop
        );

        RelativeAssetsPath.append( ( PathAbsoluleToSource, PathAbsoluleToSven, PathRelative ) );
    #
#

import shutil;
for Asset in RelativeAssetsPath:
#
    g_Logger.info( "Installing <g>{}<>", Asset[ASSET.RELATIVE] );
    shutil.copy( Asset[ASSET.ABS_SOURCE], Asset[ASSET.ABS_SVEN] );
    del Asset;
#

del RelativeAssetsPath;
