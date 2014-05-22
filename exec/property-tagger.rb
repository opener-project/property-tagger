#!/usr/bin/env ruby

require 'opener/daemons'
require_relative '../lib/opener/property_tagger'

options = Opener::Daemons::OptParser.parse!(ARGV)
daemon  = Opener::Daemons::Daemon.new(Opener::PropertyTagger, options)

daemon.start