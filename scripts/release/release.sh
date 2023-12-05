#!/bin/bash

# Remove 'v' prefix from VERSION if it exists
VERSION=${VERSION#v}

# The script builds the package and publishes it to npm.
#
# It's the entry point for the release process.

set -e

# A pre-release is a version with a label i.e. v2.0.0-alpha.1
if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+-.+$ ]]
then
  IS_PRE_RELEASE=true
else
  IS_PRE_RELEASE=false
fi

# Write version & commit package.json
./scripts/release/writeVersion.js
git add package.json
git commit -m "Prepare $VERSION"
git tag -a "$VERSION" -m "$VERSION"
git push

# Right now, we do releases manually, but when we move to GitHub Actions we'll need this line:
echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc
cd "$PACKAGE_PATH" || exit 1
if [ "$IS_PRE_RELEASE" = true ]
then
  yarn
  yarn publish --tag next --access=public
  echo "NPM authToken=$NPM_TOKEN"
  echo "npm publish --tag next --access=public"
else
  yarn
  yarn publish --access=public
  echo "NPM authToken=$NPM_TOKEN"
  echo "npm publish --access=public"
fi
cd - || exit

# TODO: Build & deploy docs JSON

# TODO: Publish to slack 