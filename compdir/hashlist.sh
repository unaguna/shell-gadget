#!/bin/bash

base_dir=${1:-"."}

cd $base_dir && \
find . -type f -print0 | xargs -0 sha256sum

exit $?
