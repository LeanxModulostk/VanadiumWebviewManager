#!/system/bin/sh
MODDIR=${0%/*}

# Esperar a que el arranque termine
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Arranque completo: reiniciar contador anti-bootloop
echo 0 > "$MODDIR/.bootcount"

# Asegurar que Vanadium sea el WebView activo
cmd webviewupdate set-webview-implementation app.vanadium.webview 2>/dev/null || true

# Sincronizar version y versionCode de module.prop con el WebView instalado
sh "$MODDIR/syncprop.sh"

exit 0
