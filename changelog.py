import os
import sys
import json
import requests

owner = 'Mikk155'

repo = 'test-github-actions'

token = os.getenv( 'TOKEN' )
webhook_url = os.getenv( 'WEBHOOK' )

headers = {
    'Authorization': f'token {token}',
    'Accept': 'application/vnd.github.v3+json'
}

file = sys.argv[1]

url = f'https://api.github.com/repos/{owner}/{repo}/releases/tags/{file}'

if file:
    response = requests.get(url, headers=headers)

    if response.status_code == 200:

        changelog = os.path.join( os.path.dirname( __file__ ), 'changelog' )

        markdown_content = ''

        if os.path.exists( f'{changelog}/{file}.md' ):

            with open( f'{changelog}/{file}.md', 'r', encoding='utf-8') as f:

                markdown_content = f.read()

        if markdown_content and markdown_content != '':

            release_id = response.json()['id']

            url = f'https://api.github.com/repos/{owner}/{repo}/releases/{release_id}'

            response = requests.patch(url, json={ 'body': markdown_content }, headers=headers)

            # Don't send the whole thing to discord >:|
            split = markdown_content.split( '---' )

            if split and len(split) > 1:
                data = {'content': split[0]}
                headers = {'Content-Type': 'application/json'}
                response_discord = requests.post(webhook_url, data=json.dumps(data), headers=headers)
