import os
from github import Github

def upload_asset( tag_name, filename ):
    token = os.getenv("TOKEN")

    g = Github(token)

    user = 'Mikk155'
    repository = 'Sven-Co-op'
    repom = g.get_repo( f'{user}/{repository}')

    releases = repom.get_releases()
    release = None

    for r in releases:
        if r.tag_name == tag_name:
            release = r
            file_path = os.path.join( os.path.dirname( __file__ ), filename )
            release.upload_asset(file_path, label=filename)
            print( f'Uploaded dependancy "{filename}" to "{tag_name}"')
            break
