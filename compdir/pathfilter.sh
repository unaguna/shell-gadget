#!/bin/bash

SHELL_DIR=$(cd $(dirname $0) && pwd)
SHELL_NAME=`basename $0`
PATH="$SHELL_DIR:$PATH"


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    set +e +o pipefail
    
    # 一時ファイルが存在する場合に削除
    rm -f $script_file
}
trap finally EXIT


################################################################################
# 引数取得
################################################################################

# 例外を除いて、すべての引数をそのまま sed に渡す。
# 渡す引数リストを args として生成する。
args=()
while (( $# > 0 ))
do
    if [ "$1" == "-f" ]; then
        args+=( "$1" )
        list_file=$2
        script_file=`mktemp -t "$SHELL_NAME.script_file.XXXXXX"`
        args+=( "$script_file" )
        shift 2
    else
        args+=( "$1" )
        list_file=
        script_file=
        shift
    fi
done


# リストの指定があった場合は、sed スクリプトファイルに変換する。
if [ -n "$list_file" ]; then
    # ホワイト・ブラックリストを sed のスクリプトファイルに変換する。
    # trim_comment.sh:                コメント行を削除する。
    # tac:                              下の行ほど優先したいので逆順にする。
    # sed -e 's/\([][\/.]\)/\\\1/g' :   パスに含まれる ][\/. をエスケープし、正規表現内で通常文字として扱えるようにする。
    # awk ...:                          A の行を p\nd(出力) 命令に、D の行を d(無視) 命令にして、sed のスクリプトファイルを作成する。
    trim_comment.sh $list_file | \
    tac | \
    sed -e 's/\([][\/.]\)/\\\1/g' | \
    awk '{if($1 == "A"){print "/^"$2"/{p\nd}"}else if($1 == "D"){print "/^"$2"/d"}}' > $script_file
fi

sed "${args[@]}"
