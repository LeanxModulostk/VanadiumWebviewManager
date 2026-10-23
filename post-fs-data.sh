#!/system/bin/sh
MODDIR=${0%/*}
CNT="$MODDIR/.bootcount"

COUNT=$(cat "$CNT" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$CNT"

if [ "$COUNT" -ge 3 ]; then
    echo 0 > "$CNT"
    touch "$MODDIR/disable"

    # Enable stock WebViews
    pm enable com.google.android.webview >/dev/null 2>&1
    pm enable com.android.webview >/dev/null 2>&1
    pm enable com.google.android.trichromelibrary >/dev/null 2>&1

    pm uninstall app.vanadium.webview >/dev/null 2>&1
    pm uninstall app.vanadium.trichromelibrary >/dev/null 2>&1
fi
