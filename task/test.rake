desc 'Runs the tests'
task :test => [:lexicons] do
  ENV['RESOURCE_PATH'] = File.expand_path('../../tmp/lexicons/hotel', __FILE__)

  sh('cucumber features')
end
