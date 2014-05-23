require 'spec_helper'

describe Opener::PropertyTagger::Factory do
  context '#initialize' do
    example 'store the options in an attribute' do
      described_class.new(:number => 10).options.should == {:number => 10}
    end
  end

  context '#new' do
    before :all do
      @factory = described_class.new(:args => %w{--help})
    end

    example 'create a new instance' do
      @factory.new.is_a?(Opener::PropertyTagger).should == true
    end

    example 'pass the options to the kernel' do
      @factory.new.args.should == %w{--help}
    end

    example 'pass the options as a copy' do
      @factory.new

      @factory.options.key?(:args).should == true
    end
  end
end
