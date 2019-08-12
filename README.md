# Deploy to GitHub Pages

A GitHub Action that builds and deploys a Jekyll site to GitHub Pages.

This GitHub Action requires a GitHub personal access token to deploy commits. To create one, click [here](https://github.com/settings/tokens/new?scopes=public_repo,repo_deployment&description=Token%20for%20Deploy%20GitHub%20Pages%20GitHub%20Action) and specify the `GH_PAGES_TOKEN` environment variable in your GitHub repository's Secrets.

## Environment variables

Name | Description | Default | Allowed values
---|---|---|---
`GH_PAGES_BRANCH` | Specifies the branch to deploy to | `gh-pages` | Any branch name
`GH_PAGES_DIST_FOLDER` | Specifies the folder that Jekyll builds to | `_site` | A folder name
`GH_PAGES_COMMIT_MESSAGE` | Specifies the commit message | `Deploy commit $GITHUB_SHA\nAutodeployed using $GITHUB_ACTION in $GITHUB_WORKFLOW` | A commit message
`REMOTE_REPO` | Specifies the Git remote repository | `https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git` | A remote repo
`COMMITTER_USERNAME` | Specifies the committer's username | `$GITHUB_ACTOR` | A GitHub username
`COMMITTER_EMAIL` | Specifies the committer's email | `${GITHUB_ACTOR}@users.noreply.github.com` | A valid email address
`GIT_FORCE` | Whether to add the `--force` flag to `git push`. | `true` | A boolean (`true` or `false`), or an integer (`0` or `1`)
`OVERRIDE_GH_PAGES_BRANCH` | Whether to override the contents of the existing branch with the contents of the build. (Should be used with `GIT_FORCE` set to `false`) | `false` | A boolean (`true` or `false`), or an integer (`0` or `1`)
`GH_PAGES_ADD_NO_JEKYLL` | Whether to add the `.nojekyll` file to the branch to indicate that it should not be compiled with Jekyll. | `true` | A boolean (`true` or `false`), or an integer `0` or `1`)

### Other

Name | Description | Default | Allowed values
---|---|---|---
`GH_PAGES_COMMIT_PRE_COMMANDS` | Commands to be executed before committing to the `gh-pages` branch. | No default | Any valid command (to be executed by `eval` in a sub-shell)
`GH_PAGES_COMMIT_POST_COMMANDS` | Commands to be executed after committing to the `gh-pages` branch. | No default | Any valid command (to be executed by `eval` in a sub-shell)
`JEKYLL_BUILD_PRE_COMMANDS` | Commands to be executed before the building of the site. (This can be used to ) | No default | Any valid command (to be executed by `eval` in a sub-shell)
`JEKYLL_BUILD_POST_COMMANDS` | Commands to be executed after the building of the site. | No default | Any valid command (to be executed by `eval` in a sub-shell)

## Secrets used

This script requires the following secrets:

Name | Description | Allowed values
---|---|---
`GH_PAGES_TOKEN` | Specifies the personal access token to use to request a build request **(required)** | No default | A valid personal access token (create one [here](https://github.com/settings/tokens/new?scopes=public_repo,repo_deployment&description=Token%20for%20Deploy%20GitHub%20Pages%20GitHub%20Action) with the scopes `public_repo` and `repo_deployment` enabled)

## Arguments

This script does not take in any arguments.

## Examples

Add the following code to define an action:

```hcl
workflow "Deploy Site" {
  on = "push"
  resolves = ["Build and Deploy Jekyll"]
}

action "Build and Deploy Jekyll" {
  uses = "Chan4077/actions/githubPages@master"
  secrets = ["GH_PAGES_TOKEN"]
}
```
