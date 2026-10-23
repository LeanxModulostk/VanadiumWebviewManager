# Vanadium Updater (Magisk / KernelSU / APatch)

Installs and updates **Vanadium WebView**, **Vanadium Browser** and **Vanadium Config** from GrapheneOS, with a WebUI to manage them. Sets Vanadium as the active system WebView.

## What is Vanadium?

Vanadium is the hardened, Chromium-based browser and Android System WebView developed by GrapheneOS, focused on security and privacy.

## Components

| Component | Package | Purpose |
|-----------|---------|---------|
| WebView | `app.vanadium.webview` | System WebView used by other apps to render web content |
| Browser | `app.vanadium.browser` | The Vanadium web browser |
| Config | `app.vanadium.config` | Configuration data for Vanadium (see below) |

## What does Vanadium Config do?

Vanadium Config is a data-only package: it has no code and requests no permissions. It ships the configuration that Vanadium reads:

- **Feature flags** applied to Vanadium.
- **Content filter lists** used by the built-in content blocker: EasyList + EasyPrivacy as the main list, plus EasyList Germany as a supplemental list when the German language is enabled.

If Config is not installed, or is not signed with the key Vanadium was built to trust, Vanadium falls back to the standard Chromium filter lists. Installing it is optional, but recommended if you want Vanadium's own blocking lists and flags.

## Features

- Install and update WebView, Browser and Config.
- Uninstall Browser and Config.
- WebUI showing the installed version of each component.
- Automatically activates Vanadium as the system WebView on every boot.
- Keeps `version` and `versionCode` in `module.prop` in sync with the installed WebView.

## Requirements

- Root with Magisk, KernelSU, KernelSU Next or APatch.
- arm64 device.
- Android 14+
- Internet connection (APKs are downloaded from the GrapheneOS GitLab).
- Module Meta (I recommend NoMount)

## Usage

1. Flash the module zip and reboot.
2. Open the WebUI:
   - **KernelSU / KSU Next / APatch:** from the module list.
   - **Magisk:** use KSUWebUI or MMRL.
3. Tap **Install** or **Update** next to each component.
4. Use **Uninstall** to remove Browser or Config.

Download time depends on your internet speed and the server.

## Notes

- Vanadium is not officially supported outside GrapheneOS. On other ROMs it can't provide all of its hardening and features, and the WebView may not work on every device or ROM.
- WebView has no uninstall button on purpose: removing the system WebView can break apps that depend on it.
- Updating from the WebUI installs over the existing package (`pm install -r`).

## Credits

- [GrapheneOS](https://grapheneos.org) for Vanadium.
- APKs are downloaded from the [Vanadium repository](https://gitlab.com/grapheneos/platform_external_vanadium).
