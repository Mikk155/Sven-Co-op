import os
from github import Github, GithubException
from broken import broken

access_token = os.getenv( "TOKEN" )

if not access_token or access_token == '':

    broken('No github token were provided!')

g = Github(access_token)

user = 'Mikk155'

repository = 'Sven-Co-op'

repo = g.get_repo( f'{user}/{repository}')

def ReleaseTag( file ):

    tag_name = file

    try:

        release = repo.create_git_release(tag_name, tag_name, f"# {tag_name}" )

        new_body = ""

        changelog = os.path.join( os.path.dirname(__file__), f'../changelog/{file}.md' )

        if os.path.exists( changelog ):

            with open( changelog, 'r') as cl:

                for line in cl.readlines():

                    new_body = f'{new_body}{line}'

                cl.close()

        if new_body:
            release.update_release(release.title, new_body)

        file_name = 'assets.zip'

        file_path = os.path.join( os.path.dirname( __file__ ), 'assets.zip' )

        release.upload_asset(file_path, label=file_name)

        print(f'Updated release for "{tag_name}"')

    except GithubException as e:

        if e.status == 422:

            print(f'Release with tag "{tag_name}" already exists. updating..')

        releases = repo.get_releases()

        release = None

        for r in releases:

            if r.tag_name == tag_name:

                release = r

                break

        if release:

            release.delete_release()

            ReleaseTag( tag_name )

        else:

            broken(f'Can not find the release "{tag_name}"')
