#!/bin/sh

START=$(pwd)
REPO=$1
TAR_FN=$2
TMP_DIR=/tmp/${REPO}

echo ${START}
echo ${REPO}
echo ${TAR_FN}
echo ${TMP_DIR}

rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}
tar -xf /tmp/${TAR_FN} -C ${TMP_DIR}
echo

rm -rf ${START}/${REPO}
mv ${TMP_DIR}/* ${TMP_DIR}/.* ${START}

sudo systemctl restart ${REPO}

