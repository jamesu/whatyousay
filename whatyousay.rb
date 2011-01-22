#!/usr/bin/env ruby
# Simple script to consolidate multiple chat logs into a single JSON/html document
#   (C) 2011 James S Urquhart (jamesu at gmail dot com)
#
# Reads from the list of input files, see --help for info.
#

require 'core'
require 'optparse'
require 'json'

OPTIONS = {
  :log_type => 'colloquy',
  :channel => nil,
  :output => 'out.json'
}

PARSERS = {
  'colloquy' => ColloquyParser,
  'bip' => BipParser,
  'ircii' => IrciiParser,
  'talker' => TalkerParser,
  'json' => JSONParser
}

def entry(logs)
  parser = nil
  collection = nil
  parser_class = PARSERS[OPTIONS[:log_type].downcase]
  unless parser_class
    puts "Unknown parser #{OPTIONS[:log_type]}"
    return -1
  else
    collection = LogCollection.new
    parser = parser_class.new(collection)
  end
  
  puts "Dumping to #{OPTIONS[:output]}"
  logs.each do |scan_path|
    (Dir[scan_path]).each do |file|
      puts file
      fs = File.open(file, "r")
      parser.parse(fs)
      fs.close
    end
  end
  
  collection.clean_entries
  unless OPTIONS[:channel].nil?
    channel = OPTIONS[:channel]
    collection.entries.each {|entry| entry.source = channel}
  end
  
  # Lets make JSON
  puts "Generating dump..."
  
  ext = OPTIONS[:output].split('.').last
  if ext == 'html'
    File.open(OPTIONS[:output], "w") do |fs|
      dump = HTMLDumper.new(collection)
      dump.write(fs)
    end
  else
    File.open(OPTIONS[:output], "w") do |fs|
      json = {:senders => collection.senders.map{|k,v| v.to_loghash },
       :entries => collection.entries.map{|entry| entry.to_loghash }}
       
       fs.write(JSON.pretty_generate(json))
    end
  end
  
  return 0
end

OptionParser.new do |opts|
  opts.banner = "Usage: whatyousay.rb [options] logs"
  opts.on( '-t', '--logType TYPE', 'Log Type' ) { |type| OPTIONS[:log_type] = type }
  opts.on( '-c', '--channel CHANNEL', 'Set channel' ) { |channel| OPTIONS[:channel] = channel }
  opts.on( '-o', '--output file', 'Set output' ) { |output| OPTIONS[:output] = output }
  opts.on( '-h', '--help', 'Display this screen' ) { puts opts; exit }
end.parse!

entry(ARGV)
