#!/system/bin/sh

# Desacoplar completamente el proceso para que sobreviva en segundo plano
(
    # 1. Esperar a que Android termine de arrancar completamente
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 2
    done

    # 2. Esperar 5 segundos adicionales para que el PackageManager esté listo
    sleep 5

    # 3. Restaurar y habilitar los WebViews originales del sistema
    for PKG in com.google.android.webview com.android.webview com.google.android.trichromelibrary; do
        pm unhide "$PKG" 2>/dev/null
        pm default-state --user 0 "$PKG" 2>/dev/null
        pm enable --user 0 "$PKG" 2>/dev/null
        pm enable "$PKG" 2>/dev/null
    done

    # 4. Desinstalar los paquetes de Vanadium instalados en /data
    pm uninstall app.vanadium.webview 2>/dev/null
    pm uninstall app.vanadium.trichromelibrary 2>/dev/null

) >/dev/null 2>&1 &

exit 0