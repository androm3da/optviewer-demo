#!/bin/bash -ex

set -euo pipefail

configure_identity() {
    ENCRYPTION_LABEL=d87c07fd1a5b
    ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
    ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
    ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
    ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

    # Decrypt the key we'll use to publish this change to
    # github:
    openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_rsa.enc -out deploy_key -d
    chmod 600 deploy_key
    eval $(ssh-agent -s)
    ssh-add deploy_key
}

THIS_REPO_SHA=$(git rev-parse --verify HEAD)

configure_identity

REPO=git@github.com:androm3da/optviewer-demo.git
git clone $REPO ${HOME}/output_repo
cd ${HOME}/output_repo

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

export GENERATED_OUTPUT=${HOME}/output_analysis/
rm -rf  ${HOME}/output_repo/output_analysis/
mv ${GENERATED_OUTPUT} ${HOME}/output_repo/
#find ${HOME}/output_repo/output_analysis/
git fetch --all
git checkout ${TARGET_BRANCH}
git add output_analysis/
git commit -m "Deploy output for '${THIS_REPO_SHA}'"

# Publish to the gh-pages branch

git push origin ${TARGET_BRANCH}
git push origin ${TARGET_BRANCH}
