#!/usr/bin/env bash

set -x # 実行されたコマンドを表示する
set -e # エラーがあったら諦めろ
set -u # 未定義変数があるとエラー

BASE_DIR=`cd $(dirname $0); pwd`

JUBATUS_DIR="jubatus-generate"
JUBATUS_BRANCH="master"
CLIENT_DIR="${BASE_DIR}/../generate"

[ $# -eq 0 ] || JUBATUS_BRANCH="${1}"

rm -rf "${JUBATUS_DIR}"
git clone https://github.com/jubatus/jubatus.git "${JUBATUS_DIR}"
pushd "${JUBATUS_DIR}"
git checkout "${JUBATUS_BRANCH}"
popd

# Perl
rm -rf "${CLIENT_DIR}/lib/"*
pushd "${JUBATUS_DIR}/jubatus/server/server"
for IDL in *.idl; do
  NAME_SPACE="$(basename "${IDL}" ".idl")"
  NAME_SPACE="${NAME_SPACE^}"
  PM_DIR=${CLIENT_DIR}/lib
  IDL_HASH=`git log -1 --format=%H -- ${IDL}`
  IDL_VER=`git describe ${IDL_HASH}`
  /home/overlast/git/other/jubatus/tools/jenerator/src/jenerator -l perl -n "Jubatus::${NAME_SPACE}::" -o "${PM_DIR}" "${IDL}" --idl-version ${IDL_VER}
done
popd

mkdir -p ${BASE_DIR}/../lib/Jubatus/
cp -rf  ${PM_DIR}/Jubatus/* ${BASE_DIR}/../lib/Jubatus/
