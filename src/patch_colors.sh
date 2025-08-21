#!/bin/bash

# Replace some greys with darker greys
for file in $(find build/patched/ -type f -name "*.scss"); do
  sed -i \
    -e 's/#3d3846/#1f1f1f/g' \
    -e 's/#36363a/#181818/g' \
    -e 's/#222226/#111111/g' \
    "$file"
done
