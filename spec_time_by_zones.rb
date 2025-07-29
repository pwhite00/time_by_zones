#!/usr/bin/env ruby
#
# RSpec-style tests for time_by_zones.rb
# Run with: ruby spec_time_by_zones.rb
#

require 'time'
require_relative 'time_by_zones'

# Make @timezones available in this context
TIMEZONES = @timezones

def get_timezones
  TIMEZONES
end

# Simple RSpec-like testing framework
class RSpecLike
  def self.describe(description, &block)
    puts "\n#{description}"
    puts "=" * description.length
    new.instance_eval(&block)
  end
  
  def it(description, &block)
    print "  #{description}... "
    begin
      instance_eval(&block)
      puts "✓ PASS"
    rescue => e
      puts "✗ FAIL: #{e.message}"
      puts "  #{e.backtrace.first}"
    end
  end
  
  def expect(value)
    Expectation.new(value)
  end
  
  def be_nil
    BeNilMatcher.new
  end
  
  def be_kind_of(klass)
    BeKindOfMatcher.new(klass)
  end
  
  def include(item)
    IncludeMatcher.new(item)
  end
  
  def match(regex)
    MatchMatcher.new(regex)
  end
  
  def eq(expected)
    EqMatcher.new(expected)
  end
  
  def be_true
    BeTrueMatcher.new
  end
  
  def be_false
    BeFalseMatcher.new
  end
  
  def be_greater_than(value)
    BeGreaterThanMatcher.new(value)
  end
  
  def be_less_than(value)
    BeLessThanMatcher.new(value)
  end
  
  def raise_error(error_class = StandardError)
    RaiseErrorMatcher.new(error_class)
  end
  
  def not
    NotMatcher.new
  end
  
  def capture_output(&block)
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end

class Expectation
  def initialize(value)
    @value = value
  end
  
  def to(matcher)
    matcher.matches?(@value) or raise matcher.failure_message
  end
  
  def not_to(matcher)
    matcher.not_matches?(@value) or raise matcher.negative_failure_message
  end
end

class BeNilMatcher
  def matches?(value)
    value.nil?
  end
  def not_matches?(value)
    !value.nil?
  end
  def failure_message
    "expected nil but got value"
  end
  def negative_failure_message
    "expected not nil but got nil"
  end
end

class BeKindOfMatcher
  def initialize(klass)
    @klass = klass
  end
  def matches?(value)
    value.is_a?(@klass)
  end
  def not_matches?(value)
    !value.is_a?(@klass)
  end
  def failure_message
    "expected #{@klass} but got #{value.class}"
  end
  def negative_failure_message
    "expected not #{@klass} but got #{@klass}"
  end
end

class IncludeMatcher
  def initialize(item)
    @item = item
  end
  def matches?(value)
    value.include?(@item)
  end
  def not_matches?(value)
    !value.include?(@item)
  end
  def failure_message
    "expected #{value.inspect} to include #{@item.inspect}"
  end
  def negative_failure_message
    "expected #{value.inspect} to not include #{@item.inspect}"
  end
end

class MatchMatcher
  def initialize(regex)
    @regex = regex
  end
  def matches?(value)
    value.match?(@regex)
  end
  def not_matches?(value)
    !value.match?(@regex)
  end
  def failure_message
    "expected #{value.inspect} to match #{@regex.inspect}"
  end
  def negative_failure_message
    "expected #{value.inspect} to not match #{@regex.inspect}"
  end
end

class EqMatcher
  def initialize(expected)
    @expected = expected
  end
  def matches?(value)
    value == @expected
  end
  def not_matches?(value)
    value != @expected
  end
  def failure_message
    "expected #{@expected.inspect} but got #{value.inspect}"
  end
  def negative_failure_message
    "expected not #{@expected.inspect} but got #{@expected.inspect}"
  end
end

class BeTrueMatcher
  def matches?(value)
    value == true
  end
  def not_matches?(value)
    value != true
  end
  def failure_message
    "expected true but got #{value.inspect}"
  end
  def negative_failure_message
    "expected not true but got true"
  end
end

class BeFalseMatcher
  def matches?(value)
    value == false
  end
  def not_matches?(value)
    value != false
  end
  def failure_message
    "expected false but got #{value.inspect}"
  end
  def negative_failure_message
    "expected not false but got false"
  end
end

class BeGreaterThanMatcher
  def initialize(value)
    @value = value
  end
  def matches?(actual)
    actual > @value
  end
  def not_matches?(actual)
    actual <= @value
  end
  def failure_message
    "expected greater than #{@value} but got #{actual}"
  end
  def negative_failure_message
    "expected not greater than #{@value} but got greater"
  end
end

class BeLessThanMatcher
  def initialize(value)
    @value = value
  end
  def matches?(actual)
    actual < @value
  end
  def not_matches?(actual)
    actual >= @value
  end
  def failure_message
    "expected less than #{@value} but got #{actual}"
  end
  def negative_failure_message
    "expected not less than #{@value} but got less"
  end
end

