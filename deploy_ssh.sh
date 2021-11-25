#!/bin/sh

REPO=$1
BUILD=$2

TAR_FN=${REPO}.${BUILD}.tar.xz
INST_DIR=~/${REPO}.${BUILD}

if [ -d ${INST_DIR} ]; then
	echo "## Moving previous installation to: "${INST_DIR}.old
	if [ -d ${INST_DIR}.old ]; then
		echo "### "${INST_DIR}".old already exists, deleting..."
		rm -rf ${INST_DIR}.old
	fi
	mv ${INST_DIR} ${INST_DIR}.old
	echo
fi

mkdir ${INST_DIR}

echo "## Extracting /tmp/"${TAR_FN}" to "${INST_DIR}
tar -xf /tmp/${TAR_FN} -C ${INST_DIR}
rm /tmp/${TAR_FN}
echo

SERVICE_FILE=${REPO}.${BUILD}.service
echo "## Copying service file: "${SERVICE_FILE}
sudo cp ${INST_DIR}/${SERVICE_FILE} /etc/systemd/system/${SERVICE_FILE}
echo

echo "## Migrating database..."
cd ${INST_DIR}
yarn db:${BUILD}

echo "## Reloading service file and restarting service..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_FILE}
sudo systemctl restart ${SERVICE_FILE}

rm -rf ${INST_DIR}.old
echo

