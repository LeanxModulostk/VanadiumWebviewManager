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


# Otros WebViews (stock/Google): estado, desactivar, activar
if [ "$1" = "stockwv" ]; then
  STOCK="com.android.webview com.google.android.webview com.google.android.trichromelibrary"
  has() { pm list packages "$1" 2>/dev/null | grep -qx "package:$1"; }
  case "$2" in
    status)
      for P in $STOCK; do
        has "$P" || continue
        if pm list packages -d "$P" 2>/dev/null | grep -qx "package:$P"; then
          echo "$P:disabled"
        else
          echo "$P:enabled"
        fi
      done
      exit 0 ;;
    disable)
      has app.vanadium.webview || { echo "Install Vanadium WebView first"; exit 1; }
      echo "Setting Vanadium as active WebView..."
      cmd webviewupdate set-webview-implementation app.vanadium.webview >/dev/null 2>&1 \
        || { echo "Could not set Vanadium as WebView provider. Aborting."; exit 1; }
      for P in $STOCK; do
        has "$P" || continue
        echo "Disabling $P..."
        pm disable-user --user 0 "$P" >/dev/null 2>&1 || pm disable "$P" >/dev/null 2>&1
      done
      echo "Done"
      exit 0 ;;
    enable)
      for P in $STOCK; do
        has "$P" || continue
        echo "Enabling $P..."
        pm enable "$P" >/dev/null 2>&1
      done
      echo "Done"
      exit 0 ;;
    *) echo "Uso: $0 stockwv status|disable|enable"; exit 1 ;;
  esac
fi

# Instalar / actualizar
case "$1" in
  webview) URL="$BASE/arm64-multilib/VanadiumWebView.apk"; OPT="--install-location 1" ;;
  browser) URL="$BASE/arm64/VanadiumBrowser.apk" ;;
  config)  URL="$BASE/VanadiumConfig.apk" ;;
  *) echo "Uso: $0 webview|browser|config|uninstall"; exit 1 ;;
esac

APK="$TMP/vanadium_$1.apk"

# Limpiar restos de descargas anteriores y borrar el APK siempre al salir
rm -f "$TMP"/vanadium_*.apk
trap 'rm -f "$APK"' EXIT HUP INT TERM

echo "Downloading $1..."
"$MODDIR/bin/curl" --fail --location --connect-timeout 15 --retry 2 \
    --dns-servers 1.1.1.1,1.0.0.1 -# -o "$APK" "$URL" \
    || { echo "Download failed"; rm -f "$APK"; exit 1; }

echo "Installing..."
# Abrir el APK, borrarlo del disco y instalar leyendo por stdin:
# así el archivo desaparece ANTES de instalar y no depende de que el script
# siga vivo (al actualizar el WebView, Android mata procesos).
SIZE=$(stat -c %s "$APK" 2>/dev/null || wc -c < "$APK")
exec 3< "$APK"
rm -f "$APK"
pm install -r -S "$SIZE" $OPT <&3
RC=$?
exec 3<&-

if [ $RC -eq 0 ]; then
    echo "Done"
    # Solo el WebView define la versión del módulo
    [ "$1" = "webview" ] && sh "$MODDIR/syncprop.sh"
else
    echo "The installation failed."
fi
exit $RC