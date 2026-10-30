# Node 24 iOS 15 CLI build kit

This macOS build recipe creates an iOS CLI carrier from a pinned NodeMobile runtime. Its workflow uses read-only repository permissions and uploads a seven-day artifact; it does not publish releases or contact a phone. The Actions job and artifact logs determine build status. A successful job does not establish any real-device result.

The runtime is fogtape/nodejs-mobile `v24.22.1-0` full, archive SHA-256 `3fa1b8fb0720768b01c2e0dae3a17e788476e8c1613a1d9a54e206793b45326e`. Its `ios-arm64` device library is a 93,109,464-byte Mach-O arm64 dylib with LC_BUILD_VERSION iOS 14.0.0, SDK 26.5.0. The simulator library is different and must not be deployed.

The launcher links `node_start` and sets `@executable_path/Frameworks` as its rpath. NodeMobile embeds its own Node 24.22.1 and V8 jitless configuration. The CLI is a native iOS process, dynamically linked to the adjacent framework; it is not a monolithic executable. Keep the entire `Frameworks/NodeMobile.framework` directory beside `node`.

Minimum-OS load commands and a successful link do not prove all runtime symbols are compatible with iOS 15. A real iPhone run is mandatory. `process.execPath`, self-spawn, IPC, SQLite, HTTPS, workers, and built-in TypeScript handling must be verified separately. The framework's polywasm compatibility layer is not native V8 Wasm/JIT.

The entitlement template reproduces the model documented by j0shua-SYSON/node-ios. These are broad jailbreak-only entitlements; they are not an App Store distribution model. No device trust-cache or system setting is changed by this build. Device-side deployment and re-signing still require the user's explicit approval.

Fallback if this carrier fails: cross-compile Node 24.22.1 using a reviewed adaptation of node-ios's iOS SDK guards, preferably jitless first. Its current script includes Node 22/V8-specific W^X JIT edits and should not be assumed to apply to Node 24. Its workflow comments about the CPU architecture of `macos-14` are not sufficient evidence of host architecture.

Upstream source and licenses:

- https://github.com/fogtape/nodejs-mobile/tree/d4aedf536d035bf4eeab7a7a6e18b73d154d0ea5 (MIT mobile patches)
- https://github.com/nodejs/node/tree/ce7aaf1cee78b8cf0ce17364260535c418d3ed26 (Node license plus bundled third-party notices)
- https://github.com/j0shua-SYSON/node-ios/tree/deb413641ba05d1661d5dab39b1dc21504650997 (MIT prior art and entitlement model)
