#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[-f <path_filter_list>] [-t <target_subdir>] [<left_dir> [<right_dir>]]"
    echo "      " `basename $0` "-b <left_hashlist> [<right_dir>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_LEFT:   比較結果の表示に使用される、左ディレクトリを表す文字列。"
    echo "    TAG_RIGHT:  比較結果の表示に使用される、右ディレクトリを表す文字列。"
    exit
}

function hashlist () {
    hashlist.sh "$@"
    return $?
}

function comp_hashlist () {
    comp_hashlist.sh "$@"
    return $?
}

left_list_tmp=
SHELL_DIR=$(cd $(dirname $0) && pwd)
SHELL_NAME=`basename $0`
TMP_DIR="/tmp"
PATH="$SHELL_DIR:$PATH"

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
    rm -f $left_list_tmp
}
trap finally EXIT

################################################################################
# 引数解析
################################################################################
while getopts f:b:t:h OPT
do
    case $OPT in
        b)  LEFT_LIST=$OPTARG
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

if [ -n "$LEFT_LIST" ]; then
    right_dir=${1:-"."}

    left_list=$LEFT_LIST
else
    left_dir=${1:-"."}
    right_dir=${2:-"."}
fi


# すべてのファイルは次のいずれかに当てはまる。
#   (I). left にのみ存在し、right には存在しない
#   (II). right にのみ存在し、left には存在しない
#   (III). left にも right にも存在するが内容が一致しない
#   (IV). left にも right にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# left のハッシュリストを作成。ただし、引数でハッシュリストが指定されている場合は作成しない。
if [ -z "$left_list" ]; then
    left_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.left_list.XXXXXX`

    left_list=$left_list_tmp
    hashlist $list_file_option $target_dir_option $left_dir > $left_list
fi

# right のハッシュリストを作成して、left のハッシュリストと比較
hashlist $list_file_option $target_dir_option $right_dir | comp_hashlist $left_list
