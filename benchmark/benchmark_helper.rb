require 'benchmark/ips'

require_relative '../lib/opener/property_tagger'

ENV['RESOURCE_PATH'] ||= File.expand_path('../../tmp/lexicons/hotel', __FILE__)
