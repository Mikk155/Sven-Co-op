# ====================================================
# Purpose: Generate hmtl files for all the definition files
# ====================================================

import os
import json

class Path:
    Script: str = os.path.dirname( __file__ );
    '''Current directory of this script'''
    Workspace: str = os.path.dirname( os.path.dirname( Script ) );
    '''Base repository directory'''
    Definitions: str = os.path.join( Script, "definitions" );
    '''Json definition files'''
    Documents: str = os.path.join( os.path.join( Workspace, "docs" ), "downloads" );
    '''HTML folder'''

def GetTemplate( name: str ) -> str:
    '''Get a template by file name'''
    with open( os.path.join( os.path.join( Path.Script, "templates" ), f"{name}.html" ), "r", encoding="utf-8" ) as f:
        return f.read();
    return None;

T_index: str = GetTemplate( "index" );
T_block: str = GetTemplate( "block" );
T_asset: str = GetTemplate( "asset" );

T_GreenColor = "#3aaa10";
T_RedColor = "#cc4444";

g_Plugins: list[dict] = []
g_MapScripts: list[dict] = []

def AddIncludes( obj: dict ):
    '''Include all "includes" of obj into it's "assets" list'''

    if "includes" in obj:

        includes = obj.pop( "includes" );

        for include in includes:

            with open( os.path.join( Path.Definitions, include ), "r", encoding="utf-8" ) as f:
                included = json.load(f)
                AddIncludes(included);
                assets: list[str] = obj[ "assets" ]
                for asset in included[ "assets" ]:
                    assets.append( asset ); # Python lists works as reference. just append to it

for file in os.listdir( Path.Definitions ):

    if not file.endswith(".json"):
        continue

    print( f"Parsing {file}" );

    path: str = os.path.join( Path.Definitions, file )

    data: dict = None;

    with open( path, "r", encoding="utf-8" ) as f:
        data = json.load(f)

    scriptName: str = data[ "name" ];
    scriptTitle: str = data.get( "title", scriptName );
    data[ "title" ] = scriptTitle;
    scriptDescription: str = data.get( "description", "No description provided." );
    if not "short_description" in data:
        data[ "short_description" ] = scriptDescription;
    AddIncludes( data );
    scriptAssets: list[str] =  data[ "assets" ];
    for asset in scriptAssets:
        if not os.path.exists( os.path.join( Path.Workspace, asset ) ):
            print( f"Invalid file {asset} at {file}!" );
            exit(0);

    scriptAssets: str = json.dumps( scriptAssets );
    data[ "assets" ] = scriptAssets;
    scriptMapScript: str = f"""<a style="color:{T_RedColor}">✗ No</a>""";
    scriptPlugin: str = f"""<a style="color:{T_RedColor}">✗ No</a>""";
    scriptMetamod: str = None;

    isMapScript = data.get( "map_script", False );

    if isMapScript is True:
        scriptMapScript: str = f"""<a style="color:{T_GreenColor}">✓ Yes</a>""";

    isPlugin = data.get( "plugin", False );

    if isPlugin is True:
        scriptPlugin: str = f"""<a style="color:{T_GreenColor}">✓ Yes</a>""";

    metamodType = data.get( "metamod", "no" );

    if metamodType:
        match metamodType:
            case "no":
                scriptMetamod: str = f"""<a style="color:{T_GreenColor}">✗ Not needed</a>""";
            case "required":
                scriptMetamod: str = f"""<a href="https://github.com/Mikk155/Sven-Co-op/releases/tag/metamod" target="_blank" style="color:{T_RedColor}">✓ Required</a>""";
            case "optional":
                scriptMetamod: str = f"""<a href="https://github.com/Mikk155/Sven-Co-op/releases/tag/metamod" target="_blank" style="color:{T_GreenColor}">✓ Partial support</a>""";
    data[ "metamod" ] = scriptMetamod;

    html: str = T_asset \
        .replace( "{name}", scriptName ) \
        .replace( "{title}", scriptTitle ) \
        .replace( "{assets}", scriptAssets ) \
        .replace( "{map_script}", scriptMapScript ) \
        .replace( "{plugin}", scriptPlugin ) \
        .replace( "{metamod}", scriptMetamod ) \
        .replace( "{description}", scriptDescription.replace( "\n", "<br>" ) );

    outputFile: str = os.path.join( Path.Documents, f"{scriptName}.html" );

    with open( outputFile, "w", encoding="utf-8" ) as f:
        f.write( html )

    if isMapScript is True:
        g_MapScripts.append( data );

    if isPlugin is True:
        g_Plugins.append( data );

g_MaxShortDescriptionCharacters = 128;

def GetBufferFor( obj: list ) -> str:

    buffer: str = "";

    for script in obj:

        scriptDescription: str = script[ "short_description" ];
        if len( scriptDescription ) > g_MaxShortDescriptionCharacters:
            scriptDescription = scriptDescription[ 0 : g_MaxShortDescriptionCharacters ] + f"""<a href="downloads/{script[ "name" ]}.html">...</a>""";

        buffer += "\n" + T_block \
            .replace( "{name}", script[ "name" ] ) \
            .replace( "{title}", script[ "title" ] ) \
            .replace( "{metamod}", script[ "metamod" ] ) \
            .replace( "{description}", scriptDescription ) \
            .replace( "{assets}", script.get( "assets" ) );

    return buffer;

html = T_index \
    .replace( "{plugins}", GetBufferFor( g_Plugins ) ) \
    .replace( "{map_scripts}", GetBufferFor( g_MapScripts ) );

with open( os.path.join( Path.Documents, f"index.html" ), "w", encoding="utf-8" ) as f:
    f.write( html )
