#!/bin/bash

echo "Checking if Google Play App Signing SHA-1 is in google-services.json..."
echo ""

SHA1_TO_FIND="6922a8b733b2b822ac24d454d2a35e3bea49f21b"

if grep -q "$SHA1_TO_FIND" android/app/google-services.json; then
    echo "✅ SUCCESS: Google Play App Signing SHA-1 is found in google-services.json"
    echo ""
    echo "Current SHA-1 fingerprints in file:"
    grep -A 2 "certificate_hash" android/app/google-services.json
else
    echo "❌ ERROR: Google Play App Signing SHA-1 is MISSING from google-services.json"
    echo ""
    echo "Expected SHA-1: $SHA1_TO_FIND"
    echo ""
    echo "Current SHA-1 fingerprints in file:"
    grep -A 2 "certificate_hash" android/app/google-services.json
    echo ""
    echo "ACTION REQUIRED:"
    echo "1. Add SHA-1 to Firebase Console"
    echo "2. Download updated google-services.json"
    echo "3. Replace android/app/google-services.json"
fi

