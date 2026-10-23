#!/system/bin/sh
MODDIR=${0%/*}
PROP="$MODDIR/module.prop"

DUMP=$(dumpsys package app.vanadium.webview 2>/dev/null)
NEW_VER=$(echo "$DUMP" | grep -m1 "versionName=" | cut -d= -f2)
NEW_CODE=$(echo "$DUMP" | grep -m1 "versionCode=" | sed 's/.*versionCode=\([0-9]*\).*/\1/')

if [ -n "$NEW_VER" ] && [ -n "$NEW_CODE" ]; then
    OLD_VER=$(grep "^version=" "$PROP" | cut -d= -f2)
    OLD_CODE=$(grep "^versionCode=" "$PROP" | cut -d= -f2)

    [ "$OLD_VER" != "$NEW_VER" ] && sed -i "s|^version=.*|version=$NEW_VER|" "$PROP"
    [ "$OLD_CODE" != "$NEW_CODE" ] && sed -i "s|^versionCode=.*|versionCode=$NEW_CODE|" "$PROP"
fi
