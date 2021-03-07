#!/bin/bash

################################################################################
# 入力照合
#
# 標準入力が引数と一致するかどうかを確かめる。
################################################################################

# 標準入力が引数に一致しない場合の終了コード
readonly EXIT_CODE_FAILED=120


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    :
}
trap finally EXIT


################################################################################
# 引数解析
################################################################################
declare -i argc=0
declare -a expected=()
while (( $# > 0 )); do
    case $1 in
        *)
            ((++argc))
            expected=("${expected[@]}" "$1")
            shift
            ;;
    esac
done


################################################################################
# メイン処理
################################################################################

# 照合済みなら1文字以上の文字列になる
success=

# 連続失敗回数
cnt_faild=0

# 入力を促す
echo -n "> "

while read line; do
    # 入力が引数のうちどれか一つと一致すれば照合成功。
    # 成功時や失敗して再度の入力を受け付けない時は exit で while を抜ける。
    if printf '%s\n' "${expected[@]}" | grep -qx "$line" > /dev/null >&2; then
        success=true
        cnt_faild=0
        exit 0
    else
        cnt_faild=$(($cnt_faild+1))
        echo "入力 \"$line\" は期待される文字列と一致しません。" 1>&2
    fi

    # 再度の入力を促す
    echo -n "> "
done


################################################################################
# 結果返却
################################################################################
if [ -n "$success" ]; then
    exit 0
else
    exit $EXIT_CODE_FAILED
fi
