# This script has been made for reading sentences and paste these in the docs
# i know i could have used javascript directly on the html but i don't know js :p

import os
import json

# Languages for webpages
Languages = [
    'en',
    'es'
]

# Replace key with a link to the value
href = {
    # Users
    "Zode": "https://github.com/Zode",
    "hzqst": "https://github.com/hzqst",
    "Mikk": "https://github.com/mikk155",
    "Rick": "https://github.com/RedSprend",
    "Wootguy": "https://github.com/wootguy",
    "Giegue": "https://github.com/JulianR0",
    "CubeMath": "https://github.com/CubeMath",
    "Kezaeiv": "https://github.com/KEZAEIV3255",
    "Kerncore": "https://github.com/KernCore91",
    "Gaftherman": "https://github.com/Gaftherman",
    "Rizulix": "https://github.com/Rizulix",

    # Extern links
    "Discord": "https://discord.gg/sqK7F3kZfn",
    "metamod": "https://github.com/Mikk155/metamod-limitless-potential",
    "snippets": "https://github.com/Mikk155/Sven-Co-op/blob/main/.vscode/shared.code-snippets",
}

# read the sentences.json and the config files then after swap json's key to json's values paste into an html file
def EncodeHTML( js, path, lang ):

    with open( path, 'r') as fr:

        lines = fr.readlines()

        for i, line in enumerate( lines ):

            for key, value in js.items():

                if not isinstance( value, dict ):
                    continue

                nmMessage = str(value.get( lang ))

                for k, v in href.items():

                    if nmMessage.find( k ) != -1:
                        nmMessage = nmMessage.replace( k, f'<a href="{v}" target="_blank" class="link-extern">{k}</a>' )

                while lines[i].find( f'#{key}#' ) != -1:

                    lines[i] = lines[i].replace( f'#{key}#', nmMessage )

    return lines

# Open all src/website/*.config
def FindJsonFiles():

    jsonpath = os.path.join( 'src/website/', 'sentences.json' )

    with open( jsonpath, 'r') as file:

        try:
            js = json.load( file )

            for key in Languages:

                for dirpath, _, filenames in os.walk( f'src\website' ):

                    for filename in filenames:

                        if filename.endswith('.config'):

                            HTML = os.path.join( f'docs\\{key}' + dirpath.replace( 'src\\website', '' ), filename.replace( '.config', '.html' ) )
                            with open( HTML, 'w') as fw:

                                lines = EncodeHTML( js, os.path.join( dirpath, filename ), key )

                                fw.writelines( lines )

        except json.JSONDecodeError as e:

            print(f"Error decoding JSON at {jsonpath}: {e}")

FindJsonFiles()
