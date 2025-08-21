#!/bin/bash

# Replace some greys with darker greys
for file in $(find build/patched/ -type f -name "*.scss"); do
  sed -i \
    -e 's/#3d3846/#201f24/g' \
    -e 's/#36363a/#161322/g' \
    -e 's/#222226/#000920/g' \
    "$file"
done
