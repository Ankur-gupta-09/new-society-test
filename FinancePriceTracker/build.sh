#!/bin/bash

# Finance Price Tracker - Build Script
# This script provides convenient commands for building and testing the iOS app

set -e

PROJECT_NAME="FinancePriceTracker"
SCHEME_NAME="FinancePriceTracker"
WORKSPACE="${PROJECT_NAME}.xcodeproj"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to check if Xcode is installed
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        print_color $RED "❌ Xcode command line tools not found. Please install Xcode."
        exit 1
    fi
    print_color $GREEN "✅ Xcode found"
}

# Function to clean the project
clean() {
    print_color $YELLOW "🧹 Cleaning project..."
    xcodebuild clean -project "$WORKSPACE" -scheme "$SCHEME_NAME"
    print_color $GREEN "✅ Project cleaned"
}

# Function to build the project
build() {
    print_color $YELLOW "🔨 Building project..."
    xcodebuild build -project "$WORKSPACE" -scheme "$SCHEME_NAME" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
    print_color $GREEN "✅ Build completed successfully"
}

# Function to run tests
test() {
    print_color $YELLOW "🧪 Running tests..."
    xcodebuild test -project "$WORKSPACE" -scheme "$SCHEME_NAME" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
    print_color $GREEN "✅ Tests completed"
}

# Function to build for device
build_device() {
    print_color $YELLOW "📱 Building for device..."
    xcodebuild build -project "$WORKSPACE" -scheme "$SCHEME_NAME" -destination 'generic/platform=iOS'
    print_color $GREEN "✅ Device build completed"
}

# Function to archive the project
archive() {
    print_color $YELLOW "📦 Creating archive..."
    ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
    xcodebuild archive -project "$WORKSPACE" -scheme "$SCHEME_NAME" -archivePath "$ARCHIVE_PATH"
    print_color $GREEN "✅ Archive created at: $ARCHIVE_PATH"
}

# Function to open project in Xcode
open_xcode() {
    print_color $BLUE "🚀 Opening project in Xcode..."
    open "$WORKSPACE"
}

# Function to show available simulators
show_simulators() {
    print_color $BLUE "📱 Available iOS Simulators:"
    xcrun simctl list devices iOS
}

# Function to boot simulator
boot_simulator() {
    local simulator_name=${1:-"iPhone 15"}
    print_color $YELLOW "🚀 Booting $simulator_name simulator..."
    xcrun simctl boot "$simulator_name" 2>/dev/null || print_color $YELLOW "Simulator may already be booted"
    open -a Simulator
    print_color $GREEN "✅ Simulator booted"
}

# Function to install app on simulator
install_simulator() {
    local simulator_name=${1:-"iPhone 15"}
    print_color $YELLOW "📲 Installing app on $simulator_name..."
    # This would require a built app bundle
    print_color $BLUE "Note: Run 'build' first, then manually install from Xcode"
}

# Function to show help
show_help() {
    print_color $BLUE "Finance Price Tracker - Build Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  clean           Clean the project"
    echo "  build           Build for iOS Simulator"
    echo "  test            Run unit tests"
    echo "  device          Build for iOS device"
    echo "  archive         Create archive for distribution"
    echo "  xcode           Open project in Xcode"
    echo "  simulators      Show available iOS simulators"
    echo "  boot [name]     Boot iOS simulator (default: iPhone 15)"
    echo "  install [name]  Install app on simulator"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 boot 'iPhone 15 Pro'"
    echo "  $0 test"
}

# Main script logic
main() {
    check_xcode
    
    case "${1:-help}" in
        "clean")
            clean
            ;;
        "build")
            build
            ;;
        "test")
            test
            ;;
        "device")
            build_device
            ;;
        "archive")
            archive
            ;;
        "xcode")
            open_xcode
            ;;
        "simulators")
            show_simulators
            ;;
        "boot")
            boot_simulator "$2"
            ;;
        "install")
            install_simulator "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Create build directory if it doesn't exist
mkdir -p build

# Run main function with all arguments
main "$@"