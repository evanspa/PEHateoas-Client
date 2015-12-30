#!/bin/bash

readonly PROJECT_NAME="PEHateoas-Client"
readonly SDK_VERSION="9.2"
readonly DEVICE_NAME="iPhone 5s"
readonly ARCH="i386"
export LC_CTYPE=en_US.UTF-8

xcodebuild \
test \
-workspace "${PROJECT_NAME}.xcworkspace" \
-scheme "${PROJECT_NAME}Tests" \
-configuration Debug \
-sdk iphonesimulator${SDK_VERSION} \
-destination "platform=iOS Simulator,OS=${SDK_VERSION},name=${DEVICE_NAME}"
