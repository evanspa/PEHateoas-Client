#!/bin/bash

readonly PROJECT="PEHateoas-Client"
readonly VERSION="$1"
readonly TAG_LABEL=${PROJECT}-v${VERSION}

git tag -f -a $TAG_LABEL -m 'version $version'
git push -f --tags
