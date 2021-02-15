#!/bin/bash

# 使い方を出力する関数
usage() {
    echo "抽出ファイルリスト取得シェル" 1>&2
    echo usage: `basename $0` "<cond_list_filepath>" 1>&2
}

if [[ $1 = "-help" ]] || [[ $1 = "--help" ]]; then
    usage
    exit 1
fi

# ホワイト・ブラックリストのパス
# ファイルパスが引数として指定されない場合、代わりに標準入力を使用する。
CONDLIST_PATH=$1
if [ -z "$CONDLIST_PATH" ]; then
    CONDLIST_PATH=-
fi

# パイプラインの途中でエラーがあった場合に、終了ステータスで補足できるようにする。
set -o pipefail

# 一時ファイルを作るディレクトリ
# 環境変数 FILTERLS_TMP_DIR に指定がない場合はデフォルト値を使用する。
TMP_DIR="${FILTERLS_TMP_DIR:-"/tmp"}"

# 一時ファイル名の接頭語
TMP_SED_SCRIPT_PREFIX="filterls_"

# スクリプト終了時に実行する関数を設定。
unset TMP_SED_SCRIPT_PATH
atexit() {
    # 一時ファイル削除
    [[ -n ${TMP_SED_SCRIPT_PATH-} ]] && rm -f "$TMP_SED_SCRIPT_PATH"
}
trap atexit EXIT


# ホワイト・ブラックリストを読み込む。
# sed -e 's/#.*$//':    「#」以降をコメントとして扱い、取り除く。
# awk 1:                末尾に改行がない場合に追加する。
#                       (入力とsedの実装によっては末尾に改行がつかず、そのままでは以降の tac の出力が意図したとおりにならないため。)
CONDLIST=`sed -e 's/#.*$//' $CONDLIST_PATH | awk 1`

# ファイルリスト取得の対象とするディレクトリ
TARGET_DIR=`awk '{if($1 == "R"){print $2}}' <<< $CONDLIST | head -n1`
EXEC_CODE=$?
if [ $EXEC_CODE -ne 0 ]; then
    exit $EXEC_CODE
elif [ -z "$TARGET_DIR" ]; then
    echo `basename $0`: "探索のルートディレクトリが指定されていません。" 1>&2
    echo "入力に「R <root dir>」の行を追加してください。" 1>&2
    exit 1
fi

# 一時ファイルを作成し、そのパスを取得
TMP_SED_SCRIPT_PATH=$(mkdir -p "${TMP_DIR}" && mktemp "${TMP_DIR}/${TMP_SED_SCRIPT_PREFIX}XXXXXXXX")
EXEC_CODE=$?
if [ $EXEC_CODE -ne 0 ]; then
    exit $EXEC_CODE
fi

# ホワイト・ブラックリストを sed のスクリプトファイルに変換する。
# tac:                              下の行ほど優先したいので逆順にする。
# sed -e 's/\([][\/.]\)/\\\1/g' :   パスに含まれる ][\/. をエスケープし、正規表現内で通常文字として扱えるようにする。
# awk ...:                          A の行を p\nd(出力) 命令に、D の行を d(無視) 命令にして、sed のスクリプトファイルを作成する。
tac <<< $CONDLIST | sed -e 's/\([][\/.]\)/\\\1/g' | awk '{if($1 == "A"){print "/^"$2"/{p\nd}"}else if($1 == "D"){print "/^"$2"/d"}}' > $TMP_SED_SCRIPT_PATH
EXEC_CODE=$?
if [ $EXEC_CODE -ne 0 ]; then
    exit $EXEC_CODE
fi

# ホワイト・ブラックリストで規定されたファイルの ls -l を表示する。
# find ${TARGET_DIR} -type f:       ${TARGET_DIR} ディレクトリ以下のすべてのファイルの絶対パスを取得
# sed -n -f $TMP_SED_SCRIPT_PATH:   ホワイト・ブラックリストで規定されたファイルのみを抽出
# xargs ls -l:                      抽出されたパスについて ls -l を取得。
#                                   パイプラインの途中でエラーが発生した場合は実行してほしくないので、
#                                   直接パイプラインで繋がず、xargs の前に $? のチェックを挟む。
tmp=`find ${TARGET_DIR} -type f | sed -n -f $TMP_SED_SCRIPT_PATH`
EXEC_CODE=$?
if [ $EXEC_CODE -ne 0 ]; then
    exit $EXEC_CODE
fi
xargs ls -dl <<< $tmp
EXEC_CODE=$?
if [ $EXEC_CODE -ne 0 ]; then
    exit $EXEC_CODE
fi
