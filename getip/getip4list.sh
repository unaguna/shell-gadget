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
# 引数取得
################################################################################

# 渡す引数リストを args として生成する。
options=()
args=()
while (( $# > 0 ))
do
    use_opt_arg=
    if [[ "$1" =~ ^- ]]; then
        if [[ "$1" =~ "T" ]]; then
            options+=( "-T" )
        fi
        if [[ "$1" =~ "w" ]]; then
            options+=( "-w" )
        fi
        if [[ "$1" =~ "s" ]]; then
            options+=( "-s" )
        fi
        if [[ "$1" =~ "r" ]]; then
            options+=( "-r" )
        fi
        if [[ "$1" =~ "W" ]]; then
            options+=( "-W" )
            options+=( "$2" )
            use_opt_arg=true
        fi
        if [[ "$1" =~ "R" ]]; then
            options+=( "-R" )
            options+=( "$2" )
            use_opt_arg=true
        fi
    else
        args+=( "$1" )
    fi


    if [ -n "$use_opt_arg" ]; then
        shift 2
    else
        shift
    fi
done


################################################################################
# メイン処理
################################################################################

# やりたいこと。ただし、これではgetip4.sh のエラーを拾えない。
# cat hostlist.txt | awk '{"getip4.sh "$4" " | getline ip; print $4, ip}'

# 1つでもIPを取得できなければ値が入る変数
someone_errored=

# 各引数について getip4.sh を実行する。
for host_name in "${args[@]}"; do
    ip_address=`getip4.sh "${options[@]}" "$host_name" | head -n1`
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
