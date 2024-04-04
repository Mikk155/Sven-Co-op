#!/usr/bin/env python3
import os
import sys

def main():
    if len( sys.argv ) != 2:
        print("Usage: {} <file.res>".format(sys.argv[0]))
        sys.exit(1)

    res_file = sys.argv[1]

    if not os.path.isfile(res_file):
        print("¡Warning {} not exists".format(res_file))
        sys.exit(1)

    temp_dir = "dependencies"
    os.makedirs(temp_dir, exist_ok=True)

    dependencies = []
    with open(res_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            dependency = line.replace( '"', '' )
            dependency = dependency.replace( '\n', '' )
            dependencies.append(dependency)

    Path = os.path.join(os.path.dirname(__file__) )

    for dependency in dependencies:
        print( f'{dependency}\n')
        if os.path.exists( f'{Path}/{dependency}' ):
            os.system("cp {} {}".format(dependency, temp_dir))
        else:
            print( f"Warning: {Path}/{dependency} no exists!" )

    print("All done.")

if __name__ == "__main__":
    main()
