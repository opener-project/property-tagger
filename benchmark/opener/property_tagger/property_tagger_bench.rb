require_relative '../../benchmark_helper'

processor = Opener::PropertyTagger.new

input = File.read(
  File.expand_path('../../../../features/fixtures/input.en.kaf', __FILE__)
)

Benchmark.ips do |bench|
  bench.report 'English' do
    processor.run(input)
  end
end
