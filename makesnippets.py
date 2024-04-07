import os

def CreateSnippets():

    vsfolder = os.path.join( os.path.dirname(__file__), '.vscode/' )

    if not os.path.exists(vsfolder):

        os.makedirs(vsfolder)

    res_file = os.path.join( os.path.dirname(__file__), 'resources/shared.res' )

    with open(res_file, 'r') as f, open( f'{vsfolder}/shared.code-snippets', 'w') as snippet:

        Quote = ''

        snippet.write( '{\n' )

        for line in f:

            file_path = line.strip().strip('"')

            asDst = os.path.join( os.path.dirname(__file__), file_path )

            with open( asDst, 'r' ) as a:

                lines = a.readlines()

                InComment = False
                IsEnum = ''
                EnumValue = 0
                ShouldCopyFunction = False

                prefix = ''
                body = ''
                description = ''

                for line in lines:

                    line = line.strip()

                    if IsEnum != '':

                        if line == '{':
                            continue
                        elif line == '}':
                            IsEnum = ''
                            EnumValue = 0
                            continue
                        elif( line.startswith( '/*' ) ):
                            InComment = True
                            continue
                        elif( line.startswith( '*/' ) ):
                            InComment = False
                            ShouldCopyFunction = True
                            continue

                        if ShouldCopyFunction:

                            line = line.replace( ' ', '' )
                            for i in line.split( ',' ):

                                if '=' in i:
                                    v = i.split( '=' )
                                    EnumValue = int( v[1] )
                                    i = v[0]

                                if i == '':
                                    continue

                                snippet.write( f'{Quote}\t"enum {IsEnum}::{i}":\n' )
                                snippet.write( '\t{\n' )
                                snippet.write( f'\t\t"prefix": [ "{i}", "{IsEnum}::{i}" ],\n' )
                                snippet.write( f'\t\t"body": "{IsEnum}::{i}",\n' )
                                snippet.write( f'\t\t"description": "{description}",\n' )
                                snippet.write( '\t}' )
                            EnumValue = EnumValue + 1
                            ShouldCopyFunction = False

                    elif( ShouldCopyFunction ):
                        snippet.write( f'{Quote}\t"{line}":\n' )
                        snippet.write( '\t{\n' )
                        snippet.write( f'\t\t"prefix":[ "{prefix}" ],\n' )

                        function = line[ line.find ( " " ) + 1:]
                        body = body.strip( ' ' )

                        Dot = '.'

                        if line.startswith( 'namespace' ):
                            Dot = '::'

                        if not "(" in function:

                            snippet.write( f'\t\t"body": "' )

                            if body != '':
                                snippet.write( f'{body}{Dot}' )
                            snippet.write( f'{function}",\n' )

                        else:

                            Arguments = function[ function.find( '(' ) + 1 : function.find( ')' ) - 1 ]

                            function = function[ : function.find( '(' ) ]

                            dArgs = ''
                            dListArgs = Arguments.split( ',' )

                            snippet.write( f'\t\t"body": "' )

                            if body != '':
                                snippet.write( f'{body}{Dot}' )

                            snippet.write( f'{function}(' )

                            for i, Args in enumerate( dListArgs ):

                                if not Args:
                                    continue

                                if Args.startswith( ' ' ):
                                    Args = Args[1:]

                                Args = Args.strip()

                                s = f'${{{i + 1}:{Args}}}'

                                if i < len( dListArgs ) - 1:
                                    s += ','

                                snippet.write( f' {s}' )

                            snippet.write( f')",\n' )

                        snippet.write( f'\t\t"description": "{description}"\n' )

                        line = ''
                        body = ''
                        prefix = ''
                        Quote = ',\n'
                        description = ''
                        snippet.write( '\t}' )
                        ShouldCopyFunction = False

                    if line.startswith( 'enum' ):
                        IsEnum = line[ line.find( ' ' ) + 1 : ]
                    elif( line.startswith( '@prefix' ) ):
                        prefix = line.strip( '@prefix' )
                        prefix = prefix.strip()
                        prefix = prefix.replace( ' ', '", "' )
                    elif( line.startswith( '@body' ) ):
                        body = line.strip( '@body' )
                    elif( line.startswith( '/*' ) ):
                        InComment = True
                    elif( line.startswith( '*/' ) ):
                        InComment = False
                        ShouldCopyFunction = True
                    elif InComment:
                        line = line.replace( '"', '\\"' )
                        if description != '':
                            description = f'{description} {line}'
                        else:
                            description = line

                a.close()

        f.close()
        snippet.write( '\n}\n' )
        snippet.close()

if __name__ == "__main__":

    CreateSnippets()