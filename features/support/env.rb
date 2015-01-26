require_relative '../../lib/opener/property_tagger'
require 'rspec'

def kernel
  return Opener::PropertyTagger.new(:no_time => true)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
