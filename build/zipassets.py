import os, zipfile

def zipassets():

    AssetsSource = os.path.join( os.path.dirname( __file__ ), 'assets.zip' )

    if os.path.exists( AssetsSource ):
        os.remove( AssetsSource )

    with zipfile.ZipFile( AssetsSource, 'w', zipfile.ZIP_DEFLATED ) as zipf:

        for root, _, files in os.walk( 'build/assets' ):

            for file in files:

                absp = os.path.join(root, file)

                relp = os.path.relpath( absp, 'build/assets' )

                zipf.write( absp, relp )
                dbg = relp[ relp.rfind( '\\' ) + 1 : ]
                print( f'Compressing {dbg}')