#!/usr/bin/env ruby

require 'opener/daemons'

require_relative '../lib/opener/property_tagger'

daemon = Opener::Daemons::Daemon.new(Opener::PropertyTagger)

daemon.start
