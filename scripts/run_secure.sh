#!/bin/bash

# Secure run script for RISAQ
# This script loads environment variables from .env and runs Flutter with --dart-define

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure your values.${NC}"
    echo "  cp .env.example .env"
    exit 1
fi

# Load environment variables from .env
export $(grep -v '^#' .env | xargs)

# Build dart-define arguments
DART_DEFINES=""

# Function to add dart-define if variable exists
add_define() {
    local var_name=$1
    local var_value=${!var_name}
    
    if [ ! -z "$var_value" ]; then
        DART_DEFINES="$DART_DEFINES --dart-define=$var_name=$var_value"
        echo -e "${GREEN}✓${NC} $var_name configured"
    else
        echo -e "${YELLOW}⚠${NC}  $var_name not set"
    fi
}

echo -e "${BLUE}Loading configuration...${NC}"
echo "------------------------"

# Add all configuration variables
add_define "ENVIRONMENT"
add_define "DEBUG_MODE"
add_define "SUPABASE_URL"
add_define "SUPABASE_ANON_KEY"
add_define "OPENAI_API_KEY"
add_define "GOOGLE_MAPS_API_KEY"
add_define "SENTRY_DSN"
add_define "MIXPANEL_TOKEN"
add_define "AMPLITUDE_API_KEY"
add_define "ENABLE_CRASHLYTICS"
add_define "ENABLE_ANALYTICS"
add_define "ENABLE_PERFORMANCE_MONITORING"

echo "------------------------"

# Parse command line arguments
COMMAND="run"
DEVICE=""
FLAVOR=""
EXTRA_ARGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        build)
            COMMAND="build"
            shift
            ;;
        test)
            COMMAND="test"
            shift
            ;;
        -d|--device)
            DEVICE="-d $2"
            shift 2
            ;;
        --flavor)
            FLAVOR="--flavor $2"
            shift 2
            ;;
        --release)
            EXTRA_ARGS="$EXTRA_ARGS --release"
            shift
            ;;
        --profile)
            EXTRA_ARGS="$EXTRA_ARGS --profile"
            shift
            ;;
        --debug)
            EXTRA_ARGS="$EXTRA_ARGS --debug"
            shift
            ;;
        apk|appbundle|ios|ipa|web|macos|windows|linux)
            EXTRA_ARGS="$EXTRA_ARGS $1"
            shift
            ;;
        *)
            EXTRA_ARGS="$EXTRA_ARGS $1"
            shift
            ;;
    esac
done

# Run Flutter with secure configuration
echo -e "\n${BLUE}Running Flutter ${COMMAND}...${NC}"
echo "------------------------"

if [ "$COMMAND" = "test" ]; then
    # For tests, we might want different defines
    flutter test $EXTRA_ARGS $DART_DEFINES
else
    flutter $COMMAND $DEVICE $FLAVOR $EXTRA_ARGS $DART_DEFINES
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n${GREEN}✅ Flutter $COMMAND completed successfully!${NC}"
else
    echo -e "\n${RED}❌ Flutter $COMMAND failed with exit code $EXIT_CODE${NC}"
fi

exit $EXIT_CODE