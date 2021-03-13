#!/bin/bash

# 2つのディレクトリの内容を比較し、差分をファイル一覧として出力する。
# ファイル同士の同一性はそのハッシュ値によって判断するため、原理的には誤陰性が起こりうる。

function usage_exit () {
    echo "Usage:" `basename $0` "[--number-state] <left_hashlist> [<right_hashlist>]"
    echo
    echo "Environment Variables:"
    echo "    TAG_LEFT:   比較結果の表示に使用される、左ディレクトリを表す文字列。"
    echo "    TAG_RIGHT:  比較結果の表示に使用される、右ディレクトリを表す文字列。"
    exit $1
}

function echo_err () {
    echo "$SHELL_NAME: $@" 1>&2
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
exit_code=$?
if [ $exit_code -ne 0 ]; then
    exit $exit_code
fi

################################################################################
# 引数取得
################################################################################

if [ $argc -le 0 -o $argc -ge 3 ]; then
    usage_exit 1
fi

left_list=${argv[0]}
right_list=${argv[1]:-"-"}

TAG_LEFT=${TAG_LEFT:-"LEFT"}
TAG_LEFT_EMPTY=`echo $TAG_LEFT | sed 's/./-/g'`
TAG_RIGHT=${TAG_RIGHT:-"RIGHT"}
TAG_RIGHT_EMPTY=`echo $TAG_RIGHT | sed 's/./-/g'`


# ファイルの存在チェック
if [ -n "$left_list" -a "$left_list" != "-" ]; then
    if [ ! -e "$left_list" ]; then
        echo_err "fatal: cannot open file \`$left_list' for reading (No such file or directory)"
        exit 1
    elif [ ! -f "$left_list" ]; then
        echo_err "fatal: cannot open file \`$left_list' for reading (It is a directory)"
        exit 1
    elif [ ! -r "$left_list" ]; then
        echo_err "fatal: cannot open file \`$left_list' for reading (Permission denied)"
        exit 1
    fi
fi
if [ -n "$right_list" -a "$right_list" != "-" ]; then
    if [ ! -e "$right_list" ]; then
        echo_err "fatal: cannot open file \`$right_list' for reading (No such file or directory)"
        exit 1
    elif [ ! -f "$right_list" ]; then
        echo_err "fatal: cannot open file \`$right_list' for reading (It is a directory)"
        exit 1
    elif [ ! -r "$right_list" ]; then
        echo_err "fatal: cannot open file \`$right_list' for reading (Permission denied)"
        exit 1
    fi
fi


# すべてのファイルは次のいずれかに当てはまる。
#   (I). left にのみ存在し、right には存在しない
#   (II). right にのみ存在し、left には存在しない
#   (III). left にも right にも存在するが内容が一致しない
#   (IV). left にも right にも存在し、内容が一致する
# これらのうち、(I),(II),(III) に当てはまるものだけを抽出し、
# 各ファイルがどれに当てはまるかがわかる形式で出力する。


# (I), (II), (III) のどれに該当するかを表す数値『存在フラグ』を
# 出力用文字列に変換するためのコマンド。
if [ -n "$number_state" ]; then
    # オプションで、文字列変換を OFF にできる。
    state_replace=(cat)
else
    # 『存在フラグ』を視認しやすい文字列へ変換するコマンド。
    state_replace=(sed -e "s/^1/$TAG_LEFT -- $TAG_RIGHT_EMPTY/" -e "s/^2/$TAG_LEFT_EMPTY -- $TAG_RIGHT/" -e "s/^3/$TAG_LEFT != $TAG_RIGHT/")
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
# sed -e 's/ \+/\x0/' -e 's/ \+/\x0/'
#   フィールドの区切りをヌル文字に変える。
#   ファイル名に含まれるスペースが区切り文字とならないようにするため。
# sort --key=3 | uniq --skip-chars=2 --unique
#   (ハッシュ値, ファイルパス) の組が重複する場合、このファイルは left と right で一致しているので除外する。
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が1の行と2の行があり、『ハッシュ値』は一致しない
#        (IV). 行がない
# awk -F '\0' '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}'
#   SQLでいうところの「SELECT sum(存在フラグ),ファイルパス GROUP BY ファイルパス」
#   この時点で、各ファイルについて次の状態になる。
#         (I). 『存在フラグ』が1の行だけある。
#        (II). 『存在フラグ』が2の行だけある。
#       (III). 『存在フラグ』が3の行だけある。
#        (IV). 行がない
# ${state_replace[@]}
#   上記の『存在フラグ』を、視認しやすい文字列へ変換する。
{
    awk '{print "1", $0}' $left_list
    awk '{print "2", $0}' $right_list
} | \
sed -e 's/ \+/\x0/' -e 's/ \+/\x0/' | \
sort --key=3 --field-separator='\0' | uniq --skip-chars=2 --unique | \
awk -F '\0' '{arr[$3]+=$1} END{for(i in arr) print arr[i], i}' | \
"${state_replace[@]}"
