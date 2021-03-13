#!/bin/bash

readonly script_dir=$(cd $(dirname $0) && pwd)
readonly script_name=`basename $0`
PATH="$script_dir:$PATH"


# 通過させるディレクトリパスの配列
accept_dir_list=()

# 取捨選択の判定に用いるフィールド番号
key=1


################################################################################
# エラーハンドリング
################################################################################

set -e -o pipefail

function finally () {
    set +e +o pipefail
    
    # 一時ファイルが存在する場合に削除
    rm -f $awk_script_file
}
trap finally EXIT

################################################################################
# 引数解析
################################################################################
declare -i argc=0
declare -a argv=()
while (( $# > 0 )); do
    case $1 in
        -)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
        -a)
            accept_dir_list+=( "$2" )
            shift 2
            ;;
        -k)
            key="$2"
            shift 2
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
# メイン処理
################################################################################

# awk スクリプトファイル作成
awk_script_file=`mktemp -t "$script_name.awk_script.XXXXXX"`
{
    echo -n 0
    for target in "${accept_dir_list[@]}"; do
        echo -n " || substr(\$$key,0,length(\"$target\")) == \"$target\""
    done
    echo
} > "$awk_script_file"


cat "${argv[@]}" | \
awk -f "$awk_script_file"
