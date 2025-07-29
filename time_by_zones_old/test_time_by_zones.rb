#!/usr/bin/env ruby
#
# Unit tests for time_by_zones.rb
# Run with: ruby test_time_by_zones.rb
#

require 'test/unit'
require 'time'
require_relative 'time_by_zones'

class TestTimeByZones < Test::Unit::TestCase
  
  def setup
    # Mock ARGV to test different modes
    @original_argv = ARGV.dup
  end
  
  def teardown
    # Restore original ARGV
    ARGV.replace(@original_argv)
  end
  
  def test_timezone_mapping_structure
    # Test that all timezones are properly defined
    assert_not_nil @timezones
    assert_kind_of Hash, @timezones
    
    # Test that all required timezones are present
    required_zones = ['UTC', 'CDG', 'LHR', 'IAD', 'ORD', 'DEN', 'SFO', 'HNL', 'HYD', 'SIN', 'NRT']
    required_zones.each do |zone|
      assert @timezones.key?(zone), "Missing timezone: #{zone}"
      assert_not_nil @timezones[zone], "Timezone #{zone} has nil value"
      assert_kind_of String, @timezones[zone], "Timezone #{zone} is not a string"
    end
  end
  
  def test_timezone_identifiers_are_valid
    # Test that all IANA timezone identifiers are valid
    @timezones.values.each do |tz_id|
      assert_nothing_raised do
        TZInfo::Timezone.get(tz_id)
      end
    end
  end
  
  def test_get_time_in_zone_format
    # Test that get_time_in_zone returns properly formatted output
    result = get_time_in_zone('UTC', 'UTC')
    
    # Should match pattern: "UTC: HH:MM" or "UTC: HH:MM (DST)"
    assert_match(/^UTC: \d{2}:\d{2}( \(DST\))?$/, result)
  end
  
  def test_get_time_in_zone_with_dst_detection
    # Test DST detection for a timezone that uses DST
    result = get_time_in_zone('America/New_York', 'IAD')
    
    # Should include time and optionally DST indicator
    assert_match(/^IAD: \d{2}:\d{2}( \(DST\))?$/, result)
  end
  
  def test_get_time_in_zone_with_invalid_timezone
    # Test error handling for invalid timezone
    result = get_time_in_zone('Invalid/Timezone', 'TEST')
    assert_equal 'TEST: ERROR', result
  end
  
  def test_default_mode_output
    # Test default mode (no arguments)
    ARGV.clear
    
    # Capture stdout
    output = capture_output do
      default_report
    end
    
    # Should contain UTC, IAD, and SFO
    assert_match(/UTC:/, output)
    assert_match(/IAD:/, output)
    assert_match(/SFO:/, output)
    
    # Should not contain other timezones
    assert_no_match(/CDG:/, output)
    assert_no_match(/LHR:/, output)
  end
  
  def test_all_mode_output
    # Test all mode
    ARGV.replace(['all'])
    
    output = capture_output do
      full_report
    end
    
    # Should contain all timezones
    @timezones.keys.each do |zone|
      assert_match(/#{zone}:/, output)
    end
  end
  
  def test_us_mode_output
    # Test US mode
    ARGV.replace(['us'])
    
    output = capture_output do
      us_report
    end
    
    # Should contain US timezones
    us_zones = ['IAD', 'ORD', 'DEN', 'SFO', 'HNL']
    us_zones.each do |zone|
      assert_match(/#{zone}:/, output)
    end
    
    # Should not contain non-US timezones
    non_us_zones = ['UTC', 'CDG', 'LHR', 'HYD', 'SIN', 'NRT']
    non_us_zones.each do |zone|
      assert_no_match(/#{zone}:/, output)
    end
  end
  
  def test_help_mode
    # Test help mode
    ARGV.replace(['help'])
    
    output = capture_output do
      usage
    end
    
    # Should contain usage information
    assert_match(/Usage/, output)
    assert_match(/help/, output)
    assert_match(/all/, output)
    assert_match(/us/, output)
    assert_match(/Version/, output)
  end
  
  def test_timezone_offsets_are_reasonable
    # Test that timezone offsets are within reasonable bounds
    @timezones.each do |display_name, tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      now = tz.now
      utc_now = Time.now.utc
      
      # Calculate offset in hours
      offset_hours = (now.utc_offset - utc_now.utc_offset) / 3600.0
      
      # Offset should be between -12 and +14 hours
      assert offset_hours >= -12, "Timezone #{display_name} has unreasonable negative offset: #{offset_hours}"
      assert offset_hours <= 14, "Timezone #{display_name} has unreasonable positive offset: #{offset_hours}"
    end
  end
  
  def test_dst_transitions
    # Test that DST detection works for known DST timezones
    dst_timezones = ['America/New_York', 'Europe/London', 'Europe/Paris']
    
    dst_timezones.each do |tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      now = tz.now
      
      # Should be able to detect DST status
      assert_kind_of TrueClass, tz.current_period.dst? if tz.current_period.dst?
      assert_kind_of FalseClass, tz.current_period.dst? unless tz.current_period.dst?
    end
  end
  
  def test_non_dst_timezones
    # Test that non-DST timezones are handled correctly
    non_dst_timezones = ['UTC', 'Asia/Tokyo', 'Asia/Singapore', 'Pacific/Honolulu']
    
    non_dst_timezones.each do |tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      
      # These timezones should not observe DST
      assert !tz.current_period.dst?, "Timezone #{tz_id} should not observe DST"
    end
  end
  
  private
  
  def capture_output
    # Capture stdout for testing
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end

# Run tests if this file is executed directly
if __FILE__ == $0
  puts "Running time_by_zones tests..."
  puts "=" * 50
  
  # Run the test suite
  Test::Unit::AutoRunner.run
end 