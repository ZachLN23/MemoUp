#!/usr/bin/env python3
"""Prepares the generated android/ folder for MemoUp's closed-app reminders.

Run once, from the project root, AFTER `flutter create --platforms=android .`:

    python3 tools/setup_android.py

It adds the notification permissions + receivers to AndroidManifest.xml,
turns on core-library desugaring in the app's Gradle file (required by
flutter_local_notifications), and names the app "MemoUp". Safe to run twice.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT / "android" / "app"
MANIFEST = APP / "src" / "main" / "AndroidManifest.xml"

PERMISSIONS = """    <!-- MemoUp reminders -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
"""

RECEIVERS = """        <!-- MemoUp reminders: fire scheduled alarms, survive reboot, handle buttons -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
"""


def patch_manifest(text: str) -> str:
    if "MemoUp reminders" in text:
        return text
    text, n = re.subn(r"(\s*)<application", lambda m: "\n" + PERMISSIONS + m.group(1) + "<application", text, count=1)
    if n != 1:
        sys.exit("Could not find <application> in AndroidManifest.xml")
    text, n = re.subn(r"</application>", RECEIVERS + "    </application>", text, count=1)
    if n != 1:
        sys.exit("Could not find </application> in AndroidManifest.xml")
    # Let the reminder light up the screen / show over the lock screen.
    if "showWhenLocked" not in text:
        text, n = re.subn(r"<activity\b", '<activity\n            android:showWhenLocked="true"\n            android:turnScreenOn="true"', text, count=1)
        if n != 1:
            sys.exit("Could not find <activity> in AndroidManifest.xml")
    text = re.sub(r'(<application\b[^>]*?android:label=")[^"]*(")', r"\1MemoUp\2", text, count=1, flags=re.S)
    return text


def patch_gradle(path: pathlib.Path) -> None:
    text = path.read_text()
    kts = path.suffix == ".kts"
    if "desugar_jdk_libs" in text:
        return
    flag = "isCoreLibraryDesugaringEnabled = true" if kts else "coreLibraryDesugaringEnabled true"
    dep = ('coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' if kts
           else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'")
    text, n = re.subn(r"(compileOptions\s*\{)", lambda m: m.group(1) + "\n        " + flag, text, count=1)
    if n != 1:
        sys.exit(f"Could not find compileOptions in {path.name}")
    if re.search(r"^dependencies\s*\{", text, flags=re.M):
        text = re.sub(r"(^dependencies\s*\{)", lambda m: m.group(1) + "\n    " + dep, text, count=1, flags=re.M)
    else:
        text = text.rstrip() + "\n\ndependencies {\n    " + dep + "\n}\n"
    path.write_text(text)


def main() -> None:
    if not MANIFEST.exists():
        sys.exit("android/ not found. Run `flutter create --platforms=android .` first.")
    MANIFEST.write_text(patch_manifest(MANIFEST.read_text()))
    gradle = next((p for p in (APP / "build.gradle.kts", APP / "build.gradle") if p.exists()), None)
    if gradle is None:
        sys.exit("Could not find android/app/build.gradle(.kts)")
    patch_gradle(gradle)
    print("Android is ready for MemoUp reminders.")


if __name__ == "__main__":
    main()
