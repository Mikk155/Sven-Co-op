import requests, os, sys
from github import Github

RELEASE = False

if len( sys.argv ) < 4:
    print( f'ERROR! No proper inputs set.\nUsage: python copyrelease.py \"string app name\" \"string owner name\" \"string repository name\" \"bool release = True\"\nExiting...' )
    sys.exit(1)

if len( sys.argv ) > 4 and sys.argv[4] == 'true':
    RELEASE = True

app_name = sys.argv[1]
repo = f'{sys.argv[2]}/{sys.argv[3]}'

token = os.getenv("TOKEN")

headers = {
    "Authorization": f"token {token}",
    "Accept": "application/vnd.github.v3+json"
}

print(f'Pullin {repo}')

response = requests.get(f"https://api.github.com/repos/{repo}/releases/latest", headers=headers )

release = response.json()

asset_url = release['assets'][0]['browser_download_url']
AssetName = release['assets'][0]['name']

print(f'Downloading asset "{AssetName}"')

asset_response = requests.get(asset_url, headers=headers)

with open( AssetName, 'wb') as file:
    file.write(asset_response.content)

from upload_asset import upload_asset

if RELEASE:
    upload_asset( app_name, AssetName )
