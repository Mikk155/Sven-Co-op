import os, json
from broken import broken
from movefile import movefile

def resources( file ):

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

                resources( incl )

        if not 'Resources' in data or len( data.get( 'Resources', {} ) ) <= 0:

            broken( f'No Assets in "Resources" label in {file}.json.')

        res = data.get( 'Resources', {} )

        for r in res:

            movefile( r )