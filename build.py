import os, sys, shutil, zipfile
from github import Github, GithubException

#=========================================================#
#============= Something went wrong, notice ==============#
#=========================================================#
def broken ( message ):
    print( f'ERROR! {message}\nExiting...' )
    sys.exit(1)

#=========================================================#
#======================= Debuggin ========================#
#=========================================================#
def verb ( message ):
    if VERBOSE:
        print( f'{message}' )

#=========================================================#
#======= Read assets enlisted in the resource file =======#
#=========================================================#
def ListenResources( PathFile, ResourceFile ):
    with open( ResourceFile, 'r' ) as res:

        verb( f'Decoding {PathFile}.res ({ResourceFile})')

        lines = res.readlines()

        CurrentPath = ""

        for line in lines:

            line = line[ line.find( '"', 0 ) + 1 : line.rfind( '"' ) ]

            if line.find( '" "' ) != -1:
                split  = line.split( '" "' )

                if split[0] == 'path':
                    verb( f'Adjusted destination path {split[1]}' )
                    CurrentPath = split[1]
            else:
                movefile( line, CurrentPath )

#=========================================================#
#==== Move the specified file to the given destination ===#
#=========================================================#
def movefile( AssetFile, DestinationPath ):

    filename = AssetFile
    AssetFile = AssetFile.replace( '/', '\\' )
    abssolute_asset = os.path.join( os.path.dirname( __file__ ), f'src\{AssetFile}' )

    if filename.rfind( '/' ) != -1:
        filename = filename[ filename.rfind( '/' ) + 1: ]

    if not filename:
        return

    DestinationPath = DestinationPath.replace( '/', '\\' )

    destination_folder = os.path.join( os.path.dirname( __file__ ), f'{DestinationPath}' )
    destination_asset = os.path.join( os.path.dirname( __file__ ), f'{DestinationPath}{filename}' )

    if not os.path.exists( destination_folder ):
        os.makedirs( os.path.dirname( destination_folder ), exist_ok = True )

    try:
        shutil.copyfile( abssolute_asset, destination_asset )
        verb(f"Installing asset \"{DestinationPath}{filename}\"" )
        gpDestinations[ f'{DestinationPath}{filename}' ] = destination_asset
    except Exception as e:
        broken( f"Warning! Couldn't copy {DestinationPath}{filename}\n{e}" )

#=========================================================#
#==================== Zip all assets =====================#
#=========================================================#

def zipassets():

    AssetsSource = os.path.join( os.path.dirname( __file__ ), 'svencoop.zip' )

    if os.path.exists( AssetsSource ):
        os.remove( AssetsSource )

    with zipfile.ZipFile( AssetsSource, 'w', zipfile.ZIP_DEFLATED ) as zipf:
        for Asset, Destination in gpDestinations.items():
            if RELEASE:
                WriteLicence(Destination)
            zipf.write( Destination, Asset )
            verb( f'Compressing {Asset}')

#=========================================================#
#===================== Stamp license =====================#
#=========================================================#
def WriteLicence( File ):
    if File.endswith( '.as' ):
        with open( File, 'r+') as f, open( os.path.join( os.path.dirname( __file__ ), 'header.ini' ), 'r') as l:
            lines = f.readlines()
            f.seek(0)
            lines.insert( 0, '\n' )
            for h in reversed(l.readlines()):
                lines.insert( 0, h )
            f.writelines(lines)

#=========================================================#
#========= Clear directories on virtual machine ==========#
#=========================================================#
def RemoveAssets():
    for Asset, Destination in gpDestinations.items():
        if os.path.exists( Destination ):
            verb( f'Clearing {Asset}')
            os.remove( Destination )

#=========================================================#
#=========== Generate release for application ============#
#=========================================================#
def GenerateRelease( appname ):

    access_token = os.getenv( "TOKEN" )

    if not access_token or access_token == '':
        broken('No github token were provided!')

    RemoveAssets()

    g = Github(access_token)

    user = 'Mikk155'
    repository = 'Sven-Co-op'
    repo = g.get_repo( f'{user}/{repository}')

    tag_name = appname

    try:
        release = repo.create_git_release(tag_name, tag_name, f"# {tag_name}" )
        new_body = ""

        changelog = os.path.join( os.path.dirname(__file__), f'src/{appname}/changelog.md' )
        if os.path.exists( changelog ):
            with open( changelog, 'r') as cl:
                verb( f'Reading changelog for release body')
                for line in cl.readlines():
                    new_body = f'{new_body}{line}'
                cl.close()

        if new_body:
            release.update_release(release.title, new_body)

        file_name = 'svencoop.zip'
        file_path = os.path.join( os.path.dirname( __file__ ), 'svencoop.zip' )
        release.upload_asset(file_path, label=file_name)
        verb( f'Generated release for "{tag_name}"')

    except GithubException as e:
        if e.status == 422:
            verb(f'Release with tag "{tag_name}" already exists. updating..')
        releases = repo.get_releases()
        release = None
        for r in releases:
            if r.tag_name == tag_name:
                release = r
                break
        if release:
            release.delete_release()
            GenerateRelease( tag_name )
        else:
            broken(f'Can not find the release "{tag_name}"')

#=========================================================#
#===== Start the program, build projects and repack ======#
#=========================================================#
VERBOSE = False
RELEASE = False
gpDestinations = {}

if len( sys.argv ) < 2:
    broken( "No proper inputs set.\nUsage: python build.py \"string app name\" \"bool verbose = True\" \"bool release = True\"" )
if len( sys.argv ) > 1:
    ResName = sys.argv[1]
if len( sys.argv ) > 2 and sys.argv[2] == 'true':
    VERBOSE = True
if len( sys.argv ) > 3 and sys.argv[3] == 'true':
    RELEASE = True

AbsPathRes = os.path.join( os.path.dirname( __file__ ), f'src\{ResName}\{ResName}.res' )
if not os.path.exists( AbsPathRes ) and ResName != 'bot':
    broken( f"File \"src/{ResName}/{ResName}.res\" does not exists!" )

CCHangelogFile = os.path.join( os.path.dirname(__file__), f'src\{ResName}\changelog.md' )

from bot import InitBot

if ResName == 'bot':
    InitBot()
else:
    ListenResources( ResName, AbsPathRes )

if RELEASE:
    zipassets()
    GenerateRelease( ResName )
    InitBot()

# python build.py assetname true true < release
# python build.py bot < send BOT.md