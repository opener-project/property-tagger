lexicons_url = 'https://s3-eu-west-1.amazonaws.com/opener/dummy-hotel-lexicons.tar.gz'
tmp_archive  = 'tmp/lexicons.tar.gz'
tmp_lexicons = 'tmp/lexicons'
en_lexicon   = 'tmp/lexicons/hotel/en.txt'

file(tmp_archive) do |task|
  sh "wget #{lexicons_url} -O #{task.name} --quiet"
end

directory(tmp_lexicons) do |task|
  sh "mkdir -p #{task.name}"
end

file(en_lexicon) do |task|
  sh "tar -xf #{tmp_archive} -C #{tmp_lexicons}"
end

desc 'Downloads dummy lexicons'
task :lexicons => [tmp_archive, tmp_lexicons, en_lexicon]
