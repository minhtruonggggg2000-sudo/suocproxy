# OGIOS Safe Edition

A clean SwiftUI iOS app based on the original OGIOS visual direction. This safe rebuild intentionally excludes kernel exploits, sandbox escapes, anti-detection code, device/game patching, patch payloads, and license/key bypass components.

## Included
- Neon dark SwiftUI dashboard and device/iOS version display.
- Settings sheet.
- Private in-app document library: import, share, and delete files copied into this app's Documents folder.
- Link to the official Free Fire website.
- iOS 16.0+ deployment target.

## Not included
- Kernel or sandbox exploitation, jailbreak functionality, anti-detection routines.
- Modifying Free Fire or other apps, aim/cheat patches, system-wide cache cleaning, or access to another app's private data.
- Original `.3105` patch payloads and exploit binaries.

## Build on Windows
You can edit the Swift files in VS Code on Windows, but a native iOS device build requires macOS with Xcode. This repository includes a GitHub Actions workflow so the build can run on a GitHub-hosted macOS runner.

1. Create a GitHub repository and upload this folder's contents.
2. Open **Actions** → **Build unsigned iOS IPA** → **Run workflow**.
3. When complete, open the workflow run and download the `OGIOSSafe-unsigned-IPA` artifact.
4. The resulting IPA is unsigned. It must be signed with a valid Apple development/distribution certificate and provisioning profile before it can be installed on a physical iPhone.

## Build locally on macOS
Open `OGIOSSafe.xcodeproj` in Xcode, select the `OGIOSSafe` scheme and an iPhone destination, then build. To install on your own device, configure your Apple Developer Team under Signing & Capabilities.
