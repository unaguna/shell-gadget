#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[--number-state] <base_hashlist> [<clone_hashlist>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_BASE:   比較結果の表示に使用される、比較元ディレクトリを表す文字列。"
    echo "    TAG_CLONE:  比較結果の表示に使用される、比較対象ディレクトリを表す文字列。"
    exit $1
}

SHELL_NAME=`basename $0`


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

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
        -*)
            if [[ "$1" == '--number-state' ]]; then
                number_state='true'
            else
                usage_exit 1
            fi
            shift
            ;;
        *)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
    esac
done
exit_code=$#
if [ $exit_code -ne 0 ]; then
    exit $exit_code
fi

################################################################################
# 引数取得
################################################################################

if [ $argc -le 0 -o $argc -ge 3 ]; then
    usage_exit 1
fi

base_list=${argv[0]}
clone_list=${argv[1]:-"-"}

TAG_BASE=${TAG_BASE:-"base"}
TAG_BASE_EMPTY=`echo $TAG_BASE | sed 's/./-/g'`
TAG_CLONE=${TAG_CLONE:-"clone"}
TAG_CLONE_EMPTY=`echo $TAG_CLONE | sed 's/./-/g'`


# すべてのファイルは次のいずれかに当てはまる。
#   (I). base にのみ存在し、clone には存在しない
#   (II). clone にのみ存在し、base には存在しない
#   (III). base にも clone にも存在するが内容が一致しない
#   (IV). base にも clone にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# (I), (II), (III) のどれに該当するかを表す数値『存在フラグ』を
# 出力用文字列に変換するためのコマンド。
if [ -n "$number_state" ]; then
    # オプションで、文字列変換を OFF にできる。
    state_replace=(cat)
else
    # 『存在フラグ』を視認しやすい文字列へ変換するコマンド。
    state_replace=(sed -e "s/^1/$TAG_BASE -- $TAG_CLONE_EMPTY/" -e "s/^2/$TAG_BASE_EMPTY -- $TAG_CLONE/" -e "s/^3/$TAG_BASE != $TAG_CLONE/")
fi

# 2つのハッシュリストを比較する。
# { awk ... awk ... }
#   2つのハッシュリストを加工し結合。
#   先頭に『存在フラグ』フィールドを付ける。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致する
# sort -k 3 | uniq -f1 -u
#   (ハッシュ値, ファイルパス) の組が重複する場合、このファイルは base と clone で一致しているので除外する。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 行がない
# sed -e 's/ \+\([0-9a-fA-F]\+\) \+/;\1;/'
#   フィールドの区切りをセミコロンに変える。
#   ファイル名に含まれるスペースが区切り文字とならないようにするため。
# awk -F ';' '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}'
#   SQLでいうところの「SELECT sum(存在フラグ),ファイルパス GROUP BY ファイルパス」
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が3の行だけある。
#        (IV). 行がない
# ${state_replace[@]}
#   上記の『存在フラグ』を、視認しやすい文字列へ変換する。
{
    awk '{print "1", $0}' $base_list
    awk '{print "2", $0}' $clone_list
} | \
sort -k 3 | uniq -f1 -u | \
sed -e 's/ \+\([0-9a-fA-F]\+\) \+/;\1;/' | \
awk -F ';' '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}' | \
"${state_replace[@]}"
