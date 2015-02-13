require 'spec_helper'

describe Opener::PropertyTagger::AspectsCache do
  before do
    @cache = described_class.new
    @path  = File.expand_path('../../../../tmp/lexicons/hotel/en.txt', __FILE__)
  end

  describe '#[]' do
    it 'returns a Hash' do
      @cache[@path].should be_an_instance_of(Hash)
    end

    it 'return the keys as Symbols' do
      @cache[@path].each do |key, _|
        key.should be_an_instance_of(Symbol)
      end
    end

    it 'returns the values as Arrays' do
      @cache[@path].each do |_, values|
        values.should be_an_instance_of(Array)
      end
    end

    it 'returns the cached data after it has been loaded' do
      @cache.should_receive(:load_aspects).once.and_call_original

      @cache[@path]
      @cache[@path]
    end
  end
end
