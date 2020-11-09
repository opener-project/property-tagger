require_relative '../../lib/opener/property_tagger'
require 'rspec'

ENV['PROPERTY_TAGGER_LEXICONS_PATH'] = 'tmp/lexicons/hotel'

def kernel
  return Opener::PropertyTagger.new(:no_time => true, :pretty => true)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
