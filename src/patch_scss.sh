#!/bin/bash

while IFS= read -r -d '' file; do
  # Replace some greys with darker greys
  # shellcheck disable=SC2016
  sed -i \
    -e 's/#3d3846/#1f1f1f/g' \
    -e 's/#36363a/#181818/g' \
    -e 's/#222226/#111111/g' \
    -e 's/$window_radius: .*;/$window_radius: 16px;/g' \
    -e 's/$popover_radius: .*;/$popover_radius: 16px;/g' \
    "$file"
done < <(find build/patched/ -type f -name "*.scss" -print0)
