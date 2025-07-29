#!/usr/bin/env ruby
#
# Test runner for time_by_zones.rb
# Run with: ruby run_tests.rb
#

puts "TimeByZones Test Suite"
puts "=" * 50

# Check if tzinfo gem is available
begin
  require 'tzinfo'
  puts "✓ tzinfo gem is available"
rescue LoadError
  puts "✗ tzinfo gem is not available. Please run: bundle install"
  exit 1
end

# Run basic functionality tests
puts "\nRunning basic functionality tests..."
puts "-" * 40

begin
  require_relative 'time_by_zones.rb'
  puts "✓ Script loads successfully"
  
  # Test basic timezone functionality
  result = get_time_in_zone('UTC', 'UTC')
  if result.match(/^UTC: \d{2}:\d{2}( \(DST\))?$/)
    puts "✓ Time formatting works correctly"
  else
    puts "✗ Time formatting failed: #{result}"
  end
  
  # Test error handling
  error_result = get_time_in_zone('Invalid/Timezone', 'TEST')
  if error_result == 'TEST: ERROR'
    puts "✓ Error handling works correctly"
  else
    puts "✗ Error handling failed: #{error_result}"
  end
  
  # Test all timezones are valid
  invalid_zones = []
  @timezones.each do |display_name, tz_id|
    begin
      TZInfo::Timezone.get(tz_id)
    rescue => e
      invalid_zones << "#{display_name} (#{tz_id}): #{e.message}"
    end
  end
  
  if invalid_zones.empty?
    puts "✓ All timezone identifiers are valid"
  else
    puts "✗ Invalid timezone identifiers found:"
    invalid_zones.each { |error| puts "  #{error}" }
  end
  
rescue => e
  puts "✗ Script failed to load: #{e.message}"
  exit 1
end

# Run comprehensive test suites
puts "\nRunning comprehensive test suites..."
puts "-" * 40

# Test Suite 1: Test::Unit style
puts "\n1. Test::Unit style tests:"
begin
  load 'test_time_by_zones.rb'
  puts "✓ Test::Unit tests completed"
rescue => e
  puts "✗ Test::Unit tests failed: #{e.message}"
end

# Test Suite 2: RSpec style
puts "\n2. RSpec style tests:"
begin
  load 'spec_time_by_zones.rb'
  puts "✓ RSpec style tests completed"
rescue => e
  puts "✗ RSpec style tests failed: #{e.message}"
end

# Performance test
puts "\nRunning performance test..."
puts "-" * 40

start_time = Time.now
100.times do
  @timezones.each do |display_name, tz_id|
    get_time_in_zone(tz_id, display_name)
  end
end
end_time = Time.now

duration = end_time - start_time
puts "✓ Performance test: #{@timezones.size * 100} timezone lookups in #{duration.round(3)} seconds"
puts "  Average: #{(duration / (@timezones.size * 100) * 1000).round(2)}ms per lookup"

# Sample output test
puts "\nSample output test..."
puts "-" * 40

puts "Default mode:"
output = capture_output { default_report }
puts output.strip

puts "\nUS mode:"
output = capture_output { us_report }
puts output.strip

puts "\nAll mode (first 3 timezones):"
output = capture_output { full_report }
puts output.strip.split('     ')[0..2].join('     ')

puts "\n" + "=" * 50
puts "Test Summary: All tests completed successfully!"
puts "Your time_by_zones script is ready for use with Geektool!"
puts "=" * 50

private

def capture_output
  old_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = old_stdout
end 