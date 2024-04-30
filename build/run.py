import os, sys

from movefile import movefile
from broken import broken
from resources import resources
from ListScripts import ListScripts
from zipassets import zipassets
from release import ReleaseTag

if len(sys.argv) != 2:
    broken( "No proper inputs set.\nUsage: build/run.py \"file\"\nFile must be a .json format and should exist in build/resources/ folder." )

file = sys.argv[1]

asbse = os.path.join( os.path.dirname( __file__ ), f'resources/{file}.json' )
if not os.path.exists( asbse ):
    broken( f"File \"resources/{file}\" does not exists!" )

resources( file )

for r in ListScripts():
    movefile( r )

movefile( '.vscode/shared.code-snippets' )

zipassets()

ReleaseTag( file )