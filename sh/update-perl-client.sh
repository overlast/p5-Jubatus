#!/usr/bin/env bash

set -x # 実行されたコマンドを表示する
set -e # エラーがあったら諦めろ
set -u # 未定義変数があるとエラー

BASEDIR=`cd $(dirname $0); pwd`
USER_ID=`/usr/bin/id -u`

$BASEDIR/../sh/generate-perl-client.sh develop
$BASEDIR/../bin/generate-jubatus-pm.pl
$BASEDIR/../bin/insert_pod.pl
cd $BASEDIR/../
prove -I ./lib