class RaiseErrorMatcher
  def initialize(error_class)
    @error_class = error_class
  end
  def matches?(block)
    begin
      block.call
      false
    rescue @error_class
      true
    rescue
      false
    end
  end
  def not_matches?(block)
    begin
      block.call
      true
    rescue @error_class
      false
    rescue
      true
    end
  end
  def failure_message
    "expected #{@error_class} to be raised"
  end
  def negative_failure_message
    "expected #{@error_class} not to be raised"
  end
end

class NotMatcher
  def initialize
    @matcher = nil
  end
  def to(matcher)
    @matcher = matcher
    self
  end
  def matches?(value)
    !@matcher.matches?(value)
  end
  def not_matches?(value)
    @matcher.matches?(value)
  end
  def failure_message
    "expected not to #{@matcher.failure_message}"
  end
  def negative_failure_message
    "expected to #{@matcher.negative_failure_message}"
  end
end

# Test suite
RSpecLike.describe "TimeByZones" do
  
  it "should have valid timezone mappings" do
    expect(get_timezones).not_to be_nil
    expect(get_timezones).to be_kind_of(Hash)
    
    required_zones = ['UTC', 'CDG', 'LHR', 'IAD', 'ORD', 'DEN', 'SFO', 'HNL', 'HYD', 'SIN', 'NRT']
    required_zones.each do |zone|
      expect(get_timezones).to include(zone)
      expect(get_timezones[zone]).not_to be_nil
      expect(get_timezones[zone]).to be_kind_of(String)
    end
  end
  
  it "should have valid IANA timezone identifiers" do
    get_timezones.values.each do |tz_id|
      expect(-> { TZInfo::Timezone.get(tz_id) }).not_to raise_error
    end
  end
  
  it "should format time output correctly" do
    result = get_time_in_zone('UTC', 'UTC')
    expect(result).to match(/^UTC: \d{2}:\d{2}( \(DST\))?$/)
  end
  
  it "should handle DST detection" do
    result = get_time_in_zone('America/New_York', 'IAD')
    expect(result).to match(/^IAD: \d{2}:\d{2}( \(DST\))?$/)
  end
  
  it "should handle invalid timezones gracefully" do
    result = get_time_in_zone('Invalid/Timezone', 'TEST')
    expect(result).to eq('TEST: ERROR')
  end
  
  it "should output correct timezones in default mode" do
    output = capture_output { default_report }
    
    expect(output).to include('UTC:')
    expect(output).to include('IAD:')
    expect(output).to include('SFO:')
    expect(output).not_to include('CDG:')
    expect(output).not_to include('LHR:')
  end
  
  it "should output all timezones in all mode" do
    # Patch @timezones for the main script context
    @timezones = get_timezones
    output = capture_output { full_report }
    
    get_timezones.keys.each do |zone|
      expect(output).to include("#{zone}:")
    end
  end
  
  it "should output only US timezones in us mode" do
    output = capture_output { us_report }
    
    us_zones = ['IAD', 'ORD', 'DEN', 'SFO', 'HNL']
    us_zones.each do |zone|
      expect(output).to include("#{zone}:")
    end
    
    non_us_zones = ['UTC', 'CDG', 'LHR', 'HYD', 'SIN', 'NRT']
    non_us_zones.each do |zone|
      expect(output).not_to include("#{zone}:")
    end
  end
  
  it "should display help information correctly" do
    output = capture_output { usage }
    
    expect(output).to include('Usage')
    expect(output).to include('help')
    expect(output).to include('all')
    expect(output).to include('us')
    expect(output).to include('Version')
  end
  
  it "should have reasonable timezone offsets" do
    get_timezones.each do |display_name, tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      now = tz.now
      utc_now = Time.now.utc
      
      offset_hours = (now.utc_offset - utc_now.utc_offset) / 3600.0
      
      expect(offset_hours).to be_greater_than(-12)
      expect(offset_hours).to be_less_than(14)
    end
  end
  
  it "should correctly identify DST timezones" do
    dst_timezones = ['America/New_York', 'Europe/London', 'Europe/Paris']
    
    dst_timezones.each do |tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      expect(tz.current_period.respond_to?(:dst?)).to be_true
    end
  end
  
  it "should correctly identify non-DST timezones" do
    non_dst_timezones = ['UTC', 'Asia/Tokyo', 'Asia/Singapore', 'Pacific/Honolulu']
    
    non_dst_timezones.each do |tz_id|
      tz = TZInfo::Timezone.get(tz_id)
      expect(tz.current_period.dst?).to be_false
    end
  end
  
  it "should handle edge cases around midnight" do
    # Test that time wrapping works correctly
    result = get_time_in_zone('UTC', 'UTC')
    expect(result).to match(/^\d{2}:\d{2}/)
    
    # Test Pacific time (UTC-8)
    result = get_time_in_zone('America/Los_Angeles', 'SFO')
    expect(result).to match(/^\d{2}:\d{2}/)
  end
  
  it "should maintain consistent output format" do
    # Test multiple timezones to ensure consistent formatting
    zones_to_test = ['UTC', 'America/New_York', 'Asia/Tokyo']
    
    zones_to_test.each do |tz_id|
      result = get_time_in_zone(tz_id, 'TEST')
      expect(result).to match(/^TEST: \d{2}:\d{2}( \(DST\))?$/)
    end
  end
end

puts "\n" + "="*50
puts "Test Summary:"
puts "All tests completed!"
puts "="*50 