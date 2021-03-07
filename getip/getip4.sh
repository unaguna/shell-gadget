#!/bin/bash

################################################################################
# 名前解決 (IPv4)
#
# 入力されたホストのIPアドレスを標準出力する。
# IPアドレス取得には host コマンドが使用され、オプションとして TwsrWR を使用できる。
################################################################################

SCRIPT_NAME=`basename $0`


################################################################################
# 引数取得
################################################################################

# 渡す引数リストを args として生成する。
args=()
while (( $# > 0 ))
do
    use_opt_arg=
    if [[ "$1" =~ "^-" ]]; then
        if [[ "$1" =~ "T" ]]; then
            args+=( "-T" )
        fi
        if [[ "$1" =~ "w" ]]; then
            args+=( "-w" )
        fi
        if [[ "$1" =~ "s" ]]; then
            args+=( "-s" )
        fi
        if [[ "$1" =~ "r" ]]; then
            args+=( "-r" )
        fi
        if [[ "$1" =~ "W" ]]; then
            args+=( "-W" )
            args+=( "$2" )
            use_opt_arg=true
        fi
        if [[ "$1" =~ "R" ]]; then
            args+=( "-R" )
            args+=( "$2" )
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

output=`host -4t a "${args[@]}"`
exit_code=$?
ip_address=`grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' <<< "$output"`
if [ "$exit_code" -ne 0 ]; then
    if [ -n "$output" ]; then
        echo "$output" 1>&2
    fi
    exit $exit_code
elif [ -z "$ip_address" ]; then
    echo "$SCRIPT_NAME: failed" 1>&2
    exit 1
fi

echo "$ip_address"
