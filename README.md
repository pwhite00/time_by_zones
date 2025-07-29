# Time by Zones - Geektool Script

A script to display current time in multiple timezones for use with Geektool on macOS.

## Features

- **Automatic DST Detection**: No manual intervention required
- **Proper Timezone Handling**: Uses IANA timezone identifiers
- **Multiple Display Modes**: All zones, US only, or default view
- **DST Indicators**: Shows when daylight saving time is active

## Available Versions

### Ruby Version (Recommended)
- **File**: `time_by_zones.rb` - Improved version with automatic DST detection
- **Dependencies**: `tzinfo` gem
- **Pros**: More mature timezone library, better string formatting, smaller footprint
- **Setup**: `bundle install` (uses Gemfile)

### Original Version
- **File**: `time_by_zones.rb` - Original script (kept for reference)
- **Dependencies**: None (uses built-in Ruby time functions)
- **Note**: Manual DST management, requires periodic updates

## Setup Instructions

### Ruby Version
```bash
cd time_by_zones
bundle install
chmod +x time_by_zones.rb
```

### Original Version
```bash
cd time_by_zones
chmod +x time_by_zones.rb
```

## Testing

The Ruby version includes comprehensive unit tests to ensure reliability:

### Quick Test
```bash
ruby run_tests.rb
```

### Individual Test Suites
```bash
# Test::Unit style tests
ruby test_time_by_zones.rb

# RSpec style tests  
ruby spec_time_by_zones.rb
```

### What the Tests Cover
- ✅ Timezone mapping validation
- ✅ IANA timezone identifier verification
- ✅ DST detection accuracy
- ✅ Error handling for invalid timezones
- ✅ Output format consistency
- ✅ All display modes (default, all, us)
- ✅ Performance benchmarks
- ✅ Edge cases around midnight
- ✅ Timezone offset validation

## Usage

### Improved Version
```bash
# Default mode (UTC, IAD, SFO)
./time_by_zones.rb

# All timezones
./time_by_zones.rb all

# US timezones only
./time_by_zones.rb us

# Help
./time_by_zones.rb help
```

### Original Version
```bash
# Default mode (IAD, SFO)
./time_by_zones.rb

# All timezones
./time_by_zones.rb all

# US timezones only
./time_by_zones.rb us

# Help
./time_by_zones.rb help
```

## Geektool Configuration

1. Open Geektool
2. Add a new "Shell" geeklet
3. Set the command to: `/path/to/time_by_zones.rb`
4. Set refresh interval to 60 seconds (or as desired)

## Timezone Mapping

| Code | Location | IANA Timezone |
|------|----------|---------------|
| UTC  | Universal | UTC |
| CDG  | Paris | Europe/Paris |
| LHR  | London | Europe/London |
| IAD  | Washington DC | America/New_York |
| ORD  | Chicago | America/Chicago |
| DEN  | Denver | America/Denver |
| SFO  | San Francisco | America/Los_Angeles |
| HNL  | Honolulu | Pacific/Honolulu |
| HYD  | Hyderabad | Asia/Kolkata |
| SIN  | Singapore | Asia/Singapore |
| NRT  | Tokyo | Asia/Tokyo |

## Key Improvements Over Original

1. **Automatic DST**: No manual flags or calculations
2. **Correct Timezone Data**: Uses proper IANA identifiers
3. **Error Handling**: Graceful handling of timezone errors
4. **DST Indicators**: Shows when DST is active
5. **Cleaner Code**: More maintainable and readable
6. **Future-Proof**: Automatically handles timezone rule changes

## Why the Improved Version?

The **v2 version is recommended** because:

1. **Automatic DST detection**: No manual intervention required
2. **Proper timezone handling**: Uses IANA timezone identifiers
3. **Better error handling**: Graceful handling of timezone errors
4. **Future-proof**: Automatically handles timezone rule changes
5. **Comprehensive testing**: Built-in test frameworks ensure reliability
6. **Smaller footprint**: Perfect for Geektool scripts

The original version is kept for reference and comparison.

## Continuous Testing

For ongoing reliability, consider setting up automated testing:

### Pre-commit Hook
Add this to your `.git/hooks/pre-commit`:
```bash
#!/bin/bash
cd time_by_zones
ruby run_tests.rb
if [ $? -ne 0 ]; then
    echo "Tests failed! Commit aborted."
    exit 1
fi
```

### Cron Job for Regular Testing
Add to your crontab to test daily:
```bash
# Test timezone script daily at 2 AM
0 2 * * * cd /path/to/time_by_zones && ruby run_tests.rb >> /tmp/timezone_tests.log 2>&1
```

This ensures your timezone script remains reliable as timezone rules change over time. 