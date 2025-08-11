'''
MIT License

Copyright (c) 2025 Mikk155

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
SOFTWARE.
'''

import os;
import re;
import sys;
import json;

MyWorkspace: str = os.path.abspath( os.path.dirname( os.path.dirname( __file__ ) ) );

# Fix relative library importing by appending the directory to the sys path.
sys.path.append( MyWorkspace );

from utils.Path import Path;
Path.SetWorkspace( MyWorkspace );
del MyWorkspace;

from utils.Logger import Logger, LoggerSetLevel, LoggerLevel;
LoggerSetLevel( LoggerLevel.AllLoggers );
g_Logger: Logger = Logger( "Snippet Generator" );

UtilsFolderPath: str = Path.enter( "src", "scripts", "Mikk155" );

SNIPPETS: dict = {
    "summary": {
        "scope": "angelscript",
        "prefix": [ "summary", "<summary>", "snippet", "/**" ],
        "body": '''/**\n<summary>\n\t<return>${1:Return value type}</return>\n\t<body>${2:Body of the method}</body>\n\t<prefix>${3:Prefixes. separate by a coma}</prefix>\n\t<description>${4:Description}</description>\n</summary>\n**/''',
        "description": "Create a comment block that will get formated into user snippets"
    }
}

def Summary( content: str, type: str ) -> str | None:
#
    SummaryStart: int = content.find( f"<{type}>" );

    if SummaryStart == -1:
    #
        g_Logger.warn( "Missing summary <c><{}><>", type );
        return None;
    #

    SummaryEnd: int = content.find( f"</{type}>" );

    if SummaryEnd == -1:
    #
        g_Logger.error( "Missing enclosing summary <c><\{}><> at around <g>{}<>...", type, content[ SummaryStart : max( len(content) + SummaryStart, 20 ) ] );
        return None;
    #

    return content[ SummaryStart + 2 + len(type) : SummaryEnd ];
#

def GenerateSnippetsForFile( file: str ) -> None:

    if not file.endswith(".as"):
    #
        return;
    #

    content: str = None;

    with open( file, "r", encoding="utf-8" ) as f:
    #
        content = f.read();
    #

    if content is None:
    #
        return;
    #

    SumStartIndex = content.find( "<summary>" );

    if SumStartIndex == -1:
    #
        return;
    #

    g_Logger.info( "Generating snippets for <c>{}<>...", os.path.relpath( file, Path.Workspace() ) );

    while SumStartIndex != -1:
    #
        SummaryContent = Summary( content, "summary" );

        if SummaryContent is None:
        #
            break;
        #

        content = content[ content.find( "</summary>", SumStartIndex ) + 10 : ];
        SumStartIndex = content.find( "<summary>" );

        SumaryPrefix = Summary( SummaryContent, "prefix" );

        if SumaryPrefix is None:
        #
            g_Logger.warn( "Missing <c><prefix><> ignoring..." );
            continue;
        #

        SummaryBody = Summary( SummaryContent, "body" );

        if SummaryBody is None:
        #
            g_Logger.warn( "Missing <c><body><> ignoring..." );
            continue;
        #

        SumaryReturn = Summary( SummaryContent, "return" );

        SumaryDescription = Summary( SummaryContent, "description" );

        SumaryPrefixList = [ a.strip( " " ) for a in SumaryPrefix.split( "," ) ]

        SummaryBodyPrefixed = SummaryBody;

        if "(" in SummaryBodyPrefixed and ")" in SummaryBodyPrefixed:
        #
            BodyBefore, InsideMethod = SummaryBodyPrefixed.split( "(", 1 );
            InsideMethod: str = InsideMethod.rsplit( ")", 1 )[0].strip();

            args: list[str] = [ arg.strip() for arg in InsideMethod.split( "," ) ] if InsideMethod else [];

            ArgsPlaceholder: list[str] = [];

            for i, arg in enumerate( args, start=1 ):
            #
                ArgsPlaceholder.append( f"${{{i}:{arg}}}" );
            #

            if len( ArgsPlaceholder ) > 0:
            #
                SummaryBodyPrefixed = f"{BodyBefore}( {', '.join( ArgsPlaceholder )} )"
            #
        #

        filename: str = os.path.basename( file );

        SNIPPETS[ f'{SumaryReturn} {SummaryBody}' if SumaryReturn else SummaryBody ] = {
            "scope": "angelscript",
            "prefix": SumaryPrefixList,
            "body": SummaryBodyPrefixed,
            "description": f'[{filename}] {SumaryDescription}' if SumaryDescription else filename
        }
    #
#

for root, _, files in os.walk( UtilsFolderPath ):
#
    for file in files:
    #
        GenerateSnippetsForFile( os.path.join( root, file ) );
    #
#

with open( Path.enter( ".vscode", "mikk155.code-snippets", SupressWarning=True ), "w", encoding="utf-8" ) as f:
#
    json.dump( SNIPPETS, f, indent=4, ensure_ascii=False );
#
