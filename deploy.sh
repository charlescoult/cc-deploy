#!/bin/sh

REPO=cc-web
BRANCH=${1:-develop}

SSH_STR=ec2-user@ec2-54-153-119-62.us-west-1.compute.amazonaws.com
SSH_KEY=~/.ssh/cc-web-key.pem

echo ${REPO}
echo ${BRANCH}

rm -rf ${REPO}
git clone -b ${BRANCH} git@github.com:charlescoult/${REPO} --recurse-submodules
cd ${REPO}
yarn && yarn build:production
cd ..
TAR_FN=${REPO}.tar.xz
tar -cJf ${TAR_FN} ${REPO} .env
scp -i ${SSH_KEY} ${TAR_FN} ${SSH_STR}:/tmp
ssh -i ${SSH_KEY} ${SSH_STR} 'bash -s' < deploy_ssh.sh ${REPO} ${TAR_FN}


