# Deploy to GitHub Pages

A GitHub Action that builds and deploys a Jekyll site to GitHub Pages.

~~This GitHub Action requires a GitHub personal access token to deploy commits. To create one, click [here](https://github.com/settings/tokens/new?scopes=public_repo,repo_deployment&description=Token%20for%20Deploy%20GitHub%20Pages%20GitHub%20Action) and specify the `GH_PAGES_TOKEN` environment variable in your GitHub repository's Secrets.~~ (Note: You no longer have to create a PAT: see the [Secrets used](#secrets-used) section for more info.)

## Usage

See [`action.yml`](./action.yml) for a list of all supported inputs.

### Secrets used

This script needs the following secrets:

Name | Description | Allowed values
---|---|---
 `GITHUB_TOKEN` | Specifies the GitHub installation token. | A valid GitHub installation token. _(Note: GitHub already creates one for you by default - you just need to manually specify this token with `${{ secrets.GITHUB_TOKEN }}` or `${{ github.token }}` in your workflow file.)_
 `GH_PAGES_TOKEN` | Specifies the personal access token to use to request a build request **(~~required~~ optional - no longer required as of 15 Feb 2020 - see this [GitHub Community post](https://github.community/t5/GitHub-Actions/Github-action-not-triggering-gh-pages-upon-push/m-p/46519/highlight/true#M6551) and [#13](https://github.com/EdricChan03/action-build-deploy-ghpages/issues/13) for more info)** | A valid personal access token (create one [here](https://github.com/settings/tokens/new?scopes=public_repo,repo_deployment&description=Token%20for%20Deploy%20GitHub%20Pages%20GitHub%20Action) with the scopes `public_repo` and `repo_deployment` enabled)

### Examples

#### Basic

```yml
steps:
  - uses: actions/checkout@v2
  - uses: EdricChan03/action-build-deploy-ghpages@v2.4.0
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      # gh_pages_token: ${{ secrets.GH_PAGES_TOKEN }} No longer needed - see https://github.community/t5/GitHub-Actions/Github-action-not-triggering-gh-pages-upon-push/m-p/46519/highlight/true#M6551 for more info
```

Alternatively, you can target the latest `v2` version of the Action:

```yml
steps:
  - uses: actions/checkout@v2
  - uses: EdricChan03/action-build-deploy-ghpages@v2
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }} # Or ${{ github.token }}
      # gh_pages_token: ${{ secrets.GH_PAGES_TOKEN }}
```

#### Environment variables (`v1`)

v2 of this GitHub Action also supports the former environment variables in v1 of the action:

```yml
steps:
  - uses: actions/checkout@v2
  - uses: EdricChan03/action-build-deploy-ghpages@v2.4.0
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # Or ${{ github.token }}
      # GH_PAGES_TOKEN: ${{ secrets.GH_PAGES_TOKEN }}
      OVERRIDE_GH_PAGES_BRANCH: 'true'
      # ...
```

#### All inputs (with defaults)

> Note: Not all of the inputs below have default values - consult the [action file](./action.yml) for more info.

```yml
steps:
  - uses: actions/checkout@v2
  - uses: EdricChan03/action-build-deploy-ghpages@v2.4.0
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }} # The GitHub installation token. Note: You can also use ${{ github.token }}
      # gh_pages_token: ${{ secrets.GH_PAGES_TOKEN }} # Note: You have to create this yourself - see the "Secrets used" section above for more info (This input does not have a default value - you have to supply this yourself) (As of 15 Feb 2020, this is no longer needed - see https://github.community/t5/GitHub-Actions/Github-action-not-triggering-gh-pages-upon-push/m-p/46519/highlight/true#M6551)
      gh_pages_branch: 'gh-pages' # The GitHub Pages branch to deploy the site to
      gh_pages_dist_folder: '_site' # The folder to build the site to
      gh_pages_commit_message: 'Deploy commit $GITHUB_SHA\n\nAutodeployed using $GITHUB_ACTION in $GITHUB_WORKFLOW' # The commit message to use when deploying the site
      jekyll_build_opts: '' # Options to pass to the Jekyll build command.
      remote_repo: 'https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git' # The repository to deploy the site to
      committer_username: '$GITHUB_ACTOR' # The username to use for the committer of the commit
      committer_email: '${GITHUB_ACTOR}@users.noreply.github.com' # The email to use for the committer of the commit
      git_force: 'true' # Whether to use the --force flag when pushing the commit
      override_gh_pages_branch: 'false' # Whether to override the gh-pages branch on push
      gh_pages_add_no_jekyll: 'true' # Whether to add the .nojekyll file to the deployed site
      skip_deploy: 'false' # Whether to skip deployment after a successful build.
      show_bundle_log: 'false' # Whether to show detailed logs from bundle install command. Useful for debugging broken builds.
```
