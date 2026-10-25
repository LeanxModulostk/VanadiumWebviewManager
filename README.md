# Vanadium WebView Manager (Magisk / KernelSU / APatch)

Installs and updates **Vanadium WebView**, **Vanadium Browser** and **Vanadium Config** from GrapheneOS, with a WebUI to manage them. Sets Vanadium as the active system WebView and includes a built-in anti-bootloop protection.

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

- Install and update WebView, Browser and Config from the WebUI.
- **Check for updates** button: compares the installed version of each component with the latest one on GitLab and highlights the ones that can be updated.
- Uninstall Browser and Config (with a confirmation dialog).
- Shows the installed version of each component.
- Automatically activates Vanadium as the system WebView on every boot.
- Keeps `version` and `versionCode` in `module.prop` in sync with the installed WebView.
- Built-in anti-bootloop protection (see below).
- Action button in the root manager opens the Telegram channel.

## Requirements

- Root with Magisk, KernelSU, KernelSU Next or APatch.
- Android 14 or newer (API 34+).
- arm64 device.
- Meta Module (I recommend NoMount)
- Internet connection, both during installation and when using the WebUI (APKs are downloaded from the GrapheneOS GitLab).

## Installation

1. Flash the module zip from your root manager.
2. The installer downloads Vanadium WebView from GitLab and shows the progress.
3. It installs the WebView overlay and disables the conflicting stock WebView packages (`com.android.webview`, `com.google.android.webview` and `com.google.android.trichromelibrary`).
4. Reboot.

On LineageOS-based ROMs the WebView is placed in `system/product/app/VWV`; on other ROMs in `system/app/VWV`.

## Usage

1. Open the WebUI:
   - **KernelSU / KSU Next / APatch:** from the module list.
   - **Magisk:** use KSUWebUI or MMRL.
2. Tap **Check for updates** to see what is new, or tap **Install** / **Update** next to each component.
3. Use **Uninstall** to remove Browser or Config.

Download time depends on your internet connection and the server.

## Anti-bootloop

The module includes an automatic protection, enabled by default. No setup or renaming is needed: it is already included as `post-fs-data.sh`.

**How it works**

1. On every boot, `post-fs-data.sh` adds 1 to a counter stored in `.bootcount`.
2. When the boot completes successfully, `service.sh` resets the counter to 0.
3. If the device fails to complete boot **3 times in a row**, the module:
   - disables itself (creates the `disable` file),
   - re-enables the stock WebView packages,
   - uninstalls Vanadium WebView and its library.

**After it triggers**

1. The device boots with the stock WebView.
2. Re-enable the module from your root manager.
3. Reinstall the WebView from the WebUI.

**Limitations**

- It only detects boots that never reach `boot_completed`. If the device boots and then reboots on its own afterwards, the counter is reset and it is not detected.
- It cannot fix a bootloop caused by something unrelated to this module.

**Manual recovery**

If your device is stuck in a bootloop and the protection did not trigger, disable the module from recovery or ADB:

```sh
touch /data/adb/modules/VanadiumWebviewManager/disable
```

To enable it again, remove that file:

```sh
rm /data/adb/modules/VanadiumWebviewManager/disable
```

## Uninstalling the module

When you remove the module from the root manager, `uninstall.sh` runs and:

- re-enables the stock WebView packages,
- uninstalls Vanadium WebView and its library.

Vanadium Browser and Vanadium Config are **not** removed automatically. Uninstall them from the WebUI before removing the module, or from Android settings afterwards.

## Notes

- Vanadium is not officially supported outside GrapheneOS. On other ROMs it can't provide all of its hardening and features, and the WebView may not work on every device or ROM.
- WebView has no uninstall button in the WebUI on purpose: removing the system WebView can break apps that depend on it.
- Updating from the WebUI installs over the existing package (`pm install -r`). Android rejects installs with a lower version than the one already installed.
- The module version shown in the manager follows the installed WebView version and is updated after each WebView update and on every boot.

## Module structure

| File | Purpose |
|------|---------|
| `customize.sh` | Installer: checks Android/arch, downloads the WebView, installs the overlay |
| `post-fs-data.sh` | Anti-bootloop counter |
| `service.sh` | Resets the counter, activates Vanadium as the WebView, syncs `module.prop` |
| `syncprop.sh` | Updates `version` and `versionCode` from the installed WebView |
| `vmgr.sh` | Downloads, installs and uninstalls components (called by the WebUI) |
| `uninstall.sh` | Restores the stock WebView when the module is removed |
| `action.sh` | Action button: opens the Telegram channel |
| `webroot/` | WebUI |
| `bin/curl` | Bundled curl used for downloads |
| `overlay/` | WebView overlay |

## Support

Telegram: [@modulostk](https://t.me/modulostk)

## Extras
- Donations: [PayPal](https://www.paypal.me/LeanHijosdesusMadres) - [LiberaPay](https://liberapay.com/LeanHijosdesusMadres) - [Ko-fi](https://ko-fi.com/leantupapi) - [Binance](https://app.binance.com/qr/dplk7b28e9c123ff4e378b472505b0adba63) - [SociaBuzz](https://sociabuzz.com/leanhijosdesusmadres/support) - [More](https://t.me/modulemagiskChiase/4846)

## Credits
- [Zackptg5](https://github.com/Zackptg5) for the MMT-Ex template
- [Topjohnwu](https://github.com/topjohnwu) for making Magisk
- [GrapheneOS](https://grapheneos.org) for Vanadium.
- APKs are downloaded from the [Vanadium repository](https://gitlab.com/grapheneos/platform_external_vanadium).
