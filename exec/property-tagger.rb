#!/usr/bin/env ruby

require 'opener/daemons'
require 'opener/core/argv_splitter'

require_relative '../lib/opener/property_tagger'

daemon_args, kernel_args = Opener::Core::ArgvSplitter.split(ARGV)

factory = Opener::PropertyTagger::Factory.new(:args => kernel_args)
options = Opener::Daemons::OptParser.parse!(daemon_args)
daemon  = Opener::Daemons::Daemon.new(factory, options)

daemon.start
