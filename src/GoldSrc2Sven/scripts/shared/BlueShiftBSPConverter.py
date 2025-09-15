#-TODO C# auto detect update

def BlueShiftBSPConverter( BSPPath : str ) -> None:
    '''
        Converts a Blue-Shift BSP
    '''

    Lumps: int = 15;

    Version = 0;
    Lump = 1;

    with open( BSPPath, 'rb+' ) as file:

        start: int = file.tell();

        header: list[int] = [ 0, [ [ 0, 0 ] for _ in range( Lumps ) ] ]

        data = file.read( 4 + 8 * Lumps )

        from struct import unpack;
        header[ Version ] = unpack('i', data[:4] )[0]

        for i in range( Lumps ):
            fileofs, filelen = unpack( 'ii', data[ 4 + i * 8:4 + ( i + 1 ) * 8 ] )
            header[ Lump ][i] = [ fileofs, filelen ]

        if header[ Lump ][1][0] == 124:
            file.close() # Already converted, don't swap
            return

        header[ Lump ][0], header[ Lump ][1] = header[ Lump ][1], header[ Lump ][0];

        from os import SEEK_SET;

        file.seek( start, SEEK_SET );

        from struct import pack;

        data: bytes = pack( 'i', header[ Version ] );

        for lump in header[ Lump ]:
            data += pack( 'ii', lump[0], lump[1] );

        file.write( data );
