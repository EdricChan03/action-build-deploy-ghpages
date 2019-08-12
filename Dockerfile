FROM ruby:2.6

# Set the default locale so as to not cause issues in Jekyll
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

LABEL "maintainer"="Edric Chan <edric.chan.1997@gmail.com>"

LABEL "com.github.actions.name"="Build and deploy GitHub page"
LABEL "com.github.actions.description"="Builds & deploys the Jekyll site to the master branch on user pages or to the gh-pages branch on project pages."
LABEL "com.github.actions.icon"="github"
LABEL "com.github.actions.color"="green"

LABEL "repository"="https://github.com/Chan4077/actions/tree/master/githubPages"

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
