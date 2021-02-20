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

SHELL_NAME=`basename $0`
TMP_DIR="/tmp"


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

TAG_BASE=${TAG_BASE:-"base"}
TAG_BASE_EMPTY=`echo $TAG_BASE | sed 's/./-/g'`
TAG_TARGET=${TAG_TARGET:-"target"}
TAG_TARGET_EMPTY=`echo $TAG_TARGET | sed 's/./-/g'`

base_list_tmp=`mktemp $TMP_DIR/$SHELL_NAME.base_list.XXXXXX`
target_list=`mktemp $TMP_DIR/$SHELL_NAME.target_list.XXXXXX`
inter_base_list=`mktemp $TMP_DIR/$SHELL_NAME.inter_base_list.XXXXXX`
inter_target_list=`mktemp $TMP_DIR/$SHELL_NAME.inter_target_list.XXXXXX`


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

# 2つのハッシュリストを加工し、先頭に『存在フラグ』フィールドを付ける。
cat $base_list | awk "{print \"1 \"\$1\" \"\$2}" > $inter_base_list
cat $target_list | awk "{print \"2 \"\$1\" \"\$2}" > $inter_target_list

# 2つのハッシュリストを以下の手順で比較する。
# cat $ $
#   2つのハッシュリストを連結する。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致する
# sort -k 3 | uniq -f1 -u
#   (ハッシュ値, ファイルパス) の組が重複する場合、このファイルは base と target で一致しているので除外する。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 行がない
# awk '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}'
#   SQLでいうところの「SELECT sum(存在フラグ),ファイルパス GROUP BY ファイルパス」
#   これにより、すべての行は次のいずれかに当てはまる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が3の行だけある。
#        (IV). 行がない
# sed -e ...
#   上記の『存在フラグ』を、視認しやすい文字列へ変換する。
cat $inter_base_list $inter_target_list | \
sort -k 3 | uniq -f1 -u | \
awk '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}' | \
sed -e "s/^1/$TAG_BASE -- $TAG_TARGET_EMPTY/" -e "s/^2/$TAG_BASE_EMPTY -- $TAG_TARGET/" -e "s/^3/$TAG_BASE != $TAG_TARGET/"


rm -f $base_list_tmp $target_list $inter_base_list $inter_target_list
