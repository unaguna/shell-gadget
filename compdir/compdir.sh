#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[<base_dir> [<target_dir>]]"
    echo "      " `basename $0` "-b <base_hashlist> [<target_dir>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_BASE:   比較結果の表示に使用される、比較元ディレクトリを表す文字列。"
    echo "    TAG_TARGET: 比較結果の表示に使用される、比較対象ディレクトリを表す文字列。"
    exit
}

function hashlist () {
    ./hashlist.sh "$@"
    return $?
}

function comp_hashlist () {
    ./comp_hashlist.sh "$@"
    return $?
}

SHELL_NAME=`basename $0`
TMP_DIR="/tmp"


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    set +e +o pipefail
    
    # 一時ファイルが存在する場合に削除
    rm -f $base_list_tmp $target_list
}
trap finally EXIT

################################################################################
# 引数解析
################################################################################
while getopts b:h OPT
do
    case $OPT in
        b)  BASE_LIST=$OPTARG
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

if [ -n "$BASE_LIST" ]; then
    target_dir=${1:-"."}

    base_list_tmp=
    base_list=$BASE_LIST
else
    base_dir=${1:-"."}
    target_dir=${2:-"."}
fi

base_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.base_list.XXXXXX`
target_list=`mktemp $TMP_DIR/$SHELL_NAME.target_list.XXXXXX`


# すべてのファイルは次のいずれかに当てはまる。
#   (I). base にのみ存在し、target には存在しない
#   (II). target にのみ存在し、base には存在しない
#   (III). base にも target にも存在するが内容が一致しない
#   (IV). base にも target にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# base のハッシュリストを作成。ただし、引数でハッシュリストが指定されている場合は作成しない。
if [ -z "$base_list" ]; then
    base_list=$base_list_tmp
    hashlist $base_dir > $base_list
fi
# target のハッシュリストを作成。
hashlist $target_dir > $target_list


comp_hashlist $base_list $target_list
