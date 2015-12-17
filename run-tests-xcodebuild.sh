#!/bin/bash

readonly PROJECT_NAME="PEHateoas-Client"
readonly SDK_VERSION="9.2"
readonly ARCH="i386"
export LC_CTYPE=en_US.UTF-8

xcodebuild \
-workspace ${PROJECT_NAME}.xcworkspace \
-scheme ${PROJECT_NAME}Tests \
-configuration Debug \
-sdk iphonesimulator${SDK_VERSION} \
-arch ${ARCH} test
