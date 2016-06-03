require 'rubygems'

require 'yaml'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
YAML::ENGINE.yamler= 'syck'

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
