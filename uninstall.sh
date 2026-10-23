#!/system/bin/sh
# Enable stock WebViews
pm enable com.google.android.webview >/dev/null 2>&1
pm enable com.android.webview >/dev/null 2>&1
pm enable com.google.android.trichromelibrary >/dev/null 2>&1

#delete vanadium
pm uninstall app.vanadium.webview 2>/dev/null
pm uninstall app.vanadium.trichromelibrary 2>/dev/null
# Configure WebView provider
#cmd webviewsetup enable com.google.android.webview
#cmd webviewupdate set-webview-implementation com.google.android.webview

exit 0