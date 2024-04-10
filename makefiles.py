# This script has been made for github workflows to take certain scripts the from the source code
# and create an artifact from the resource file at resources/
# This is automatially used for github, you dont need this in your game server.

import os
import sys
import shutil

def RepackResources( res_file ):

    dependencies_dir = os.path.join(os.path.dirname(__file__), 'dependencies')

    if not os.path.exists(dependencies_dir):

        os.makedirs(dependencies_dir)

    with open(res_file, 'r') as f:

        for line in f:

            file_path = line.strip().strip('"')

            destination_path = os.path.join(dependencies_dir, file_path)

            os.makedirs(os.path.dirname(destination_path), exist_ok=True)

            if destination_path.endswith( '.res' ):

                RepackResources( f"resources/{file_path}" )

                continue

            try:

                shutil.copyfile(file_path, destination_path)

                print(f"{file_path}")

            except Exception as e:

                print(f"Warning! couldn't copy {file_path}: {e}")

if __name__ == "__main__":

    if len( sys.argv ) != 2:

        sys.exit(1)

    res_file = sys.argv[1]

    if not os.path.exists(res_file):

        print(f"Warning: File {res_file} not found!")
    else:
        RepackResources( res_file )