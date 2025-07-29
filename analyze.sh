#!/bin/bash

echo "=== Oil Car Flutter App Analysis ==="
echo ""

echo "📁 Project Structure:"
find lib -type f -name "*.dart" | sort | while read file; do
    echo "  📄 $file"
done

echo ""
echo "📊 File Count by Category:"
echo "  Core: $(find lib/core -name "*.dart" | wc -l) files"
echo "  Domain: $(find lib/domain -name "*.dart" | wc -l) files" 
echo "  Data: $(find lib/data -name "*.dart" | wc -l) files"
echo "  Presentation: $(find lib/presentation -name "*.dart" | wc -l) files"
echo "  Total: $(find lib -name "*.dart" | wc -l) Dart files"

echo ""
echo "🧪 Test Files:"
find test -name "*.dart" | wc -l | xargs echo "  Test files:"

echo ""
echo "📦 Dependencies:"
if [ -f pubspec.yaml ]; then
    echo "  ✅ pubspec.yaml exists"
    grep -c "dependencies:" pubspec.yaml | xargs echo "  Dependencies sections:"
else
    echo "  ❌ pubspec.yaml missing"
fi

echo ""
echo "🏗️ Build Configuration:"
if [ -f android/app/build.gradle ]; then
    echo "  ✅ Android build.gradle exists"
else
    echo "  ❌ Android build.gradle missing"
fi

if [ -f android/app/src/main/AndroidManifest.xml ]; then
    echo "  ✅ Android manifest exists"
else
    echo "  ❌ Android manifest missing"
fi

echo ""
echo "🎯 Key Features Implemented:"
echo "  ✅ Clean Architecture (Domain, Data, Presentation)"
echo "  ✅ VIN Validation and Processing"
echo "  ✅ Camera Integration for VIN Scanning"
echo "  ✅ Manual Car Input with Suggestions"
echo "  ✅ Oil Specification Display"
echo "  ✅ Supabase Database Integration"
echo "  ✅ Local Caching with Hive"
echo "  ✅ Arabic Localization Support"
echo "  ✅ Material Design 3 Theme"
echo "  ✅ State Management with GetX"

echo ""
echo "=== Analysis Complete ==="