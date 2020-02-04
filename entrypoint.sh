#!/bin/bash

set -e

# Environment variables

# Specifies the branch to deploy to
# Default: `gh-pages`
GH_PAGES_BRANCH=${INPUT_GH_PAGES_BRANCH:-${GH_PAGES_BRANCH:-"gh-pages"}}

# Specifies the folder that Jekyll builds to
# Default: `_site`
GH_PAGES_DIST_FOLDER=${INPUT_GH_PAGES_DIST_FOLDER:-${GH_PAGES_DIST_FOLDER:-"_site"}}

if [[ -n "$GH_PAGES_MESSAGE" ]]; then
  echo "DEPRECATED: Please use the GH_PAGES_COMMIT_MESSAGE environment variable instead of GH_PAGES_MESSAGE."
  GH_PAGES_COMMIT_MESSAGE="$GH_PAGES_MESSAGE"
fi
# Specifies the commit message
GH_PAGES_COMMIT_MESSAGE=${INPUT_GH_PAGES_COMMIT_MESSAGE:-${GH_PAGES_COMMIT_MESSAGE:-"Deploy commit $GITHUB_SHA\n\nAutodeployed using $GITHUB_ACTION in $GITHUB_WORKFLOW"}}

# GitHub Pages token for deploying
GH_PAGES_TOKEN=${INPUT_GH_PAGES_TOKEN:-$GH_PAGES_TOKEN}

# GitHub token
GITHUB_TOKEN=${INPUT_GITHUB_TOKEN:-$GITHUB_TOKEN}

# Specifies the Git remote repository
REMOTE_REPO=${INPUT_REMOTE_REPO:-${REMOTE_REPO:-"https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"}}

# Specifies the committer's username
# Default: $GITHUB_ACTOR
COMMITTER_USERNAME=${INPUT_COMMITTER_USERNAME:-${COMMITTER_USERNAME:-$GITHUB_ACTOR}}

# Specifies the committer's email
# Default: `${GITHUB_ACTOR}@users.noreply.github.com`
COMMITTER_EMAIL=${INPUT_COMMITTER_EMAIL:-${COMMITTER_EMAIL:-"${GITHUB_ACTOR}@users.noreply.github.com"}}

# Whether to force pushing
# Default: `true`
GIT_FORCE=${INPUT_GIT_FORCE:-${GIT_FORCE:-true}}

# Whether to override the contents of the branch with the current build
OVERRIDE_GH_PAGES_BRANCH=${INPUT_OVERRIDE_GH_PAGES_BRANCH:-${OVERRIDE_GH_PAGES_BRANCH:-false}}

# Specifies the Jekyll build command
JEKYLL_BUILD_OPTS="${INPUT_JEKYLL_BUILD_OPTS:-${JEKYLL_BUILD_OPTS}}"

# Whether to add the `.nojekyll` file to indicate that the branch should not be built
# Default: `true`
GH_PAGES_ADD_NO_JEKYLL=${INPUT_GH_PAGES_ADD_NO_JEKYLL:-${GH_PAGES_ADD_NO_JEKYLL:-true}}

# Whether to skip deployment
# Default: `false`
SKIP_DEPLOY=${INPUT_SKIP_DEPLOY:-${SKIP_DEPLOY:-false}}

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
  echo "Running pre-build commands..."
  eval "$JEKYLL_BUILD_PRE_COMMANDS"
fi
bundle exec jekyll build "$JEKYLL_BUILD_OPTS"
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
  echo "Running post-build commands..."
  eval "$JEKYLL_BUILD_POST_COMMANDS"
fi

if [[ "$SKIP_DEPLOY" = true || ($SKIP_DEPLOY == 1) ]]; then
  echo "Finished build, skipping deployment..."
  exit 0
fi

if [[ -n "$GH_PAGES_COMMIT_PRE_COMMANDS" ]]; then
  echo "Running pre-commit commands..."
  eval "$GH_PAGES_COMMIT_PRE_COMMANDS"
fi
echo "Setting Git username and email..."
git config user.name "$COMMITTER_USERNAME"
git config user.email "$COMMITTER_EMAIL"

echo "Committing all files..."
git add -A

git commit -m "$(echo -e "$GH_PAGES_COMMIT_MESSAGE")"
if [[ "$GIT_FORCE" = true || ($GIT_FORCE == 1) ]]; then
  git push --force origin "$GH_PAGES_BRANCH"
else
  echo "WARNING: Not force-pushing to the branch!"
  echo "This may yield unexpected results!"
  git push origin "$GH_PAGES_BRANCH"
fi

if [[ -n "$GH_PAGES_COMMIT_POST_COMMANDS" ]]; then
  echo "Running post-commit commands..."
  eval "$GH_PAGES_COMMIT_POST_COMMANDS"
fi

echo "Requesting build request for deployed build..."

curl -X POST -u "$GITHUB_ACTOR":"$GH_PAGES_TOKEN" -H "Accept: application/vnd.github.mister-fantastic-preview+json" "https://api.github.com/repos/${GITHUB_REPOSITORY}/pages/builds"

echo "Successfully requested build request!"

cd ..

echo "Success!"
