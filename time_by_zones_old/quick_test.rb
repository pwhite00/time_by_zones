#!/usr/bin/env ruby
#
# Quick functionality test for time_by_zones.rb
#

require 'tzinfo'
require_relative 'time_by_zones.rb'

puts 'Testing basic functionality...'

# Test UTC formatting
result = get_time_in_zone('UTC', 'UTC')
if result.match?(/^UTC: \d{2}:\d{2}( \(DST\))?$/)
  puts '✓ UTC formatting OK'
else
  puts "✗ UTC formatting failed: #{result}"
end

# Test IAD formatting with DST
result = get_time_in_zone('America/New_York', 'IAD')
if result.match?(/^IAD: \d{2}:\d{2}( \(DST\))?$/)
  puts '✓ IAD formatting OK'
else
  puts "✗ IAD formatting failed: #{result}"
end

# Test error handling
result = get_time_in_zone('Invalid/Timezone', 'TEST')
if result == 'TEST: ERROR'
  puts '✓ Error handling OK'
else
  puts "✗ Error handling failed: #{result}"
end

# Test timezone validity
invalid_zones = []
@timezones.each do |display_name, tz_id|
  begin
    TZInfo::Timezone.get(tz_id)
  rescue => e
    invalid_zones << "#{display_name} (#{tz_id}): #{e.message}"
  end
end

if invalid_zones.empty?
  puts '✓ All timezone identifiers are valid'
else
  puts '✗ Invalid timezone identifiers found:'
  invalid_zones.each { |error| puts "  #{error}" }
end

puts 'Quick test completed!' 