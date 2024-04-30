import os

def ListScripts():
    for ruta, directorios, archivos in os.walk( 'scripts\mikk' ):
        for nombre_archivo in archivos:
            ruta_completa = os.path.join(ruta, nombre_archivo)
            yield ruta_completa

def CreateSnippets():

    vsfolder = os.path.join( os.path.dirname(__file__), '.vscode/' )

    if not os.path.exists(vsfolder):
        os.makedirs(vsfolder)

    with open( f'{vsfolder}/shared.code-snippets', 'w') as snippet:

        snippet.write( '{\n' )

        FirstEntry = True

        allfiles = list(ListScripts())
        allfiles.append( 'src\\aslp\\aslp.cpp' )

        for archivo in allfiles:

            Script = os.path.join( os.path.dirname(__file__), archivo )
            with open( f'{Script}', 'r') as a:

                lines = a.readlines()

                type = ''
                body = ''
                prefix = ''
                function = ''
                description = ''
                InComment = False
                CatchFunction = False

                for line in lines:

                    line = line.strip( ' ' )
                    if line.endswith( '\n' ):
                        line = line[0:line.rindex('\n') ]
                    line = line.replace( '"', '\\"' )

                    if not line or line == '':
                        continue
                    if line == '/*':
                        InComment = True
                    elif line == '*/':
                        CatchFunction = True
                        InComment = False
                    elif InComment:
                        if line.startswith( '@prefix' ):
                            pr = line[ len('@prefix ') : ]
                            pr = pr.replace( ' ', '", "' )
                            if prefix != '':
                                prefix = f'{prefix}\\n{pr}'
                            else:
                                prefix = f'{pr}'
                        elif line.startswith( '@body' ):
                            body = line[ len('@body ') : ]
                        elif line.startswith( '@description' ):
                            pr = line[ len('@description ') : ]
                            if description != '':
                                description = f'{description}\\n{pr}'
                            else:
                                description = f'{pr}'
                    elif CatchFunction and description and prefix and body:
                        type = line[ 0 : line.find( ' ', 0 ) ]
                        line = line[ line.find( ' ', 0 ) + 1 :]

                        if type in [ 'const', 'private', 'protected' ]:
                            sz = line[ 0 : line.find( ' ', 0 ) ]
                            type = f'{type} {sz}'
                            line = line[ line.find( ' ', 0 ) + 1 :]

                        function = line

                        if not FirstEntry:
                            snippet.write( ',\n' )
                        FirstEntry = False

                        if body.find( '(' ) != -1 and body.find( ')' ) != -1:
                            fn = body[ 0 : body.find( '(' ) ]
                            fnargs = body[ body.find( '(' ) + 1: ]
                            if fnargs.find( ')' ) != -1:
                                fnargs = fnargs[ 0 : fnargs.rindex( ')' ) ]
                            doargs = fnargs.split( ',' )
                            forallargs = ''
                            if len(doargs) > 0:
                                eindex = 1
                                for dargs in doargs:
                                    dargs = dargs.strip()
                                    if not dargs or dargs == '':
                                        continue
                                    dargs = '${' + f'{eindex}:{dargs}' + '}'
                                    if eindex > 1:
                                        forallargs = f'{forallargs}, {dargs}'
                                    else:
                                        forallargs = dargs
                                    eindex = eindex + 1

                            if forallargs and forallargs != '':
                                body = f'{fn}( {forallargs} )'
                            else:
                                body = f'{fn}()'

                        lib = archivo[ archivo.rfind( '\\' ) + 1 : ]
                        snippet.write( f'\t"{type} {function}":\n' )
                        snippet.write( '\t{\n' )
                        snippet.write( f'\t\t"prefix": [ "{prefix}" ],\n' )
                        snippet.write( f'\t\t"body": "{body}",\n' )
                        snippet.write( f'\t\t"description": "({lib}) {description}"\n' )
                        snippet.write( '\t}' )

                        type = ''
                        body = ''
                        prefix = ''
                        function = ''
                        description = ''
                        InComment = False
                        CatchFunction = False
                a.close()
        snippet.write( '\n}\n' )
        snippet.close()
CreateSnippets()
