require File.expand_path('../lib/opener/property_tagger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'opener-property-tagger'
  gem.version     = Opener::PropertyTagger::VERSION
  gem.authors     = ['development@olery.com']
  gem.summary     = 'Property tagger for hotels in Dutch and English.'
  gem.description = gem.summary
  gem.homepage    = 'http://opener-project.github.com/'
  gem.extensions  = ['ext/hack/Rakefile']

  gem.license = 'Apache 2.0'

  gem.required_ruby_version = '>= 1.9.2'

  gem.files = Dir.glob([
    'core/data/**/*',
    'core/*.py',
    'ext/**/*',
    'lib/**/*',
    'config.ru',
    '*.gemspec',
    '*_requirements.txt',
    'README.md',
    'LICENSE.txt',
    'exec/**/*',
    'task/*'
  ]).select { |file| File.file?(file) }

  gem.executables = Dir.glob('bin/*').map { |file| File.basename(file) }

  gem.add_dependency 'rake'
  gem.add_dependency 'cliver'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'puma'
  gem.add_dependency 'opener-daemons'
  gem.add_dependency 'opener-webservice'
  gem.add_dependency 'opener-core', '~> 1.0.2'
  gem.add_dependency 'nokogiri'

  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'cucumber'
end
