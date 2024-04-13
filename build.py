import os
import sys
import json
import shutil
import zipfile

# ======= REPACK =======
def repack_resources( file ):

    abs_assets = os.path.join( os.path.dirname( __file__ ), 'assets' )

    if not os.path.exists( abs_assets ):

        os.makedirs( abs_assets )

    abs_file = os.path.join( os.path.dirname( __file__ ), f'resources' )

    with open( f'{abs_file}/{file}.json', 'r' ) as f:

        data = json.load( f )

        if 'Include' in data:

            exas = data.get( 'Include', {} )

            for incl in exas:

                if incl == file:

                    broken( f'{file} is Including itself.')

                repack_resources( incl )

        if not 'Resources' in data and len( data.get( 'Resources', {} ) ) <= 0:

            broken( f'No Assets in "Resources" label in {file}.json.')

        res = data.get( 'Resources', {} )

        for r in res:

            dest = os.path.join( abs_assets, r )

            os.makedirs( os.path.dirname( dest ), exist_ok = True )

            try:

                shutil.copyfile( r, dest )

                print(f"Installing asset \"{r}\"" )

            except Exception as e:

                broken( f"Warning! Couldn't copy {r}: {e}" )

def broken( Str ):

    print( f'{Str}\nExiting!' )

    sys.exit(1)

# ======= MAIN =======
if len(sys.argv) != 2:

    broken( "No proper inputs set.\nUsage: build.py \"file\"\nFile must be a .json format and should exist in resources/ folder." )

file = sys.argv[1]

if not os.path.exists( f'resources/{file}.json' ):

    broken( f"File \"resources/{file}\" does not exists!" )

repack_resources( file )

# ======= ZIP =======
if os.path.exists( 'assets.zip' ):
    os.remove( 'assets.zip' )

with zipfile.ZipFile( 'assets.zip', 'w', zipfile.ZIP_DEFLATED ) as zipf:

    for root, _, files in os.walk( 'assets' ):

        for file in files:

            absp = os.path.join(root, file)

            relp = os.path.relpath( absp, 'assets' )

            zipf.write( absp, relp )