#!/bin/bash

##############################################################
# パスワード入力を伴うコマンドを実行する。
#
# 引数
#   実行するコマンド
#
# 環境変数
#   PASSWORD: 入力するパスワード
#   PRE_TIMEOUT_INTERVAL: パスワード要求までのタイムアウト時間（秒）（デフォルトは5秒）
#   TIMEOUT_INTERVAL: タイムアウト時間（秒）（デフォルトは5秒）
##############################################################

# この実行ファイル名
readonly script_name=`basename $0`


###############################################################################
# エラーハンドリング
###############################################################################

set -o pipefail

function finally () {
    :
}
trap finally EXIT


###############################################################################
# 関数定義
###############################################################################

# エラーメッセージ出力
function echo_err () {
    echo "$@" 1>&2
}


###############################################################################
# 引数取得
###############################################################################

# expect の spawn に指定する -noecho オプション。
# 指定するなら '-noecho'、しないなら空文字列。
opt_echo='-noecho'

# このシェルのオプションを取得
while (( $# > 0 )); do
    case $1 in
        --spawn-echo)
            opt_echo=''
            shift 1
            ;;
        -*)
            # 不明なオプション
            echo_err "$script_name: Unknown option: $1"
            exit 1
            ;;
        *)
            break
    esac
done

# 実行するコマンド
command="$@"

# 実行するコマンドの指定がない場合は異常終了する。
if [ -z "$command" ]; then
    echo_err "$script_name: 実行コマンドが指定されていません。"
    exit 123
fi

# PASSWORD の指定がない場合は異常終了する。
if [ -z "$PASSWORD" ]; then
    echo_err "$script_name: 使用するパスワードが指定されていません。"
    exit 123
fi

# タイムアウト時間（秒）
TIMEOUT_INTERVAL=${TIMEOUT_INTERVAL:-5}

# パスワード要求までのタイムアウト時間（秒）
PRE_TIMEOUT_INTERVAL=${PRE_TIMEOUT_INTERVAL:-5}


###############################################################################
# メイン処理
###############################################################################

expect -c "
    set timeout $PRE_TIMEOUT_INTERVAL
    spawn $opt_echo ${command[@]}
    expect {
        \"password: \" {
            send \"$PASSWORD\n\"
            set timeout $TIMEOUT_INTERVAL
            expect {
                eof { }
                timeout { puts stderr \"TIMEOUT\"; exit 124 }
                \"Permission denied\" { puts stderr \"Permission denied\"; exit 124 }
            }
        }
        timeout { puts stderr \"TIMEOUT (LOGIN)\"; exit 124 }
    }

    # ssh の終了コードを確認する
    catch wait result
    set OS_ERROR [ lindex \$result 2 ]
    if { \$OS_ERROR == -1 } { exit 127 }
    exit [ lindex \$result 3 ]
"
exit $?
