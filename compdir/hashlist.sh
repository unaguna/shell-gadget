#!/bin/bash


function usage_exit () {
    echo "Usage:" `basename $0` "[-f <path_filter_list>] [-t <target_directory>] ... [<root_directory>]"
    exit 1
}


SHELL_DIR=$(cd $(dirname $0) && pwd)
PATH="$SHELL_DIR:$PATH"


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    :
}
trap finally EXIT


################################################################################
# 引数解析
################################################################################
target_dir=()
while getopts f:t:h OPT
do
    case $OPT in
        f)  list_file=$OPTARG
            ;;
        t)  target_dir+=( $OPTARG )
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

shift $((OPTIND - 1))


################################################################################
# 引数取得
################################################################################
root_dir=${1:-"."}
target_dir=${target_dir:-"."}


if [ -n "$list_file" ]; then
    ( cd "$root_dir" && find "${target_dir[@]}" -type f -print0 ) | \
    pathfilter.sh -z -f $list_file | \
    ( cd "$root_dir" && xargs -r -0 sha256sum )
else
    cd "$root_dir" && find "${target_dir[@]}" -type f -print0 | \
    xargs -r0 sha256sum
fi

