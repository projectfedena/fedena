#!/usr/bin/env ruby
 
# This script will take a look at the output from your rails application and print
# info about the number of selects, updates and inserts, as well as the slowest partials
# to render and the slowest selects.
#
# Usage... just pipe the output of your rails app or log to it:
#
# script/server | log_analyzer.rb
# or..
# tail -f log/development.log | log_analyzer.rb
#
num_selects = 0
num_sqls = 0
num_exists = 0
num_cached_selects = 0
num_updates = 0
num_inserts = 0
num_partials = 0
num_searches = 0
partial_times = {}
request_lines = []
select_types = {}
exists_types = {}
search_types = {}
select_times = []
 
def calculate_time(time_string, unit_string)
  time = time_string.to_f
  if unit_string == 'ms'
    time
  else
    time * 1000.0
  end
end
 
while line = STDIN.gets
  if line =~ /\s*Processing\s+([\w|:]*)Controller#.*/
    num_selects = 0
    num_sqls = 0
    num_exists = 0
    num_cached_selects = 0
    num_updates = 0
    num_inserts = 0
    num_partials = 0
    num_searches = 0
    partial_times = {}
    request_lines = []
    select_types = {}
    exists_types = {}
    search_types = {}
    select_times = []
  elsif line =~ /(\W*)(\w+) Load[\w|\s]+\(([0-9|\.]+)(m?s)\)(.*)/
    num_selects += 1
    select_types[$2] ||= [0, 0.0]
    select_types[$2][0] += 1
    time = calculate_time($3, $4)
    select_types[$2][1] += time
    select_times << [time, $5]
  elsif line =~ /(\W*)(\w+) Exists[\w|\s]+\(([0-9|\.]+)(m?s)\)(.*)/
    num_exists += 1
    exists_types[$2] ||= [0, 0.0]
    exists_types[$2][0] += 1
    exists_types[$2][1] += calculate_time($3, $4)
  elsif line =~ /(\W*)SQL[\w|\s]+\(([0-9|\.]+)(m?s)\)(.*)/
    num_sqls += 1
  elsif line =~ /(\s*)CACHE(.*)/
    num_cached_selects += 1
  elsif line =~ /(\s*)(\w+) Create(.*)/
    num_inserts += 1
  elsif line =~ /(\s*)(\w+) Update(.*)/
    num_updates += 1
  elsif line =~ /(\s*)Rendered (.*) \((.*)\)(\s*)/
    num_partials += 1
    partial_times[$2] ||= 0.0
    partial_times[$2] += $3.to_f
  elsif line =~ /(\W*)Solr (\w+) Search[\w|\s]+\(([0-9|\.]+)(m?s)\)(.*)/
    num_searches += 1
    search_types[$2] ||= [0, 0.0]
    search_types[$2][0] += 1
    search_types[$2][1] += calculate_time($3, $4)
  elsif line =~ /(\s*)Completed in ([0-9|.]+)(m?s)(.*)/
    request_lines.each { |p_line| puts p_line }
    puts line
    puts '================================================'
    puts "Total Time: #{$2}"
    puts "Selects: #{num_selects}"
    puts "Raw SQL: #{num_sqls}"
    puts "Exists: #{num_exists}"
    puts "Cached Selects: #{num_cached_selects}"
    puts "Updates: #{num_updates}"
    puts "Inserts: #{num_inserts}"
    puts "Partials: #{num_partials}"
    puts "Searches: #{num_searches}"
    puts '================================================'
    puts ''
    puts 'Top ten partials:'
    time = calculate_time($2.to_f, $3)
    partial_times.map { |key, value| [key, value] }.sort_by { |i| i[1] }.reverse.slice(0, 10).each do |item|
      puts "#{item[0]} - #{item[1]} - #{((item[1] / time) * 100.0).to_i}%"
    end
    puts ''
    puts 'Top five selects by type:'
    select_types.map { |type, values| [type, values[0], values[1]] }.sort_by { |i| i[2] }.reverse.slice(0, 5).each do |item|
      puts "Type: #{item[0]} Count: #{item[1]} Time: #{item[2]} Percent: #{((item[2] / time) * 100.0).to_i}%"
    end
    puts ''
    puts 'Top five selects by count:'
    select_types.map { |type, values| [type, values[0], values[1]] }.sort_by { |i| i[1] }.reverse.slice(0, 5).each do |item|
      puts "Type: #{item[0]} Count: #{item[1]} Time: #{item[2]} Percent: #{((item[2] / time) * 100.0).to_i}%"
    end
    puts ''
    puts 'Five slowest selects:'
    select_times.sort_by { |item| item[0] }.reverse.slice(0, 5).each do |item|
      puts "Time: #{item[0]} Query: #{item[1]}"
    end
  end
  request_lines << line
end