#!/bin/sh

set -e

[ -z "${GITHUB_PAT}" ] && exit 0
[ "${TRAVIS_BRANCH}" != "dev" ] && exit 0

git config --global user.email "patrick.schratz@gmail.com"
git config --global user.name "pat-s"

git clone -b gh-pages https://github.com/pat-s/pat-s.github.io.git curso-output
cd curso-output
git rm -rf .
cp -r ../public/* ./
git add --all *
git commit -m "Update curso-r" || true
git push -q origin gh-pages
