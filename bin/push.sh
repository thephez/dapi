#!/bin/sh

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
  #git checkout -b gh-pages
  #git add . *.html
  #git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
  
  # Add spec file and static page
  git add -A
  git status
  git commit -m "Travis-built spec for version ${VERSION}"
  git log --oneline -n 5

  git remote -v  
}

upload_files() {
  git remote add origin-openapi https://${GH_TOKEN}@github.com/thephez/dapi.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-openapi gh-pages 
}

setup_git
commit_website_files
upload_files
