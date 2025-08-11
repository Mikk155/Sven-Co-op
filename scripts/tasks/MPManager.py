from typing import LiteralString
from tasks.task import Task, Asset;

from utils.Path import Path;
from utils.Logger import Logger;

class Task_Example( Task ):

    logger = Logger( "MPManager" );

    def Run( self, assets: list[Asset] ) -> int:

        PluginManagerFile: str = None;

        for asset in assets:
        #
            Destination: str = asset.Destination;

            if Destination.endswith( "PluginManager.as" ):
            #
                PluginManagerFile = Destination;
            #
        #

        if PluginManagerFile is None:
        #
            self.logger.critical( "Can not find PluginManager.as in the destination directory!" );
            return 1;
        #

        PluginContent: str;

        with open( PluginManagerFile, "r" ) as f:
        #
            PluginContent = f.read();
        #

        DefinitionList: list[str] = [];

        while( PluginContent.find( "#define" ) ) != -1:
        #
            StartIndex: int = PluginContent.find( "#define" ) + 7;
            EndIndex: int = PluginContent.find( "#end" );

            Content: str = PluginContent[ StartIndex : EndIndex ];
            Definition: str = Content[ Content.find( "[" ) + 1 : Content.find( "]" ) ];
            Content: str = Content[ Content.find( "]" ) + 1 : ];
    
            PluginContent = PluginContent[ : StartIndex - 7  ] + PluginContent[ EndIndex + 4 : ];

            DefinitionList.append( ( Definition, Content ) );
        #

        for Definition in DefinitionList:
        #
            while PluginContent.find( f"[{Definition[0]}]" ) != -1:
            #
                DefSize: int = len(f"[{Definition[0]}]");

                StartIndex: int = PluginContent.find( f"[{Definition[0]}]" ) + DefSize;
                EndIndex: int = PluginContent.find( "[end]", StartIndex );
                if PluginContent[ EndIndex - 1 ] == "\n":
                    EndIndex -= 1;
                DefWithDef: str = Definition[1].replace( "<()>", PluginContent[ StartIndex : EndIndex ].strip() );

                last_newline: int = PluginContent.rfind( "\n", 0, StartIndex - DefSize );
                indent_size: int = ( StartIndex - DefSize ) - ( last_newline + 1 );
                indents: str = " " * indent_size

                NewDef: str = '';

                for d in DefWithDef.splitlines():
                #
                    dsp = d.strip();

                    if d == "\n" or dsp == '':
                       continue;

                    NewDef = f'{NewDef}{indents}{d}\n';
                #

                PluginContent =  PluginContent[ : PluginContent.rfind( "\n", 0, StartIndex - DefSize ) + 1 ]  + NewDef + PluginContent[ EndIndex + 5 : ];
            #
        #

        with open( PluginManagerFile, "w" ) as f:
        #
            f.write( PluginContent );
        #

        return 0;

