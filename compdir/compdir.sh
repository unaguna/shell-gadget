#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[-f <path_filter_list>] [-t <target_subdir>] ... [<left_dir> [<right_dir>]]"
    echo "      " `basename $0` "[-f <path_filter_list>] [-t <target_subdir>] ... -L <left_hashlist> [<right_dir>]"
    echo "      " `basename $0` "[-f <path_filter_list>] [-t <target_subdir>] ... -R <right_hashlist> [<left_dir>]"
    echo "      " `basename $0` "-L <left_hashlist> -R <right_hashlist>"
    echo
    echo "Environment Variables:"
    echo "    TAG_LEFT:   比較結果の表示に使用される、左ディレクトリを表す文字列。"
    echo "    TAG_RIGHT:  比較結果の表示に使用される、右ディレクトリを表す文字列。"
    exit $1
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
right_list_tmp=
SHELL_DIR=$(cd $(dirname $0) && pwd)
SHELL_NAME=`basename $0`
TMP_DIR="/tmp"
PATH="$SHELL_DIR:$PATH"

# hashlist 実行時の -f オプション。
# 指定するなら "-f <path_filter_list>" の形にし、指定しないなら空文字列にする。
list_file_option=

# hashlist 実行時の -t オプション。
# 指定するなら "-t" "<target_dir>" の形にし、指定しないなら空の配列にする。
target_dir_option=()

# pathfilter_awk 実行時の -a オプション。
# 指定するなら "-a" "<dir>" の形にし、指定しないなら空の配列にする。
accept_dir_option=()


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    set +e +o pipefail
    
    # 一時ファイルが存在する場合に削除
    rm -f $left_list_tmp $right_list_tmp
}
trap finally EXIT

################################################################################
# 引数解析
################################################################################
declare -i argc=0
declare -a argv=()
number_state=
while (( $# > 0 )); do
    case $1 in
        -)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
        -L)
            LEFT_LIST="$2"
            shift 2
            ;;
        -R)
            RIGHT_LIST="$2"
            shift 2
            ;;
        -f)
            list_file_option="-f $2"
            shift 2
            ;;
        -t)
            target_dir_option+=( "-t" "$2" )
            accept_dir_option+=( "-a" "$2" )
            shift 2
            ;;
        -*)
            usage_exit 1
            ;;
        *)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
    esac
done
exit_code=$?
if [ $exit_code -ne 0 ]; then
    exit $exit_code
fi

################################################################################
# 引数取得
################################################################################

if [ -n "$LEFT_LIST" -a -n "$RIGHT_LIST" ]; then
    left_list=$LEFT_LIST
    right_list=$RIGHT_LIST
elif [ -n "$LEFT_LIST" ]; then
    right_dir=${argv[0]:-"."}

    left_list=$LEFT_LIST
elif [ -n "$RIGHT_LIST" ]; then
    left_dir=${argv[0]:-"."}

    right_list=$RIGHT_LIST
else
    left_dir=${argv[0]:-"."}
    right_dir=${argv[1]:-"."}
fi


# すべてのファイルは次のいずれかに当てはまる。
#   (I). left にのみ存在し、right には存在しない
#   (II). right にのみ存在し、left には存在しない
#   (III). left にも right にも存在するが内容が一致しない
#   (IV). left にも right にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。

readonly left_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.left_list.XXXXXX`
readonly right_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.right_list.XXXXXX`

# left のハッシュリストを作成。
if [ -n "$left_list" ]; then
    # 引数で指定されている場合、そこから target_subdir 以外を取り除く

    if [ ${#accept_dir_option[@]} -ge 1 ]; then
        pathfilter_awk.sh -k 2 "${accept_dir_option[@]}" "$left_list" > "$left_list_tmp"
        left_list=$left_list_tmp
    fi
else
    # 引数で指定されていない場合、新たに作成

    left_list=$left_list_tmp
    hashlist $list_file_option "${target_dir_option[@]}" $left_dir > $left_list
fi

# right のハッシュリストを作成。
if [ -n "$right_list" ]; then
    # 引数で指定されている場合、そこから target_subdir 以外を取り除く

    if [ ${#accept_dir_option[@]} -ge 1 ]; then
        pathfilter_awk.sh -k 2 "${accept_dir_option[@]}" "$right_list" > "$right_list_tmp"
        right_list=$right_list_tmp
    fi
else
    # 引数で指定されていない場合、新たに作成

    right_list=$right_list_tmp
    hashlist $list_file_option "${target_dir_option[@]}" $right_dir > $right_list
fi

# left と right のハッシュリストと比較
comp_hashlist $left_list $right_list
