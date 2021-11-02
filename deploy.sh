#!/bin/sh

fatal_error() {
	>&2 echo $1
	echo
	exit 1
}

if [ -z "$1" ]; then
	fatal_error "Please provide a deployment (.depl) file."
fi

. $1

echo "  Repository: "${REPO}
echo "      Branch: "${BRANCH}
echo "       Build: "${BUILD}
echo " Dotenv File: "${DOTENV}
echo "Node Version: "${NODE_VER}
echo "        Port: "${PORT}
echo
echo "SSH connection: "${SSH_STR}
echo "       SSH key: "${SSH_KEY}
echo

if [ -z "${REPO}" ] || 
	[ -z "${BRANCH}" ] || 
	[ -z "${BUILD}" ] || 
	[ -z "${DOTENV}" ] || 
	[ -z "${NODE_VER}" ] || 
	[ -z "${PORT}" ] || 
	[ -z "${SSH_STR}" ] || 
	[ -z "${SSH_KEY}" ]; then
	fatal_error "One or more parameters are missing from the deployment file provided."
fi

export REPO
export BRANCH
export BUILD
export DOTENV
export NODE_VER
export PORT
export SSH_STR
export SSH_KEY

TMP_DIR=/tmp/${REPO}.${BUILD}

if [ -d ${TMP_DIR} ]; then
	echo "# Removing old "${TMP_DIR}
	rm -rf ${TMP_DIR}
	echo
fi

echo "# Cloning repository into "${TMP_DIR}
git clone -b ${BRANCH} git@github.com:charlescoult/${REPO} --recurse-submodules ${TMP_DIR}
echo

echo "# Copying .env file into "${TMP_DIR}
cp ${DOTENV} ${TMP_DIR}/.env
echo

echo "# Generating service file..."
./gen_service.sh > ${TMP_DIR}/${REPO}.${BUILD}.service
# ssh -i ${SSH_KEY} ${SSH_STR} 'cat > '${SERVICE_DIR}/${REPO}.${BUILD}.service
echo

START_DIR=$(pwd)
cd ${TMP_DIR}

echo "# Installing dependencies..."
yarn
echo

echo "# Building \""${BUILD}"\" client..."
yarn build:${BUILD}
echo

TAR_FN=${REPO}.${BUILD}.tar.xz
echo "# Generating compressed tar file for scp transfer: "${TAR_FN}
tar -cJf /tmp/${TAR_FN} .
echo

echo "# Copying tar file to server..."
scp -i ${SSH_KEY} /tmp/${TAR_FN} ${SSH_STR}:/tmp
echo

cd ${START_DIR}

echo "# Installing new version on server and restarting associated service."
ssh -i ${SSH_KEY} ${SSH_STR} 'bash -s' < ./deploy_ssh.sh ${REPO} ${BUILD}
echo

echo "Done."
echo

