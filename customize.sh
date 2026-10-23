ui_print "************************************"
ui_print "   Vanadium WebView Installer       "
ui_print "************************************"

# Check Android API (Requires Android 14 / API 34+)
[ "$API" -lt 34 ] && abort "Error: Android 14+ (API 34+) is required!"

# Check Architecture
[ "$ARCH" != "arm64" ] && abort "Error: Only arm64 architecture is supported!"

# Give execution permissions to binaries
chmod 0755 "$MODPATH/bin/curl"
chmod 0755 "$MODPATH/vmgr.sh"
chmod 0755 "$MODPATH/syncprop.sh"

# Detect LineageOS ROMs
if getprop | grep -qi "lineage"; then
    WVP="system/product/app/VWV"
else
    WVP="system/app/VWV"
fi

mkdir -p "$MODPATH/$WVP"

# GitLab URL for Vanadium WebView
BASE_URL="https://gitlab.com/grapheneos/platform_external_vanadium/-/raw/17/prebuilt"
WV_URL="$BASE_URL/arm64-multilib/VanadiumWebView.apk"
TARGET_APK="$MODPATH/$WVP/VWV.apk"

ui_print "- Connecting to GitLab..."

# 1. Obtener tamaño total en bytes con petición HEAD
TOTAL_BYTES=$("$MODPATH/bin/curl" -sIL --connect-timeout 10 --dns-servers 1.1.1.1,1.0.0.1 "$WV_URL" \
    | grep -i '^content-length:' | tail -n1 | tr -d '\r' | awk '{print $2}')

[ -z "$TOTAL_BYTES" ] && TOTAL_BYTES=0
TOTAL_MB=$(( TOTAL_BYTES / 1048576 ))

if [ "$TOTAL_MB" -gt 0 ]; then
    ui_print "- Download size: ~${TOTAL_MB} MB"
fi

ui_print "- Downloading Vanadium WebView:"

# 2. Iniciar descarga en segundo plano con curl silencioso
"$MODPATH/bin/curl" -s --fail --location --connect-timeout 20 --retry 3 \
    --dns-servers 1.1.1.1,1.0.0.1 -o "$TARGET_APK" "$WV_URL" &
CURL_PID=$!

# 3. Monitor de progreso visual en tiempo real
LAST_STEP=0
while kill -0 "$CURL_PID" 2>/dev/null; do
    sleep 1
    [ -f "$TARGET_APK" ] || continue
    
    CURR_BYTES=$(stat -c %s "$TARGET_APK" 2>/dev/null || wc -c < "$TARGET_APK" 2>/dev/null || echo 0)
    
    if [ "$TOTAL_BYTES" -gt 0 ]; then
        PCT=$(( CURR_BYTES * 100 / TOTAL_BYTES ))
        STEP=$(( PCT / 10 )) # Cada 10%
        
        if [ "$STEP" -gt "$LAST_STEP" ] && [ "$STEP" -le 10 ]; then
            LAST_STEP=$STEP
            CURR_MB=$(( CURR_BYTES / 1048576 ))
            
            case $STEP in
                1) BAR="██░░░░░░░░░░░░░░░░░░" ;;
                2) BAR="████░░░░░░░░░░░░░░░░" ;;
                3) BAR="██████░░░░░░░░░░░░░░" ;;
                4) BAR="████████░░░░░░░░░░░░" ;;
                5) BAR="██████████░░░░░░░░░░" ;;
                6) BAR="████████████░░░░░░░░" ;;
                7) BAR="██████████████░░░░░░" ;;
                8) BAR="████████████████░░░░" ;;
                9) BAR="██████████████████░░" ;;
               10) BAR="████████████████████" ;;
            esac
            
            ui_print "  [$BAR] $(( STEP * 10 ))% (${CURR_MB}MB / ${TOTAL_MB}MB)"
        fi
    fi
done

# 4. Esperar finalización del proceso de descarga
wait "$CURL_PID"
RC=$?

if [ $RC -ne 0 ] || [ ! -s "$TARGET_APK" ]; then
    rm -f "$TARGET_APK"
    abort "Error: Download failed or connection timed out!"
fi

# Asegurar 100% mostrado
if [ "$LAST_STEP" -lt 10 ] && [ "$TOTAL_MB" -gt 0 ]; then
    ui_print "  [████████████████████] 100% (${TOTAL_MB}MB / ${TOTAL_MB}MB)"
fi

chmod 0644 "$TARGET_APK"
ui_print "- Download completed successfully."

# Find active overlay partition
if getprop | grep -qi "lineage" || [ -d /system/product/overlay ]; then
    OVERLAY_PATH="system/product/overlay"
elif [ -d /system_ext/overlay ]; then
    OVERLAY_PATH="system/system_ext/overlay"
elif [ -d /system/overlay ]; then
    OVERLAY_PATH="system/overlay"
elif [ -d /system/vendor/overlay ]; then
    OVERLAY_PATH="system/vendor/overlay"
else
    abort "No valid overlay directory found on device!"
fi

ui_print "- Installing WebView overlay into /$OVERLAY_PATH..."
mkdir -p "$MODPATH/$OVERLAY_PATH"
mv "$MODPATH/overlay/CustomWebViewOverlay.apk" "$MODPATH/$OVERLAY_PATH/CustomWebViewOverlay.apk"
chmod 0644 "$MODPATH/$OVERLAY_PATH/CustomWebViewOverlay.apk"

# Cleanup temporary files
rm -rf "$MODPATH/overlay" "$MODPATH/apks"

ui_print "- Disabling conflicting WebView packages..."

for PKG in com.android.webview com.google.android.webview com.google.android.trichromelibrary; do
    if pm list packages | grep -q "$PKG"; then
        pm disable "$PKG" 2>/dev/null
        pm disable-user --user 0 "$PKG" 2>/dev/null
        pm hide "$PKG" 2>/dev/null
    fi
done

ui_print "- Installation complete!"
