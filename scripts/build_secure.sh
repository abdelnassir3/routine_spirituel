#!/bin/bash

# Secure build script for RISAQ production releases
# This script ensures no secrets are included in the build

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 RISAQ Secure Build Script${NC}"
echo "=============================="
echo ""

# Check environment
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please specify build target${NC}"
    echo "Usage: ./build_secure.sh [apk|appbundle|ios|ipa|web|macos|windows|linux]"
    exit 1
fi

BUILD_TARGET=$1
BUILD_MODE=${2:-release}

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo -e "${RED}Error: .env.production file not found!${NC}"
    echo -e "${YELLOW}Please create .env.production with production values.${NC}"
    exit 1
fi

# Load production environment variables
export $(grep -v '^#' .env.production | xargs)

echo -e "${BLUE}Pre-build checks...${NC}"
echo "------------------------"

# 1. Check for sensitive files that shouldn't be included
SENSITIVE_FILES=(
    ".env"
    ".env.local"
    ".env.development"
    "*.pem"
    "*.key"
    "*.p12"
    "*.keystore"
    "google-services.json"
    "GoogleService-Info.plist"
)

echo "Checking for sensitive files..."
FOUND_SENSITIVE=false
for pattern in "${SENSITIVE_FILES[@]}"; do
    if find . -name "$pattern" -not -path "*/\.*" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠ Warning: Found $pattern files${NC}"
        FOUND_SENSITIVE=true
    fi
done

if [ "$FOUND_SENSITIVE" = true ]; then
    echo -e "${YELLOW}⚠ Sensitive files detected. Make sure they're in .gitignore${NC}"
fi

# 2. Clean previous builds
echo -e "\n${BLUE}Cleaning previous builds...${NC}"
flutter clean
rm -rf build/
echo -e "${GREEN}✓ Clean complete${NC}"

# 3. Get dependencies
echo -e "\n${BLUE}Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"

# 4. Run code generation
echo -e "\n${BLUE}Running code generation...${NC}"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"

# 5. Run tests
echo -e "\n${BLUE}Running tests...${NC}"
if flutter test; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Tests failed. Fix issues before building.${NC}"
    exit 1
fi

# 6. Analyze code
echo -e "\n${BLUE}Analyzing code...${NC}"
if flutter analyze; then
    echo -e "${GREEN}✓ Code analysis passed${NC}"
else
    echo -e "${YELLOW}⚠ Code analysis warnings detected${NC}"
fi

# 7. Build dart-define arguments
DART_DEFINES=""
DART_DEFINES="$DART_DEFINES --dart-define=ENVIRONMENT=production"
DART_DEFINES="$DART_DEFINES --dart-define=DEBUG_MODE=false"

# Add production configs
[ ! -z "$SUPABASE_URL" ] && DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_URL=$SUPABASE_URL"
[ ! -z "$SUPABASE_ANON_KEY" ] && DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
[ ! -z "$SENTRY_DSN" ] && DART_DEFINES="$DART_DEFINES --dart-define=SENTRY_DSN=$SENTRY_DSN"
[ ! -z "$MIXPANEL_TOKEN" ] && DART_DEFINES="$DART_DEFINES --dart-define=MIXPANEL_TOKEN=$MIXPANEL_TOKEN"

# Enable production features
DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASHLYTICS=true"
DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=true"
DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_PERFORMANCE_MONITORING=true"

# 8. Build based on target
echo -e "\n${BLUE}Building for $BUILD_TARGET in $BUILD_MODE mode...${NC}"
echo "=============================="

case $BUILD_TARGET in
    apk)
        flutter build apk --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ APK built successfully${NC}"
        echo "Output: build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
        ;;
    
    appbundle)
        flutter build appbundle --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ App Bundle built successfully${NC}"
        echo "Output: build/app/outputs/bundle/${BUILD_MODE}Release/app-${BUILD_MODE}.aab"
        ;;
    
    ios)
        flutter build ios --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ iOS build completed${NC}"
        echo "Open Xcode to archive and upload to App Store"
        ;;
    
    ipa)
        flutter build ipa --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ IPA built successfully${NC}"
        echo "Output: build/ios/ipa/"
        ;;
    
    web)
        # Web builds with different renderer options
        echo "Select web renderer:"
        echo "1) HTML renderer (better compatibility)"
        echo "2) CanvasKit renderer (better performance)"
        read -p "Choice (1/2): " RENDERER_CHOICE
        
        if [ "$RENDERER_CHOICE" = "2" ]; then
            RENDERER="canvaskit"
        else
            RENDERER="html"
        fi
        
        flutter build web --$BUILD_MODE --web-renderer $RENDERER $DART_DEFINES
        
        # Optimize for PWA
        echo -e "\n${BLUE}Optimizing for PWA...${NC}"
        
        # Minify additional files
        if command -v terser &> /dev/null; then
            terser build/web/flutter_service_worker.js -o build/web/flutter_service_worker.js -c -m
            echo -e "${GREEN}✓ Service worker minified${NC}"
        fi
        
        echo -e "${GREEN}✓ Web build completed${NC}"
        echo "Output: build/web/"
        echo "Serve with: python3 -m http.server 8000 --directory build/web"
        ;;
    
    macos)
        flutter build macos --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ macOS build completed${NC}"
        echo "Output: build/macos/Build/Products/Release/RISAQ.app"
        ;;
    
    windows)
        flutter build windows --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ Windows build completed${NC}"
        echo "Output: build/windows/runner/Release/"
        ;;
    
    linux)
        flutter build linux --$BUILD_MODE --obfuscate --split-debug-info=build/symbols $DART_DEFINES
        echo -e "${GREEN}✓ Linux build completed${NC}"
        echo "Output: build/linux/x64/release/bundle/"
        ;;
    
    *)
        echo -e "${RED}Unknown build target: $BUILD_TARGET${NC}"
        exit 1
        ;;
esac

# 9. Generate build info
BUILD_INFO_FILE="build/build_info.txt"
echo "RISAQ Build Information" > $BUILD_INFO_FILE
echo "======================" >> $BUILD_INFO_FILE
echo "Build Date: $(date)" >> $BUILD_INFO_FILE
echo "Build Target: $BUILD_TARGET" >> $BUILD_INFO_FILE
echo "Build Mode: $BUILD_MODE" >> $BUILD_INFO_FILE
echo "Flutter Version: $(flutter --version | head -n 1)" >> $BUILD_INFO_FILE
echo "Dart Version: $(dart --version)" >> $BUILD_INFO_FILE
echo "Git Commit: $(git rev-parse HEAD 2>/dev/null || echo 'N/A')" >> $BUILD_INFO_FILE
echo "Git Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')" >> $BUILD_INFO_FILE

echo -e "\n${GREEN}✅ Build completed successfully!${NC}"
echo "=============================="
echo ""
echo "Next steps:"
echo "1. Test the build thoroughly"
echo "2. Upload debug symbols to Sentry (if using): build/symbols/"
echo "3. Sign the build for distribution"
echo "4. Upload to respective app store"
echo ""
echo -e "${YELLOW}⚠ Remember: Never commit production .env files to version control${NC}"