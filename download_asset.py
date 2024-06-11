import sys, requests

if len( sys.argv ) < 3:
    print( f'ERROR! No proper inputs set.\nUsage: python copyrelease.py \"string app name\" \"string download link\" \"string asset name\"\nExiting...' )
    sys.exit(1)

app_name = sys.argv[1]
asset = sys.argv[2]
filename = sys.argv[3]

print( f'Downloading asset "{asset}"' )

with requests.get( asset, stream=True ) as r:
    r.raise_for_status()
    print( f'Saving "{filename}')
    with open( filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)

from upload_asset import upload_asset

upload_asset( app_name, filename )
