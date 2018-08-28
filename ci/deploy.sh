#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

SOURCE_BRANCH="jekyll"
TARGET_BRANCH="master"
DEPLOY_KEY="redhat-cop-deploy-key"
ENCRYPTED_KEY=${encrypted_4141ce77cc08_key}
ENCRYPTED_VAL=${encrypted_4141ce77cc08_iv}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy;"
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH

# Clean out existing contents
rm -rf ./**/* || exit 0

cp -r /home/travis/build/redhat-cop/redhat-cop.github.io/_site/* .

# Now let's go have some fun with the cloned repo
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if git diff --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"

# Decrypt deploy key
openssl aes-256-cbc -K ${ENCRYPTED_KEY} -iv ${ENCRYPTED_VAL} \
  -in redhat-cop-deploy-key.enc -out redhat-cop-deploy-key -d

chmod 600 ../$DEPLOY_KEY
eval `ssh-agent -s`
ssh-add ../$DEPLOY_KEY

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH
