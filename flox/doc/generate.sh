#!/bin/bash

# This script creates a nice API reference documentation for the Flox source
# and installs it in Xcode.
# 
# To execute it, you need the "AppleDoc"-tool. Download it here: 
# http://www.gentlebytes.com/home/appledocapp/

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` [version]"
  echo "  (version like '1.0')"
  exit 1
fi

appledoc \
  --project-name "Flox SDK (Objective-C)" \
  --project-company "Gamua" \
  --company-id com.gamua \
  --project-version "$version" \
  --explicit-crossref \
  --ignore ".m" \
  --ignore "_Internal.h" \
  --ignore "FXRestService.h" \
  --ignore "FXURLConnection.h" \
  --ignore "FXPersistentQueue.h" \
  --ignore "FXGameSession.h" \
  --ignore "FXCapabilities.h" \
  --ignore "FXInstallationData.h" \
  --keep-undocumented-objects \
  --keep-undocumented-members \
  --keep-intermediate-files \
  --no-warn-missing-arg \
  --no-warn-undocumented-object \
  --no-warn-undocumented-member \
  --no-warn-empty-description \
  --docset-bundle-id "com.gamua.docset" \
  --docset-bundle-name "Flox SDK" \
  --docset-atom-filename "docset.atom" \
  --docset-feed-url    "http://www.gamua.com/flox/docs/objc/feed/%DOCSETATOMFILENAME" \
  --docset-package-url "http://www.gamua.com/flox/docs/objc/feed/%DOCSETPACKAGEFILENAME" \
  --publish-docset \
  --output . \
  ../src/Classes

echo
echo "Finished."
