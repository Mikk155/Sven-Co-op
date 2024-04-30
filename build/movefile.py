import os, shutil
from broken import broken

def movefile( r ):

    dest = os.path.join( os.path.join( os.path.dirname( __file__ ), 'assets' ), r )

    os.makedirs( os.path.dirname( dest ), exist_ok = True )

    try:

        shutil.copyfile( r, dest )

        print(f"Installing asset \"{r}\"" )

    except Exception as e:

        broken( f"Warning! Couldn't copy {r}: {e}" )
