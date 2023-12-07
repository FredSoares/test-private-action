#!/bin/bash

set -e

# Install dependencies
yarn

# Get version before merge
OLD_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))

# Get version after merge
NEW_VERSION=$(node -p "require('./package.json').version")

# Compare versions and publish if they are different
if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
  echo "Version changed from $OLD_VERSION to $NEW_VERSION. Publishing to npm..."]

  # Set authentication details
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> .npmrc
  
  # A pre-release is a version with a label i.e. v2.0.0-alpha.1
  if [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+-.+$ ]]
  then
    yarn
    yarn publish --tag next --access=public
  else
    yarn
    yarn publish --access=public
  fi
else
  echo "Version did not change."
fi
cd - || exit
