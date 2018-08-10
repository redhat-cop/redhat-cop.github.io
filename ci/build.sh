#!/bin/bash

# enable error reporting to the console
set -e

rm -rf ./_site/
# build site with jekyll, by default to `_site' folder
bundle install
bundle exec jekyll build
bundle exec htmlproofer ./_site --check-html
