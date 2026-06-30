#==================================================================================
#
#   Stock Entity List
#
#   Simple Python script that analizes serverdll to find game registered entity classnames.
#
#   pip install pefile
#
#   python main.py "C:/Path\To\Your\Sven Co-op\svencoop\dlls\server.dll"
#
#   This will generate a StockEntityList.txt next to this file.
#
#==================================================================================

import os;
import sys;
import pefile;
from pathlib import Path;

g_DLLPath: Path = "";

while True:

    if len( sys.argv ) < 2:
        sys.argv.append( "" );
    else:
        g_DLLPath = sys.argv[1];

    if g_DLLPath == "":
        print( "No path to server.dll provided!" );
    elif not g_DLLPath.exists():
        print( f"server.dll not found at \"{g_DLLPath}\"" );
    elif not g_DLLPath.is_file() or g_DLLPath.suffix != ".dll":
        print( f"file is not a .dll \"{g_DLLPath}\"" );
    else:
        break;

    sys.argv[1] = Path( input( "Provide a valid full path to server.dll or drag & drop the dll to this console now.\n" ).removeprefix( '"' ).removesuffix( '"' ) );

print( f"Opening \"{g_DLLPath}\"" );

try:
    pe = pefile.PE( g_DLLPath );
except Exception as e:
    input( f"Error: {e}" );
    sys.exit(1);

foundEnts: set = set();

foundEnts = [];

for export in pe.DIRECTORY_ENTRY_EXPORT.symbols:

    if export.name:

        try:
            functionName: str = export.name.decode( 'utf-8' );
            # Ew could use some regex maybe but a entity normally is all lowercase while code is camel case so this should do it.
            if functionName.lower() == functionName:
                foundEnts.append( functionName );
        except UnicodeDecodeError:
            continue;

foundEnts = sorted( list( foundEnts ) )

listPath = Path( os.path.join( os.path.dirname( __file__ ), "StockEntityList.txt" ) );

with open( listPath, "w" ) as fStream:
    fStream.write( "".join( f"{entity}\n" for entity in foundEnts ) );

print( f"Writted {len(foundEnts)} entities to \"{g_DLLPath}\"" );
