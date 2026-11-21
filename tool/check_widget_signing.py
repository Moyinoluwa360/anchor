#!/usr/bin/env python3
"""Exit 0 only if provisioning profiles exist for BOTH the app and the widget
extension, and both include the shared App Group. Run on Codemagic before
adding the extension, so a missing Apple Developer setup never breaks the
main app build (it just ships without widgets).

    python3 tool/check_widget_signing.py com.exeapp.exe
"""
import glob
import os
import plistlib
import subprocess
import sys

bundle = sys.argv[1]
group = f"group.{bundle}"
folders = [
    os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles"),
    os.path.expanduser("~/Library/Developer/Xcode/UserData/Provisioning Profiles"),
]
found = {"app": False, "extension": False}
for folder in folders:
    for path in glob.glob(os.path.join(folder, "*.mobileprovision")):
        try:
            raw = subprocess.run(["security", "cms", "-D", "-i", path], capture_output=True, check=True).stdout
            ent = plistlib.loads(raw).get("Entitlements", {})
        except Exception:
            continue
        app_id = ent.get("application-identifier", "")
        groups = ent.get("com.apple.security.application-groups", [])
        if group not in groups:
            continue
        if app_id.endswith("." + bundle):
            found["app"] = True
        if app_id.endswith("." + bundle + ".widgets"):
            found["extension"] = True

missing = [k for k, ok in found.items() if not ok]
if missing:
    print(f"Widget signing not ready (no profile with {group} for: {', '.join(missing)}).")
    sys.exit(1)
print("Widget signing ready.")
