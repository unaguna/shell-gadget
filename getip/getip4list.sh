#!/bin/bash

################################################################################
# 名前解決 (IPv4)
#
# 引数として入力されたすべてのホストのIPアドレスを標準出力する。
# IPアドレス取得には host コマンドが使用される。
################################################################################

readonly script_dir=$(cd $(dirname $0) && pwd)
readonly script_name=`basename $0`
PATH="$script_dir:$PATH"


################################################################################
# エラーハンドリング
################################################################################

set -o pipefail

function finally () {
    :
}
trap finally EXIT


################################################################################
# メイン処理
################################################################################

# やりたいこと。ただし、これではgetip4.sh のエラーを拾えない。
# cat hostlist.txt | awk '{"getip4.sh "$4" " | getline ip; print $4, ip}'

# 1つでもIPを取得できなければ値が入る変数
someone_errored=

# 各引数について getip4.sh を実行する。
while (( $# > 0 )); do
    host_name="$1"
    shift

    ip_address=`getip4.sh "$host_name" | head -n1`
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        someone_errored=true
        continue
    fi

    echo "$host_name" "$ip_address"
done
exit_code=$?
if [ $exit_code -ne 0 ]; then
    exit $exit_code
fi


if [ -n "$someone_errored" ]; then
    exit 1
fi
