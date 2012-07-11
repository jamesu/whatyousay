require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, (ENV["RACK_ENV"]||'development').to_sym)

require 'fileutils'
require 'date'
require 'time'
require 'CGI'
require 'active_support'

# Core
%w{log_collection log_entry sender html_dumper}.each do |lib|
  require File.join(File.dirname(__FILE__), lib)
end

# Parsers
%w{parser bip_parser colloquy_parser ircii_parser talker_parser json_parser}.each do |parser|
  require File.join(File.dirname(__FILE__), "parsers/#{parser}")
end


