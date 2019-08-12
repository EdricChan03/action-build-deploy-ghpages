#!/bin/bash

set -e

# Environment variables

# Specifies the type of repository
# Valid values:
# - `project`
# - `user`
# Default: `project`
# DEPRECATED: Please use GH_PAGES_BRANCH instead which allows for more configuration.
if [[ -n "$GH_PAGES_TYPE" ]]; then
  echo -e "DEPRECATED: Please use the GH_PAGES_BRANCH environment variable instead of GH_PAGES_TYPE.\nThis may be removed in a future release."
  if [[ "$GH_PAGES_TYPE" = "project" ]]; then
    GH_PAGES_BRANCH="gh-pages"
  elif [[ "$GH_PAGES_TYPE" = "user" ]]; then
    GH_PAGES_BRANCH="master"
  fi
fi
# Specifies the branch to deploy to
# Default: `gh-pages`
GH_PAGES_BRANCH=${GH_PAGES_BRANCH:-"gh-pages"}
# Specifies the folder that Jekyll builds to
# Default: `_site`
GH_PAGES_DIST_FOLDER=${GH_PAGES_DIST_FOLDER:-"_site"}

if [[ -n "$GH_PAGES_MESSAGE" ]]; then
  echo "DEPRECATED: Please use the GH_PAGES_COMMIT_MESSAGE environment variable instead of GH_PAGES_MESSAGE."
  GH_PAGES_COMMIT_MESSAGE="$GH_PAGES_MESSAGE"
fi
# Specifies the commit message
GH_PAGES_COMMIT_MESSAGE=${GH_PAGES_COMMIT_MESSAGE:-"Deploy commit $GITHUB_SHA\n\nAutodeployed using $GITHUB_ACTION in $GITHUB_WORKFLOW"}
if [[ -z "$GH_PAGES_TOKEN" ]]; then
  echo "ERROR: Please use the GH_PAGES_TOKEN to specify the token to use for triggering a build request."
  exit 1
fi
# Specifies the Git remote repository
# REMOTE_REPO=${REMOTE_REPO:-"https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"}
REMOTE_REPO=${REMOTE_REPO:-"https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"}
# Specifies the committer's username
# Default: $GITHUB_ACTOR
COMMITTER_USERNAME=${COMMITTER_USERNAME:-$GITHUB_ACTOR}
# Specifies the committer's email
# Default: `${GITHUB_ACTOR}@users.noreply.github.com`
COMMITTER_EMAIL=${COMMITTER_EMAIL:-"${GITHUB_ACTOR}@users.noreply.github.com"}

# Whether to force pushing
# Default: `true`
GIT_FORCE=${GIT_FORCE:-true}

# Whether to override the contents of the branch with the current build
OVERRIDE_GH_PAGES_BRANCH=${OVERRIDE_GH_PAGES_BRANCH:-false}

# Whether to add the `.nojekyll` file to indicate that the branch should not be built
# Default: `true`
GH_PAGES_ADD_NO_JEKYLL=${GH_PAGES_ADD_NO_JEKYLL:-true}

echo "Installing gem bundle..."
# Prevent installed dependencies messages from clogging the log
bundle install > /dev/null 2>&1

# Check if jekyll is installed
bundle list | grep "jekyll ("

echo "Successfully installed gem bundles!"

echo "Pushing to GitHub Pages..."

if [[ -d "$GH_PAGES_DIST_FOLDER" ]]; then
  rm -rf "$GH_PAGES_DIST_FOLDER"
  mkdir "$GH_PAGES_DIST_FOLDER"
# else
  # echo "The dist folder doesn't exist! Either you did not set GH_PAGES_DIST_FOLDER properly, or you changed the destination in the Jekyll configuration!"
  # exit 1
fi

echo "Cloning repository locally..."
git clone "$REMOTE_REPO" --branch "$GH_PAGES_BRANCH" "$GH_PAGES_DIST_FOLDER"

if [[ "$OVERRIDE_GH_PAGES_BRANCH" = true || ($OVERRIDE_GH_PAGES_BRANCH = 1) ]]; then
  echo "Emptying branch contents..."
  cd "$GH_PAGES_DIST_FOLDER"
  rm -rf ./*
  cd ..
fi

if [[ -n "$JEKYLL_BUILD_PRE_COMMANDS" ]]; then
  echo "Running pre commands..."
  bash -c "$JEKYLL_BUILD_PRE_COMMANDS"
fi
bundle exec jekyll build
echo "Successfully built the site!"

if [[ -d "$GH_PAGES_DIST_FOLDER" ]]; then
  cd "$GH_PAGES_DIST_FOLDER"
else
  echo "An error occurred while changing the working directory. See the log above for more info."
  exit 1
fi

if [[ "$GH_PAGES_ADD_NO_JEKYLL" = true || ($GH_PAGES_ADD_NO_JEKYLL == 1) ]]; then
  # The .nojekyll file should have a blank line in the file's contents
  echo "" > .nojekyll
fi
if [[ -n "$JEKYLL_BUILD_POST_COMMANDS" ]]; then
  echo "Running post commands..."
  bash -c "$JEKYLL_BUILD_POST_COMMANDS"
fi

if [[ -n "$GH_PAGES_COMMIT_PRE_COMMANDS" ]]; then
  echo "Running pre commands..."
  bash -c "$GH_PAGES_COMMIT_PRE_COMMANDS"
fi
echo "Setting Git username and email..."
git config user.name "$COMMITTER_USERNAME"
git config user.email "$COMMITTER_EMAIL"

echo "Committing all files..."
git add -A
# echo -n "Files to commit: " && ls -l | wc -l

git commit -m "$(echo -e "$GH_PAGES_COMMIT_MESSAGE")"
if [[ "$GIT_FORCE" = true || ($GIT_FORCE == 1) ]]; then
  git push --force origin $GH_PAGES_BRANCH
else
  echo "WARNING: Not force-pushing to the branch!"
  echo "This may yield unexpected results!"
  git push origin $GH_PAGES_BRANCH
fi

if [[ -n "$GH_PAGES_COMMIT_POST_COMMANDS" ]]; then
  echo "Running post commands..."
  bash -c "$GH_PAGES_COMMIT_POST_COMMANDS"
fi

echo "Requesting build request for deployed build..."

curl -X POST -u $GITHUB_ACTOR:$GH_PAGES_TOKEN -H "Accept: application/vnd.github.mister-fantastic-preview+json" "https://api.github.com/repos/${GITHUB_REPOSITORY}/pages/builds"

echo "Successfully requested build request!"

cd ..

echo "Success!"
