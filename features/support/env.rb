require_relative '../../lib/opener/property_tagger'
require 'rspec/expectations'

def kernel
  return Opener::PropertyTagger.new(:args => ['--no-time'])
end
