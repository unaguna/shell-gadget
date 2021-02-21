#!/bin/bash

set -e -o pipefail

sed -e 's/#.*$//' -e '/^$/d' $1 | awk 1
