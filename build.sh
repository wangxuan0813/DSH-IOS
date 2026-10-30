#!/bin/bash
# Run on macOS with Xcode; no phone access and no credentials are used.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p work dist/Frameworks logs
exec > >(tee logs/build.log) 2>&1
date -u
uname -a
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
ZIP=nodejs-mobile-ios-24.22.1-0.zip
URL="https://github.com/fogtape/nodejs-mobile/releases/download/v24.22.1-0/$ZIP"
SHA=3fa1b8fb0720768b01c2e0dae3a17e788476e8c1613a1d9a54e206793b45326e
curl --fail --location --retry 3 "$URL" -o "work/$ZIP"
printf '%s  %s\n' "$SHA" "work/$ZIP" | shasum -a 256 -c -
unzip -oq "work/$ZIP" -d work/sdk
SOURCE=work/sdk/NodeMobile.xcframework/ios-arm64/NodeMobile.framework
FRAMEWORK=dist/Frameworks/NodeMobile.framework
cp -R "$SOURCE" dist/Frameworks/
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
# Explicit iOS-device target. Never use the ios-arm64-simulator slice.
xcrun --sdk iphoneos clang \
  -target arm64-apple-ios15.0 -isysroot "$SDK" -O2 \
  launcher.c -Fdist/Frameworks -framework NodeMobile \
  -Wl,-rpath,@executable_path/Frameworks -o dist/node
file dist/node "$FRAMEWORK/NodeMobile"
otool -L dist/node "$FRAMEWORK/NodeMobile" | tee logs/dylibs.txt
otool -l dist/node > logs/launcher-load-commands.txt
otool -l "$FRAMEWORK/NodeMobile" > logs/framework-load-commands.txt
nm -gU "$FRAMEWORK/NodeMobile" | grep -E ' (_node_start|_napi_register_module_v1)$' > logs/entry-symbols.txt
# Reuse the entitlement model documented by node-ios for Dopamine.
# Signing is an artifact-preparation step, not proof that the device trusts it.
codesign --force --sign - --timestamp=none "$FRAMEWORK"
codesign --force --sign - --timestamp=none --entitlements entitlements.plist dist/node
codesign --verify --verbose=2 "$FRAMEWORK"
codesign --verify --verbose=2 dist/node
codesign -d --entitlements :- dist/node > logs/launcher-entitlements.plist 2> logs/codesign-details.txt
shasum -a 256 dist/node "$FRAMEWORK/NodeMobile" | tee dist/SHA256SUMS
cp entitlements.plist dist/
printf '%s\n' 'Build only. iPhone execution, HTTPS, SQLite, spawn and Harness remain UNTESTED.' > dist/VALIDATION_STATUS.txt
tar -czf node24.22.1-ios15-arm64-cli.tar.gz -C dist .
shasum -a 256 node24.22.1-ios15-arm64-cli.tar.gz
printf '%s\n' 'BUILD_COMPLETE_DEVICE_NOT_TESTED'
