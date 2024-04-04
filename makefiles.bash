#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file.res>"
    exit 1
fi

res_file="$1"

if [ ! -f "$res_file" ]; then
    echo "¡Warning $res_file not found"
    exit 1
fi

temp_dir=$(mktemp -d)

dependencies=$(grep -E '^"[^"]*"' "$res_file" | sed 's/"//g')

echo "$dependencies"

for dependency in $dependencies; do
    if [ -f "$dependency" ]; then
        cp "$dependency" "$temp_dir"
    else
        echo "¡Warning: $dependency not found!"
    fi
done

mv "$temp_dir" dependencies

echo "Done."
