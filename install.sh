#!/bin/bash
#
# Installation script for time_by_zones
# Run with: ./install.sh
#

set -e  # Exit on any error

echo "TimeByZones Installation Script"
echo "================================"

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is not installed. Please install Ruby first:"
    echo "   macOS: brew install ruby"
    echo "   Ubuntu: sudo apt-get install ruby ruby-dev"
    echo "   CentOS: sudo yum install ruby ruby-devel"
    exit 1
fi

echo "✅ Ruby found: $(ruby --version)"

# Check if bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing bundler..."
    gem install bundler
fi

echo "✅ Bundler found: $(bundle --version)"

# Install gems
echo "📦 Installing dependencies..."
bundle install --path vendor/bundle

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x time_by_zones.rb
chmod +x run_timezones
chmod +x run_tests_wrapper

# Run tests to verify installation
echo "🧪 Running tests to verify installation..."
./run_tests_wrapper quick

echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "Usage:"
echo "  ./run_timezones          # Default mode"
echo "  ./run_timezones all      # All timezones"
echo "  ./run_timezones us       # US timezones only"
echo "  ./run_tests_wrapper      # Run all tests"
echo ""
echo "For Geektool:"
echo "  Command: $(pwd)/run_timezones"
echo "  Refresh: 60 seconds (recommended)"
echo ""
echo "Installation directory: $(pwd)" 