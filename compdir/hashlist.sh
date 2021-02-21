#!/bin/bash


function usage_exit () {
    echo "Usage:" `basename $0` "[-f <path_filter_list>] [<directory>]"
    exit 1
}


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
while getopts f:h OPT
do
    case $OPT in
        f)  list_file=$OPTARG
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

base_dir=${1:-"."}


if [ -n "$list_file" ]; then
    ( cd $base_dir && find . -type f -print0 ) | \
    ./pathfilter.sh -z -f $list_file | \
    ( cd $base_dir && xargs -r -0 sha256sum )
else
    cd $base_dir && find . -type f -print0 | \
    xargs -0 sha256sum
fi

