#!/usr/bin/env bash

# Show script in output, and error if anything fails
set -xe

# Create OpenAPI spec file and copy above repo
npm run oas:generate
cp doc/swagger.json ../openapi-spec.json
head doc/swagger.json && printf "\n[...]\n" && tail doc/swagger.json

# Update this whenever the latest Node.js LTS version changes (~ every year).
# Do not forget to add this version to .travis.yml config also.
LATEST_LTS_VERSION="10"

# We want this command to succeed whether or not the Node.js version is the
# latest (so that the build does not show as failed), but _only_ the latest
# should be used to publish the module.
if [[ "$TRAVIS_NODE_VERSION" != "$LATEST_LTS_VERSION" ]]; then
  echo "Node.js v$TRAVIS_NODE_VERSION is not latest LTS version -- will not deploy with this version."
  exit 0
fi

# Ensure the tag matches the one in package.json, otherwise abort.
VERSION="$(jq -r .version package.json)"
PACKAGE_TAG=v"$VERSION"

# Check out spec branch and remove all files
git config remote.origin.fetch refs/heads/*:refs/remotes/origin/*
git fetch --unshallow
git checkout -B openapi-spec
git branch --set-upstream-to=origin/openapi-spec openapi-spec

rm -rf ../dapi/* .nyc_output
rm -f .dockerignore .env.example .eslintignore .eslintrc .gitignore .travis.yml

git stash
git pull -X theirs

# Put spec file back into folder
cp ../openapi-spec.json .

# Generate redoc static html
cd ..
npx redoc-cli bundle openapi-spec.json
head redoc-static.html
mv redoc-static.html dapi/index.html
cd dapi

## Add spec file and static page
git add -A
git commit -m "Travis-built spec for version ${VERSION}"
#git log --oneline -n 5

git remote add origin-openapi https://${GH_TOKEN}@github.com/thephez/dapi.git > /dev/null 2>&1
git pull --rebase
git push -u origin-openapi openapi-spec
#git push --quiet --set-upstream origin-openapi gh-pages

#git push https://${GH_TOKEN}@github.com/thephez/dapi.git
ls -alh

#if [[ "$PACKAGE_TAG" != "$TRAVIS_TAG" ]]; then
#  echo "Travis tag (\"$TRAVIS_TAG\") is not equal to package.json tag (\"$PACKAGE_TAG\"). Please push a correct tag and try again."
#  exit 1
#fi
#
