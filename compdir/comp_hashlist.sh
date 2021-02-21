#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "<base_hashlist> [<target_hashlist>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_BASE:   比較結果の表示に使用される、比較元ディレクトリを表す文字列。"
    echo "    TAG_TARGET: 比較結果の表示に使用される、比較対象ディレクトリを表す文字列。"
    exit
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
    rm -f $inter_hashlist
}
trap finally EXIT

################################################################################
# 引数取得
################################################################################

if [ $# -le 0 -o $# -ge 3 ]; then
    usage_exit
fi

base_list=$1
target_list=${2:-"-"}

TAG_BASE=${TAG_BASE:-"base"}
TAG_BASE_EMPTY=`echo $TAG_BASE | sed 's/./-/g'`
TAG_TARGET=${TAG_TARGET:-"target"}
TAG_TARGET_EMPTY=`echo $TAG_TARGET | sed 's/./-/g'`

inter_hashlist=`mktemp $TMP_DIR/$SHELL_NAME.inter_hashlist.XXXXXX`


# すべてのファイルは次のいずれかに当てはまる。
#   (I). base にのみ存在し、target には存在しない
#   (II). target にのみ存在し、base には存在しない
#   (III). base にも target にも存在するが内容が一致しない
#   (IV). base にも target にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# 2つのハッシュリストを加工し結合。
# 先頭に『存在フラグ』フィールドを付ける。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致する
cat $base_list | awk "{print \"1 \"\$1\" \"\$2}" > $inter_hashlist
cat $target_list | awk "{print \"2 \"\$1\" \"\$2}" >> $inter_hashlist


# inter_hashlist を以下の手順で加工することで、2つのハッシュリストを比較する。
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
sort -k 3 $inter_hashlist | uniq -f1 -u | \
awk '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}' | \
sed -e "s/^1/$TAG_BASE -- $TAG_TARGET_EMPTY/" -e "s/^2/$TAG_BASE_EMPTY -- $TAG_TARGET/" -e "s/^3/$TAG_BASE != $TAG_TARGET/"
