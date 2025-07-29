#!/usr/bin/env ruby
#
# geektool ruby script that displays time by time zones
# which allows me to not have to think about what time it is in other locations
# Version 2.0 - Now with automatic DST detection and proper timezone handling
#
###############################################################################

require 'tzinfo'

@version = "v2.0"

# Define timezones with proper IANA timezone identifiers
@timezones = {
  'UTC' => 'UTC',
  'CDG' => 'Europe/Paris',      # Paris Charles de Gaulle
  'LHR' => 'Europe/London',     # London Heathrow
  'IAD' => 'America/New_York',  # Washington Dulles
  'ORD' => 'America/Chicago',   # Chicago O'Hare
  'DEN' => 'America/Denver',    # Denver
  'SFO' => 'America/Los_Angeles', # San Francisco
  'HNL' => 'Pacific/Honolulu',  # Honolulu
  'HYD' => 'Asia/Kolkata',      # Hyderabad
  'SIN' => 'Asia/Singapore',    # Singapore
  'NRT' => 'Asia/Tokyo',        # Tokyo Narita
}

# set mode to use ARGV
mode = ARGV[0]

# If ARGV is not used set mode to default.
if mode.nil?
  mode = "default"
end

# a helpful usage statement.
def usage()
  msg = <<EOM

  Usage #{$0} [mode]
   help           :Display this help
   all            :Display all configured time zones
   us             :Display only US timezones
   * of {blank}   :Display UTC, IAD and SFO time only

  Version #{@version}
EOM
  puts msg
  exit 0
end

def get_time_in_zone(timezone_id, display_name)
  begin
    tz = TZInfo::Timezone.get(timezone_id)
    time = tz.now
    formatted_time = time.strftime("%H:%M")
    
    # Add DST indicator if applicable
    dst_indicator = tz.current_period.dst? ? " (DST)" : ""
    
    "#{display_name}: #{formatted_time}#{dst_indicator}"
  rescue => e
    "#{display_name}: ERROR"
  end
end

# Define the report called by "all" mode. Displays all configured timezones.
def full_report()
  @timezones.each do |display_name, timezone_id|
    print "#{get_time_in_zone(timezone_id, display_name)}     "
  end
  puts
end

# Define the report called by "us" mode. Displays all configured US timezones.
def us_report()
  us_zones = {
    'IAD' => 'America/New_York',
    'ORD' => 'America/Chicago',
    'DEN' => 'America/Denver',
    'SFO' => 'America/Los_Angeles',
    'HNL' => 'Pacific/Honolulu'
  }
  
  us_zones.each do |display_name, timezone_id|
    print "#{get_time_in_zone(timezone_id, display_name)}     "
  end
  puts
end

# Define the default report. Displays UTC, IAD and SFO times.
def default_report()
  default_zones = {
    'UTC' => 'UTC',
    'IAD' => 'America/New_York',
    'SFO' => 'America/Los_Angeles'
  }
  
  default_zones.each do |display_name, timezone_id|
    print "#{get_time_in_zone(timezone_id, display_name)}     "
  end
  puts
end

# Case statement to define the mode to run in.
case mode
  when "all"
    full_report
  when "us"
    us_report
  when "help"
    usage
  else 
    default_report
end

