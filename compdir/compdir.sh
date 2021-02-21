#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[-f <path_filter_list>] [-t <target_subdir>] [<base_dir> [<clone_dir>]]"
    echo "      " `basename $0` "-b <base_hashlist> [<clone_dir>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_BASE:   比較結果の表示に使用される、比較元ディレクトリを表す文字列。"
    echo "    TAG_CLONE:  比較結果の表示に使用される、比較対象ディレクトリを表す文字列。"
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

base_list_tmp=
SHELL_NAME=`basename $0`
TMP_DIR="/tmp"

# hashlist 実行時の -f オプション。
# 指定するなら "-f <path_filter_list>" の形にし、指定しないなら空文字列にする。
list_file_option=

# hashlist 実行時の -t オプション。
# 指定するなら "-t <target_dir>" の形にし、指定しないなら空文字列にする。
target_dir_option=


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    set +e +o pipefail
    
    # 一時ファイルが存在する場合に削除
    rm -f $base_list_tmp
}
trap finally EXIT

################################################################################
# 引数解析
################################################################################
while getopts f:b:t:h OPT
do
    case $OPT in
        b)  BASE_LIST=$OPTARG
            ;;
        f)  list_file_option="-f $OPTARG"
            ;;
        t)  target_dir_option="-t $OPTARG"
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
    clone_dir=${1:-"."}

    base_list=$BASE_LIST
else
    base_dir=${1:-"."}
    clone_dir=${2:-"."}
fi


# すべてのファイルは次のいずれかに当てはまる。
#   (I). base にのみ存在し、clone には存在しない
#   (II). clone にのみ存在し、base には存在しない
#   (III). base にも clone にも存在するが内容が一致しない
#   (IV). base にも clone にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# base のハッシュリストを作成。ただし、引数でハッシュリストが指定されている場合は作成しない。
if [ -z "$base_list" ]; then
    base_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.base_list.XXXXXX`

    base_list=$base_list_tmp
    hashlist $list_file_option $target_dir_option $base_dir > $base_list
fi

# clone のハッシュリストを作成して、base のハッシュリストと比較
hashlist $list_file_option $target_dir_option $clone_dir | comp_hashlist $base_list
