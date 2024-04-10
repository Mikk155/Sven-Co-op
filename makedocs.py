# This script has been made for reading sentences and paste these in the docs
# i know i could have used javascript directly on the html but i don't know js :p

import os
import json

# Replace key with a link to the value
href = {
    # Users
    "Zode": "https://github.com/Zode",
    "hzqst": "https://github.com/hzqst",
    "Mikk": "https://github.com/mikk155",
    "Rick": "https://github.com/RedSprend",
    "Wootguy": "https://github.com/wootguy",
    "Giegue": "https://github.com/JulianR0",
    "Cubemath": "https://github.com/CubeMath",
    "Kezaeiv": "https://github.com/KEZAEIV3255",
    "Kerncore": "https://github.com/KernCore91",
    "Gaftherman": "https://github.com/Gaftherman",

    # Extern links
    "Discord": "https://discord.gg/sqK7F3kZfn",
    "metamod": "https://github.com/Mikk155/metamod-limitless-potential",
    "snippets": "https://github.com/Mikk155/Sven-Co-op/blob/main/.vscode/shared.code-snippets",
}

# read the sentences.json and the config files then after swap json's key to json's values paste into an html file
def EncodeHTML( js, path ):

    with open( path, 'r') as fr:

        lines = fr.readlines()

        IsJson = False
        JsonInString = False
        LastChar = ''
        AllChars = ''
        Enclose = ''
        DigitType = ''
        IsBoolean = False
        IsValue = False

        for i, line in enumerate( lines ):

            for key, value in js.items():

                if not isinstance( value, str ):
                    continue

                # This may be really stupid but i don't know javascript
                # But hey, i know phyton. so let's do this stupidity :D
                if line.find( '<pre class="json">' ) != -1:
                    IsJson = True
                elif IsJson:
                    if line.find( '</pre>' ) != -1:
                        lines[i] = line
                        IsJson = False
                        continue
                    iSpaces = 0
                    while line.startswith( ' ' ):
                        iSpaces += 1
                        line = line[1:]
                    while iSpaces > 0:
                        iSpaces -= 1
                        line = f'&nbsp;{line}'
                    for c in line:
                        if c == '"' and LastChar != '\\':
                            if JsonInString:
                                Enclose = '</a>'
                                JsonInString = False
                            else:
                                AllChars += f'<a class="json-string">'
                                JsonInString = True
                        elif not JsonInString:
                            if not DigitType and c.isdigit():
                                DigitType = 'integer'
                                AllChars += f'<a class="json-#DIGITTYPE#">'
                            elif DigitType and c == '.':
                                DigitType = 'float'
                            elif IsBoolean:
                                if c == 'e':
                                    IsBoolean = False
                                    AllChars += '</a>'
                                continue
                            elif IsValue and c in ['t','f']:
                                Type = 'true'
                                if c== 'f':
                                    Type = 'false'
                                AllChars += f'<a class="json-{Type}">{Type}'
                                IsBoolean = True
                                continue
                            if c in [ "{", "}", ",", "[", "]", ":" ]:
                                if c == ":":
                                    IsValue = True
                                if DigitType:
                                    AllChars += '</a>'
                                    AllChars = AllChars.replace( '#DIGITTYPE#', DigitType )
                                    DigitType = ''
                                AllChars += f'<a class="json-tokens">'
                                Enclose = '</a>'
                        LastChar = c
                        AllChars += c
                        if Enclose:
                            AllChars += Enclose
                            Enclose = ''
                    lines[i] = AllChars
                    AllChars = ''
                    LastChar = ''
                    IsValue = False
                    IsBoolean = False
                    continue

                for k, v in href.items():

                    if value.find( k ) != -1:

                        value = value.replace( k, f'<a href="{v}" target="_blank" class="link-extern">{k}</a>' )

                if line.find( f'#{key}#' ) != -1:

                    lines[i] = line.replace( f'#{key}#', value )


    if lines:

        with open( path.replace( 'config', 'html' ), 'w') as fw:

            fw.writelines( lines )


# Open all docs/*.config
def FindJsonFiles():

    jsonpath = os.path.join( 'docs/', 'sentences.json' )

    with open( jsonpath, 'r') as file:

        try:
            js = json.load( file )

            for key, value in js.items():

                if not isinstance( value, dict ):
                    continue

                jsLang = js.get( key, {} )

                for dirpath, _, filenames in os.walk( f'docs\{key}' ):

                    for filename in filenames:

                        if filename.endswith('.config'):

                            EncodeHTML( jsLang, os.path.join( dirpath, filename ) )

        except json.JSONDecodeError as e:

            print(f"Error decoding JSON at {jsonpath}: {e}")

FindJsonFiles()
