#!/system/bin/sh
MODDIR=${0%/*}

# Esperar a que el arranque termine
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Instalar solo si el paquete no existe
if ! pm path app.vanadium.webview >/dev/null 2>&1; then
    if [ -f "$MODDIR/system/product/app/VWV/VWV.apk" ]; then
        VWV_PATH="$MODDIR/system/product/app/VWV/VWV.apk"
    elif [ -f "$MODDIR/system/app/VWV/VWV.apk" ]; then
        VWV_PATH="$MODDIR/system/app/VWV/VWV.apk"
    elif [ -f /system/product/app/VWV/VWV.apk ]; then
        VWV_PATH="/system/product/app/VWV/VWV.apk"
    else
        VWV_PATH="/system/app/VWV/VWV.apk"
    fi

    pm install -r --abi arm64-v8a "$VWV_PATH" 2>/dev/null || true
fi

# Asegurar que Vanadium sea el WebView activo
cmd webviewupdate set-webview-implementation app.vanadium.webview 2>/dev/null || true

# Sincronizar version y versionCode de module.prop con el WebView instalado
sh "$MODDIR/syncprop.sh"
