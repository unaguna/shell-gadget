#!/bin/bash

SHELL_DIR=$(cd $(dirname $0) && pwd)

# テスト対象モジュールが存在するディレクトリ。
TEST_TARGET_DIR=`sed -e 's:/spec/.\+::' -e 's:/spec$::' <<< "$SHELL_DIR"`
cd $TEST_TARGET_DIR

shellspec --path "$TEST_TARGET_DIR:$PATH" --shell bash
