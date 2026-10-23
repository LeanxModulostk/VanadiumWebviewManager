#!/system/bin/sh
MODDIR=${0%/*}
BASE="https://gitlab.com/grapheneos/platform_external_vanadium/-/raw/17/prebuilt"
TMP=/data/local/tmp

# Desinstalar
if [ "$1" = "uninstall" ]; then
  case "$2" in
    browser) PKG=app.vanadium.browser ;;
    config)  PKG=app.vanadium.config ;;
    *) echo "Uso: $0 uninstall browser|config"; exit 1 ;;
  esac
  echo "Uninstalling $2..."
  pm uninstall "$PKG"
  exit $?
fi

# Instalar / actualizar
case "$1" in
  webview) URL="$BASE/arm64-multilib/VanadiumWebView.apk"; OPT="--install-location 1" ;;
  browser) URL="$BASE/arm64/VanadiumBrowser.apk" ;;
  config)  URL="$BASE/VanadiumConfig.apk" ;;
  *) echo "Uso: $0 webview|browser|config|uninstall"; exit 1 ;;
esac

APK="$TMP/vanadium_$1.apk"

echo "Downloading $1..."
"$MODDIR/bin/curl" --fail --location --connect-timeout 15 --retry 2 \
    --dns-servers 1.1.1.1,1.0.0.1 -# -o "$APK" "$URL" \
    || { echo "Download failed"; rm -f "$APK"; exit 1; }

echo "Installing..."
pm install -r $OPT "$APK"
RC=$?
rm -f "$APK"

if [ $RC -eq 0 ]; then
    echo "Done"
    # Solo el WebView define la versión del módulo
    [ "$1" = "webview" ] && sh "$MODDIR/syncprop.sh"
else
    echo "The installation failed."
fi
exit $RC