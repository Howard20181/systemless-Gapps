SKIPUNZIP=1

getprop2() {
    grep -m 1 "^$2=" "$1" | cut -d= -f2
}

GAPPS_PATH="/sdcard/Download/MindTheGapps.zip"
[ -f "$GAPPS_PATH" ] || abort "MindTheGapps not found in $GAPPS_PATH"
unzip "$GAPPS_PATH" "build.prop" -d "$TMPDIR"
GAPPS_ARCH=$(getprop2 "$TMPDIR/build.prop" arch)
GAPPS_VERSION=$(getprop2 "$TMPDIR/build.prop" version)
gapps_version_nice=$(getprop2 "$TMPDIR/build.prop" version_nice)
ui_print "MindTheGapps for $GAPPS_ARCH Android $gapps_version_nice"
if [ "$ARCH" != "$GAPPS_ARCH" ]; then
    abort "This package is built for $GAPPS_ARCH but your device is $ARCH! Aborting"
fi
if [ "$API" != "$GAPPS_VERSION" ]; then
    android_version_nice=$(getprop ro.build.version.release)
    abort "This package is for Android $gapps_version_nice (SDK $GAPPS_VERSION) but your system is Android $android_version_nice (SDK $API)! Aborting"
fi
ui_print "Extract MindTheGapps"
if ! unzip "$GAPPS_PATH" "system/*" -x "system/addon.d/*" "system/product/priv-app/VelvetTitan/*" "system/system_ext/priv-app/SetupWizard/*" -d "$MODPATH"; then
    abort "Unzip MindTheGapps failed, package is corrupted?"
fi
unzip "$ZIPFILE" "system/*" -d "$MODPATH"
unzip "$ZIPFILE" "module.prop" -d "$MODPATH"
unzip "$ZIPFILE" "sepolicy.rule" -d "$MODPATH"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/product/lib" 0 0 0755 0644 "u:object_r:system_lib_file:s0"
set_perm_recursive "$MODPATH/system/product/lib64" 0 0 0755 0644 "u:object_r:system_lib_file:s0"
