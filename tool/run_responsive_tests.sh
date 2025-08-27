#!/bin/bash

# Script to run all responsive and PWA tests for RISAQ
# This includes unit tests, widget tests, and integration tests

echo "🧪 Running Responsive & PWA Tests for RISAQ"
echo "==========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test and track results
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    echo "----------------------------------------"
    
    if eval $test_command; then
        echo -e "${GREEN}✅ $test_name PASSED${NC}\n"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $test_name FAILED${NC}\n"
        ((TESTS_FAILED++))
    fi
}

# 1. Run unit tests for responsive components
run_test "Responsive Breakpoints Unit Tests" \
    "flutter test test/widgets/responsive_test.dart"

# 2. Run unit tests for desktop interactions
run_test "Desktop Interactions Unit Tests" \
    "flutter test test/widgets/desktop_interactions_test.dart"

# 3. Run unit tests for adaptive navigation
run_test "Adaptive Navigation Unit Tests" \
    "flutter test test/widgets/modern_home_responsive_test.dart"

# 4. Check PWA configuration
echo -e "${YELLOW}Checking PWA Configuration${NC}"
echo "----------------------------------------"
dart run tool/check_pwa.dart
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ PWA Configuration Check PASSED${NC}\n"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ PWA Configuration Check FAILED${NC}\n"
    ((TESTS_FAILED++))
fi

# 5. Run integration tests (if on a real device or emulator)
echo -e "${YELLOW}Integration Tests${NC}"
echo "----------------------------------------"
echo "To run integration tests, you need a connected device or emulator."
echo "Run these commands separately:"
echo ""
echo "  # For responsive integration tests:"
echo "  flutter test integration_test/responsive_integration_test.dart"
echo ""
echo "  # For desktop interaction tests:"
echo "  flutter test integration_test/desktop_interaction_test.dart"
echo ""
echo "  # For PWA configuration tests:"
echo "  flutter test integration_test/pwa_integration_test.dart"
echo ""

# 6. Run web-specific tests
if command -v chromedriver &> /dev/null; then
    echo -e "${YELLOW}Web Tests (Chrome)${NC}"
    echo "----------------------------------------"
    
    # Start chromedriver in background
    chromedriver --port=4444 &
    CHROME_PID=$!
    sleep 2
    
    # Run web tests
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target=test/integration/responsive_integration_test.dart \
        -d web-server \
        --browser-name=chrome
    
    # Stop chromedriver
    kill $CHROME_PID 2>/dev/null
else
    echo -e "${YELLOW}⚠️  ChromeDriver not found. Skipping web tests.${NC}"
    echo "Install ChromeDriver to run web-specific tests."
fi

# 7. Generate coverage report (optional)
echo ""
echo -e "${YELLOW}Coverage Report${NC}"
echo "----------------------------------------"
echo "To generate a coverage report, run:"
echo "  flutter test --coverage"
echo "  genhtml coverage/lcov.info -o coverage/html"
echo "  open coverage/html/index.html"

# Summary
echo ""
echo "==========================================="
echo -e "${YELLOW}TEST SUMMARY${NC}"
echo "==========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed successfully!${NC}"
    echo "Your responsive implementation is working correctly."
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please review the output above.${NC}"
    exit 1
fi