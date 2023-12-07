#!/bin/bash

set -e

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

# Get version before merge
OLD_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
OLD_VERSION=${OLD_VERSION#v} # Remove 'v' prefix if it exists
log "Old version: $OLD_VERSION"

# Get version after merge
NEW_VERSION=$(node -p "require('./package.json').version")
log "New version: $NEW_VERSION"

# Compare versions and publish if they are different
if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
  log "Version changed from $OLD_VERSION to $NEW_VERSION. Publishing new version to npm..."

  # Set authentication details
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> .npmrc

  # Publish to npm
  if [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+-.+$ ]]; then
    yarn
    yarn publish --tag next --access=public
  else
    yarn
    yarn publish --access=public
  fi

  # Generate release notes from git commits
  RELEASE_NOTES=$(git log --pretty=format:"* %s" "$OLD_VERSION".."$NEW_VERSION")
  echo "Release Notes for $NEW_VERSION:" > RELEASE_NOTES.md
  echo "$RELEASE_NOTES" >> RELEASE_NOTES.md

  # Create a new tag and release on GitHub
  git tag -a "v$NEW_VERSION" -m "Release $NEW_VERSION"
  git push origin "v$NEW_VERSION"
  gh release create "v$NEW_VERSION" --title "Release $NEW_VERSION" --notes-file RELEASE_NOTES.md

else
  log "Version did not change."
fi
